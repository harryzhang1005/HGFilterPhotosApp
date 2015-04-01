//
//  ImageDownloader.h
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"

//
@protocol ImageDownloaderDelegate;

/*
 Image download task
 */
@interface ImageDownloader : NSOperation

// Declare a delegate so that you can notify the caller once the operation is finished.
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;


// Once the operation is finished, the caller has a reference to where this operation belongs to.
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;

// Here, you can independedtly set the image property of a PhotoRecrod once it is successfully downloaded.
// If downloading fails, set its failed value to YES.
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

// Declare a designated initializer.
-(id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
                delegate:(id<ImageDownloaderDelegate>)theDelegate;

@end

/*
 notify the caller once the operation is finished.
 */
@protocol ImageDownloaderDelegate <NSObject>

// Here, pass the operation back as an object.
// The caller can access both indexPathInTableView and photoRecord.
-(void)imageDownloaderDidFinish:(ImageDownloader *)downloader;

@end
