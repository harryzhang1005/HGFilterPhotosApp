//
//  PhotoListViewController.m
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/14/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import "PhotoListViewController.h"

@interface PhotoListViewController ()

@end

// 2015-03-26 20:57:03.216 HGClassicPhotos[8587:1507389] BSXPCMessage received error for message: Connection interrupted

@implementation PhotoListViewController

#pragma mark - Lazy instantiation photos and pendingOperations
// Custome getter
-(PendingOperations *)pendingTasks
{
    if (!_pendingTasks) {
        _pendingTasks = [[PendingOperations alloc] init];
    }
    return _pendingTasks;
}

// Custome getter
-(NSMutableArray *)photos
{
    if (!_photos)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kDatasourceURLString] ]; // 1 create a request
        AFHTTPRequestOperation *datasource_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request]; // 2 create requrest task
        
        // 3 Give the user feedback, while downloading the data source by enabling network activity indicator.
        // showing network spinning gear in status bar. default is NO. Using UIApplication activity indicatior view.
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // 4 set up blocks parameters
        [datasource_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Download the property list as NSData, and then by using toll-free bridging for data into CFDataRef and CFPropertyList,
            // convert it into NSDictionary.
            NSData *dsData = (NSData *)responseObject;
            CFPropertyListRef plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)dsData,
                                                                      kCFPropertyListImmutable, NULL);
            NSDictionary *dsDictionary = (__bridge NSDictionary *)plist;
            
            _photos = [NSMutableArray array];
            for (NSString *key in dsDictionary)
            {
                PhotoRecord *record = [[PhotoRecord alloc] init];
                record.URL = [NSURL URLWithString:[dsDictionary objectForKey:key]];
                record.name = key;
                [_photos addObject:record];
                record = nil; // here is important for free memory
            }
            
            CFRelease(plist);
            [self.tableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // Connection error message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:error.localizedDescription
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show]; alert = nil;
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        // 5 Add "datasource_operation" to "downloadQueue" of PendingOperations.
        [self.pendingTasks.downloadQueue addOperation:datasource_operation];
    }
    return _photos;
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Images Filter";
    
    //self.tableView.rowHeight = 80.0; // no need
    //[self setPendingTasks:nil]; // no need
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // If the app receive memory warning, cancel all operations.
    [self cancelAllOperations];
}

