//
//  ImageFiltration.m
//  HGClassicPhotos
//
//  Created by Harvey Zhang on 10/15/14.
//  Copyright (c) 2014 HappyGuy. All rights reserved.
//

#import "ImageFiltration.h"

@interface ImageFiltration ()

@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;

@end


@implementation ImageFiltration

#pragma mark - Life cycle
-(id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
                delegate:(id<ImageFiltrationDelegate>)theDelegate
{
    if (self = [super init]) {
        self.photoRecord = record;
        self.indexPathInTableView = indexPath;
        self.delegate = theDelegate;
    }
    return self;
}

#pragma mark - Override NSOperation main method
-(void)main
{
    @autoreleasepool
    {
        if (self.isCancelled) {
            return;
        }
        
        if (!self.photoRecord.hasImage) {
            return;
        }
        
        UIImage *filteredImage = [self applySepiaFilterToImage:self.photoRecord.image]; // filter image
        
        if (self.isCancelled) {
            return;
        }
        
        if (filteredImage)
        {
            self.photoRecord.image = filteredImage; // will call setImage, and retain filteredImage object
            self.photoRecord.filtered = YES;
            
            // Once the filtering is done, the values of PhotoRecord instance are set appropriately, and then the delegate on the main thread is notified.
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageFiltrationDidFinish:) withObject:self waitUntilDone:NO];
        }
        
    }//EndOfAutorealsepool
}

#pragma mark - Filter image
-(UIImage *)applySepiaFilterToImage:(UIImage *)image
{
    // 1 This is an expensive operation + time consuming (UIImage -> CIImage)
    CIImage *inputImageCI = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    
    if (self.isCancelled) {
        return nil;
    }
    
    // 2 Create a filter named CISepiaTone
    //[CIFilter filterWithName:<#(NSString *)#> keysAndValues:<#(id), ...#>, nil]
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues:kCIInputImageKey, inputImageCI,
                                                @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    // get filtered image
    CIImage *outputImageCI = [filter outputImage];
    
    if (self.isCancelled) {
        return nil;
    }
    
    // 3 Create a CGImageRef from the context. This is an expensive + time consuming (CIImage -> CGImageRef -> UIImage)
    
    // Create a new CoreImage context object, all output will be drawn into the CG context 'ctx'.
    CIContext *context = [CIContext contextWithOptions:nil];
    
    /*
     Render the region 'r' of image 'im' into a temporary buffer using the context, 
     then create and return a new CoreGraphics image with the results. 
     
     The caller is responsible for releasing the returned image.
     
     - (CGImageRef)createCGImage:(CIImage *)im fromRect:(CGRect)r ;
     
     extent : Return a rect the defines the bounds of non-(0,0,0,0) pixels.
     */
    CGImageRef outputImageRef = [context createCGImage:outputImageCI fromRect:[outputImageCI extent]];
    
    if (self.isCancelled) {
        CGImageRelease(outputImageRef);
        return nil;
    }
    
    // 4 Get filtered image and convert to UIImage object
    UIImage *sepiaImage = nil;
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    
    // 5 release memory
    CGImageRelease(outputImageRef);
    
    return sepiaImage;
}

@end
