//
//  PhotoRecord.m
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord

-(BOOL)hasImage
{
    return _image != nil;
}

-(BOOL)isFailed
{
    return _failed;
}

-(BOOL)isFiltered
{
    return _filtered;
}

@end