#pragma mark - Table view data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; // default is UITableViewCellSelectionStyleBlue.
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activityIndicatorView;
    
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    // Prevent these off-screen cells are still in the progress of being downloaded and filtered.
    // Only in-screen cells need to be downloaded and filtered.
    // Tell the table view to start operations only if the table view is not scrolling. (UITableView : UIScrollView)
    if (!tableView.dragging && !tableView.decelerating)
    {
        [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
    }
    
    // 3
    if (aRecord.hasImage)
    {
        [((UIActivityIndicatorView *) cell.accessoryView) stopAnimating];
        cell.imageView.image = aRecord.image;
        cell.textLabel.text = aRecord.name;
    } else if (aRecord.isFailed) {
        // 4
        [((UIActivityIndicatorView *) cell.accessoryView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Failed to load";
    } else {
        // 5 The image has not been downloaded yet. Start the download and filtering operations.
        // Start the activity indicator to show user something is going on.
        [((UIActivityIndicatorView *) cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        
        [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - table view delegate method
// For better viewing, change the height of each row to 80.0, The default value is 44.0.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

#pragma mark - Helper methods
/*
 Note: the methods for downloading and filtering images are implemented separately, as there is a possibility that while an image is being downloaded the user can scroll away, and you won’t yet have applied the image filter. So next time the user comes to the same row, you don’t need to re-download the image; you only need to apply the image filter! Efficiency rocks! :]
 */
-(void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
    
    if (!record.isFiltered) {
        [self startImageFiltrationForRecord:record atIndexPath:indexPath];
    }
}

-(void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    // 1
    if (![self.pendingTasks.downloadsInProgress.allKeys containsObject:indexPath])
    {
        // 2 The task added into queue and will be Started by system
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        
        [self.pendingTasks.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        
        [self.pendingTasks.downloadQueue addOperation:imageDownloader];
    }
}

-(void)startImageFiltrationForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    // 3
    if (![self.pendingTasks.filtrationsInProgress.allKeys containsObject:indexPath])
    {
        // 4 Start filtration
        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        
        // 5 You first MUST check to see if this particular indexPath has a pending download;
        // If so, you make this filtering operation dependent on that. Otherwise, don't need dependency.
        ImageDownloader *dependency = [self.pendingTasks.downloadsInProgress objectForKey:indexPath];
        if (dependency) {
            [imageFiltration addDependency:dependency];
        }
        
        [self.pendingTasks.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
        [self.pendingTasks.filtrationQueue addOperation:imageFiltration];
    }
}

#pragma mark - ImageDownloader and ImageFiltration delegate methods
-(void)imageDownloaderDidFinish:(ImageDownloader *)downloader
{
    // 1
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    // 2 Update UI.
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // 3
    [self.pendingTasks.downloadsInProgress removeObjectForKey:indexPath];
}

-(void)imageFiltrationDidFinish:(ImageFiltration *)filtration
{
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingTasks.filtrationsInProgress removeObjectForKey:indexPath];
}

/*
 Update: “xlledo” from the forums made a good point in regard to handling instances of PhotoRecord. 
 Because you are passing a pointer to PhotoRecord to NSOperation subclasses (ImageDownloader and ImageFiltration), you modify them directly. 
 Therefore, replaceObjectAtIndex:withObject: is redundant and not needed.
 */

#pragma mark - UIScrollViewDelegate methods
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 1 As soon as the user starts scrolling, you will want to suspend all operations and take a look at what the user wants to see.
    [self suspendAllOperations];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 2 If the value of decelerate is NO, that means the user stopped dragging the table view.
    // Therefore you want to resume suspend operations, cancel opertions for offscreen cells, and
    // start operations for onscreen cells.
    if (!decelerate)
    {
        [self loadImagesForOnscreenCells]; // key point
        
        [self resumeAllOperations];
    }
}

// This delegate method tells you that table view stopped scolling.
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 3
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}

#pragma mark - Helper methods
// You basically use factory methods to suspend, resume or cancel operations and queues.
-(void)suspendAllOperations
{
    [self.pendingTasks.downloadQueue setSuspended:YES];
    [self.pendingTasks.filtrationQueue setSuspended:YES];
}

-(void)resumeAllOperations
{
    [self.pendingTasks.downloadQueue setSuspended:NO];
    [self.pendingTasks.filtrationQueue setSuspended:NO];
}

-(void)cancelAllOperations
{
    [self.pendingTasks.downloadQueue cancelAllOperations];
    [self.pendingTasks.filtrationQueue cancelAllOperations];
}

// key point
-(void)loadImagesForOnscreenCells
{
    // 1 Get a set of visible rows
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    
    // 2 Get a set of all pending operations (download and filtration)
    NSMutableSet *pendingOperatios = [NSMutableSet setWithArray:[self.pendingTasks.downloadsInProgress allKeys]];
    [pendingOperatios addObjectsFromArray:[self.pendingTasks.filtrationsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperatios mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 3 Rows that need an operation = visible rows - pendings
    [toBeStarted minusSet:pendingOperatios];
    
    // 4 Rows that their operatoins should be cancelled = pendings - visible rows
    [toBeCancelled minusSet:visibleRows];
    
    // 5 Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
    for (NSIndexPath *anIndexPath in toBeCancelled)
    {
        ImageDownloader *pendingDownload = [self.pendingTasks.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingTasks.downloadsInProgress removeObjectForKey:anIndexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingTasks.filtrationsInProgress objectForKey:anIndexPath];
        [pendingFiltration cancel];
        [self.pendingTasks.filtrationsInProgress removeObjectForKey:anIndexPath];
    }
    toBeCancelled = nil;
    
    // 6 Loop through those to be started, and call ... for each.
    for (NSIndexPath *anIndexPath in toBeStarted)
    {
        PhotoRecord *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationsForPhotoRecord:recordToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
}


/*
 
 But beware — like deeply-nested blocks, gratuitous use of threads can make a project incomprehensible to people who have to maintain your code. Threads can introduce subtle bugs that may never appear until your network is slow, or the code is run on a faster (or slower) device, or one with a different number of cores. Test very carefully, and always use Instruments (or your own observations) to verify that introducing threads really has made an improvement.
 
 */



// no need anymore
-(UIImage *)applySepiaFilterToImage:(UIImage *)image
{
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues:kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    
    return sepiaImage;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
