//
//  ImageDownloader.m
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()

@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;

@end


@implementation ImageDownloader

#pragma mark - Life cycle
-(id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
                delegate:(id<ImageDownloaderDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

#pragma mark - Downloading image, Override NSOperation main method
-(void)main
{
    // Apple recommends using @autoreleasepool block instead of alloc and init NSAutoreleasePool,
    // because blocks are more efficient.
    @autoreleasepool
    {
        if (self.isCancelled) {
            return;
        }
        
        // get image data by image URL
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];
        
        if (self.isCancelled) { // if opeartion is cancelled in middle of process
            imageData = nil;
            return;
        }
        
        if (imageData) { // get image
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage; // will call setImage and retain downloadedImage object
        } else {
            self.photoRecord.failed = YES;
        }
        
        imageData = nil; // release tmp memory
        
        if (self.isCancelled) {
            return;
        }
        
        // Notify the caller on the main thread
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }//EndOfAutoreleasepool
    
}

@end
