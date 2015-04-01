//
//  PendingOperations.m
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

// Override some getters to take advantage of lazy instantiation.
-(NSMutableDictionary *)downloadsInProgress
{
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadsInProgress;
}

-(NSOperationQueue *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download Queue";        // add a name to the queue in convenience dubug
        //_downloadQueue.maxConcurrentOperationCount = 1; // Here only for test use, in real project should comment this line
    }
    return _downloadQueue;
}


-(NSMutableDictionary *)filtrationsInProgress
{
    if (!_filtrationsInProgress) {
        _filtrationsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _filtrationsInProgress;
}

-(NSOperationQueue *)filtrationQueue
{
    if (!_filtrationQueue) {
        _filtrationQueue = [[NSOperationQueue alloc] init];
        _filtrationQueue.name = @"Image Filtration Queue";
        //_filtrationQueue.maxConcurrentOperationCount = 1;
    }
    return _filtrationQueue;
}

@end
