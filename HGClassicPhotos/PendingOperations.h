//
//  PendingOperations.h
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import <Foundation/Foundation.h>

/* To track status of each operation/task.
 
 Two dictionaries to keep track of active and pending downloads and filterings.
 The dictionary keys reference the indexPath of table view rows, and the dictionary values are
 going to be the separate instances of ImageDownloader and ImageFiltration.
 
 Note:You might wonder why you have to keep track of all active and pending operations. 
 Isn’t it possible to simply access them by making an inquiry to [NSOperationQueue operations]? Well, yes, 
 but in this project it won’t be very efficient to do so.
 
 Every time that you need to compare the indexPath of visible rows with the indexPath of rows that have a pending operation, 
 you would need to use several iterative loops, which is an expensive operation. By declaring an extra instance of NSDictionary, 
 you can conveniently keep track of pending operations without the need to perform inefficient loop operations.
*/
@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@property (nonatomic, strong) NSMutableDictionary *filtrationsInProgress;
@property (nonatomic, strong) NSOperationQueue *filtrationQueue;

@end
