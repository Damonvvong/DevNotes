//
//  DWVideoRecoder.h
//  VideoDemo
//
//  Created by Damon on 16/8/27.
//  Copyright © 2016年 damon. All rights reserved.
//


#import "DWVideoConstant.h"

@class DWVideoRecoder;

@protocol DWVideoRecoderDelegate <NSObject>

- (void)videoRecoderSwitchCamerasFailed:(DWVideoRecoder *)videoRecoder Error:(NSError *)error;
- (void)videoRecoderFocusAndExposureFailed:(DWVideoRecoder *)videoRecoder Error:(NSError *)error;


@end

@interface DWVideoRecoder : NSObject

@property (nonatomic,   weak) id<DWVideoRecoderDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic, strong, readonly) dispatch_queue_t captureQueue;

@property (nonatomic, getter = isRecording) BOOL recording;

// Session Configuration
- (BOOL)setupSession:(NSError **)error;
- (BOOL)setupSessionInputs:(NSError **)error;
- (BOOL)setupSessionOutputs:(NSError **)error;

- (void)startSession;
- (void)stopSession;

- (NSString *)sessionPreset;

// Camera Device Configuration
- (BOOL)switchCamerasWithError:(NSError **)error;
- (BOOL)canSwitchCameras;
- (void)autoFocusAndExposureAtPoint:(CGPoint)point error:(NSError **)error;

// video recode
- (void)startRecordingWithError:(NSError **)error;
- (void)stopRecordingWithError:(NSError **)error;

@end
