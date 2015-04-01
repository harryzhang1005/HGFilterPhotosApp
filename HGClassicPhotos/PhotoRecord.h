//
//  PhotoRecord.h
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>     // we need UIImage

@interface PhotoRecord : NSObject

@property (nonatomic, strong) NSString *name;   // To store the name of image
@property (nonatomic, strong) UIImage *image;   // To store the actual image
@property (nonatomic, strong) NSURL *URL;       // To store the URL of the image
@property (nonatomic, readonly) BOOL hasImage;  // Return YES if image is downloaded
@property (nonatomic, getter=isFiltered) BOOL filtered; // Return YES if image is sepia-filtered
@property (nonatomic, getter=isFailed) BOOL failed;     // Return YES if image failed to be downloaded

@end
