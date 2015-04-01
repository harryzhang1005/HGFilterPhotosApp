//
//  PhotoListViewController.h
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/14/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"

#import "AFNetworking/AFNetworking.h"

/* AFNetworking vs NSURLConnection
 
 The AFNetworking library is built upon NSOperation and NSOperationQueue. It provides you with lots of convenient methods so that you don’t have to create your own operations for common tasks like downloading a file in the background.
 
 When it comes to downloading a file from the internet, it’s good practice to have some code in place to check for errors.You can never assume that there is going to be a reliable constant internet connection.
 
 Apple provides the NSURLConnection class for this purpose. Using that can be extra work. AFNetworking is an open source library that provides a very convenient way to do such tasks. You pass in two blocks, one for when the operation finishes successfully, and one for the time the operation fails. You will see it in action a little later on.
 */

#define kDatasourceURLString @"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"

// Set PhotoListViewController as root view controller
@interface PhotoListViewController : UITableViewController <ImageDownloaderDelegate, ImageFiltrationDelegate>

//@property (nonatomic, strong) NSDictionary *photos; // main data source of controller

// You don't need the data source as-is. You are going to create instance of PhotoRecord using the property list.
// So, change the class of "photos" from NSDictionary to NSMutableArray, so that you can update the array of photos.
@property (nonatomic, strong) NSMutableArray *photos; // main data source of controller

// Here like a Facade object
@property (nonatomic, strong) PendingOperations *pendingTasks;

@end
