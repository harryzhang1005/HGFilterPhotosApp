//
//  ImageFiltration.h
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>                 // UIImage
#import <CoreImage/CoreImage.h>         // filter image
#import "PhotoRecord.h"

// Since you need to perform filtering on the UIImage instance, you need to import both UIKit and CoreImage frameworks.

@protocol ImageFiltrationDelegate;

/*
 The image filtering can be done as a separate operation in the background.
 
 You should check for isCancelled very frequently; a good practice is to call it before and after any expensive method call. 
 
 Once the filtering is done, the values of PhotoRecord instance are set appropriately, and then the delegate on the main thread is notified.
 */
@interface ImageFiltration : NSOperation

// Declare a delegate to notify the caller once its operation is finished.
@property (nonatomic, weak) id<ImageFiltrationDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

-(id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
                delegate:(id<ImageFiltrationDelegate>)theDelegate;

@end

/*
notify the caller once its operation is finished.
 */
@protocol ImageFiltrationDelegate <NSObject>

-(void)imageFiltrationDidFinish:(ImageFiltration *)filtration;

@end
