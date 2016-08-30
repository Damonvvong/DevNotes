//
//  DWVideoWriter.h
//  VideoDemo
//
//  Created by Damon on 16/8/27.
//  Copyright © 2016年 damon. All rights reserved.
//

#import "DWVideoConstant.h"

@class DWVideoWriter;

@protocol DWVideoWriterDelegate <NSObject>

- (void)videoWriter:(DWVideoWriter *)videoWriter didOutputVideoAtPath:(NSURL *)url;

@end

@interface DWVideoWriter : NSObject

@property (weak, nonatomic) id<DWVideoWriterDelegate> delegate;
@property (nonatomic, assign) BOOL isWriting;


- (id)initWithVideoSettings:(NSDictionary *)videoSettings audioSettings:(NSDictionary *)audioSettings dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)startWritingWith:(NSError **)error;
- (void)stopWritingWithError:(NSError **)error;

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer error:(NSError **)error;

@end


