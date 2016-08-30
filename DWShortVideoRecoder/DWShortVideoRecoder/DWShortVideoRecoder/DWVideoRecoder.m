//
//  DWVideoRecoder.m
//  VideoDemo
//
//  Created by Damon on 16/8/27.
//  Copyright © 2016年 damon. All rights reserved.
//

#import "DWVideoRecoder.h"
#import "DWVideoWriter.h"

@interface DWVideoRecoder () <AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,DWVideoWriterDelegate>
@property (nonatomic, strong) AVCaptureSession			*captureSession;		/**< 捕捉会话 */
@property (nonatomic,   weak) AVCaptureDeviceInput		*captureVideoInput;		/**< 视频捕捉输出 */

@property (nonatomic, strong) AVCaptureVideoDataOutput	*videoDataOutput;		/**< 视频数据输出 */
@property (nonatomic, strong) AVCaptureAudioDataOutput	*audioDataOutput;		/**< 音频数据输出 */

@property (nonatomic, strong) DWVideoWriter				*writer;				/**< 文件写入器 */

@end

@implementation DWVideoRecoder

- (instancetype)init {
	self = [super init];
	if (self) {
		
		_captureQueue = dispatch_queue_create("com.damonvvong.CaptureQueue", DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

#pragma mark - 捕捉初始化

/// 初始化 捕捉会话

- (BOOL)setupSession:(NSError **)error {
	
	self.captureSession = ({
		
		AVCaptureSession *session = [[AVCaptureSession alloc] init];
		if ([session canSetSessionPreset:[self sessionPreset]]) {
			[session setSessionPreset:[self sessionPreset]];
		}else{
			*error = DWVideoRecoderError(@"Failed to set sessionPreset.",DWVideoRecoderErrorFailedToSetSessionPreset);
			return NO;
		}
		session;
		
	});
	
	if (![self setupSessionInputs:error]) {
		return NO;
	}
	
	if (![self setupSessionOutputs:error]) {
		return NO;
	}
	
	return YES;
}

/// 初始化 捕捉输入
- (BOOL)setupSessionInputs:(NSError **)error {

	// 添加 摄像头
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:({
		
		[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
	}) error:error];
	
	if (!videoInput) { return NO; }
	
	if ([self.captureSession canAddInput:videoInput]) {
		
		[self.captureSession addInput:videoInput];
		self.captureVideoInput = videoInput;
		
	}else{
		
		*error = DWVideoRecoderError(@"Failed to add video input.",DWVideoRecoderErrorFailedToAddVideoInput);
		return NO;
		
	}
	
	// 添加 话筒
	AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:({
		
		[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
		
	}) error:error];
	
	if (!audioInput)  { return NO; }
	
	if ([self.captureSession canAddInput:audioInput]) {
		
		[self.captureSession addInput:audioInput];
		
	}else{
		
		*error = DWVideoRecoderError(@"Failed to add audio input.",DWVideoRecoderErrorFailedToAddAudioInput);
		return NO;
		
	}
	
	return YES;
}


- (BOOL)setupSessionOutputs:(NSError **)error {
	
	// 添加 视频输出
	self.videoDataOutput = ({
		
		AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
		dataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
		dataOutput.alwaysDiscardsLateVideoFrames = NO;
		[dataOutput setSampleBufferDelegate:self queue:self.captureQueue];
		dataOutput;
		
	});
	if ([self.captureSession canAddOutput:self.videoDataOutput]) {
		[self.captureSession addOutput:self.videoDataOutput];
	} else {
		*error = DWVideoRecoderError(@"Failed to add video output.",DWVideoRecoderErrorFailedToAddVideoOutput);
		return NO;
	}
	
	// 添加 音频输出
	self.audioDataOutput = ({
		
		AVCaptureAudioDataOutput * dataOutput = [[AVCaptureAudioDataOutput alloc] init];
		[dataOutput setSampleBufferDelegate:self queue:self.captureQueue];
		dataOutput;
		
	});
	if ([self.captureSession canAddOutput:self.audioDataOutput]) {
		[self.captureSession addOutput:self.audioDataOutput];
	} else {
		*error = DWVideoRecoderError(@"Failed to add audio output.",DWVideoRecoderErrorFailedToAddAudioOutput);
		return NO;
	}
	
	// 初始化 文件写入
	self.writer = ({
		
		DWVideoWriter * writer = [[DWVideoWriter alloc] initWithVideoSettings:({
			[self.videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
		})audioSettings:({
			[self.audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
		})dispatchQueue:self.captureQueue];
		writer.delegate = self;
		writer;
		
	});
	
	return YES;
}

/// 开始 捕捉会话
- (void)startSession {
	dispatch_async(self.captureQueue, ^{
		if (![self.captureSession isRunning]) {
			[self.captureSession startRunning];
		}
	});
}

/// 结束 捕捉会话
- (void)stopSession {
	dispatch_async(self.captureQueue, ^{
		if ([self.captureSession isRunning]) {
			[self.captureSession stopRunning];
		}
	});
	
}

#pragma mark - 录制控制 
- (void)startRecordingWithError:(NSError **)error {
	[self.writer startWritingWith:error];
	
	self.recording = YES;
}

- (void)stopRecordingWithError:(NSError **)error {
	[self.writer stopWritingWithError:error];
	self.recording = NO;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	
	NSError *error = nil;
	[self.writer processSampleBuffer:sampleBuffer error:&error];
	
	if (captureOutput == self.videoDataOutput) {
		
//		CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//		
//		CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
//		
//		[self.imageTarget setImage:sourceImage];
	}
}

#pragma mark - DWVideoWriterDelegate

// 文件写入完成
- (void)videoWriter:(DWVideoWriter *)videoWriter didOutputVideoAtPath:(NSURL *)url{
	
}


#pragma mark - Device Configuration

- (BOOL)canSwitchCameras { return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1;}

- (BOOL)switchCamerasWithError:(NSError **)error {
	
	if (![self canSwitchCameras]) { return NO; }
	
	
	
	// 初始化 新捕捉输出
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:({
		
		// 寻找切换的摄像头
		AVCaptureDevice *deviceOut = nil;
		AVCaptureDevicePosition position = self.captureVideoInput.device.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront :AVCaptureDevicePositionBack;
		
		for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
			if (device.position == position) {
				deviceOut = device;
				break;
			}
		}
		deviceOut;
		
	}) error:error];
	
	
	if (videoInput) {
		
		// 切换配置 必须保证事务原子性
		[self.captureSession beginConfiguration];
		[self.captureSession removeInput:self.captureVideoInput];
		if ([self.captureSession canAddInput:videoInput]) {
			[self.captureSession addInput:videoInput];
			self.captureVideoInput = videoInput;
		} else {
			[self.captureSession addInput:self.captureVideoInput];
		}
		[self.captureSession commitConfiguration];
		
	} else {
		*error = DWVideoRecoderError(@"Failed to Switch Cameras.",DWVideoRecoderErrorFailedToSwitchCameras);
		if ([self.delegate respondsToSelector:@selector(videoRecoderSwitchCamerasFailed:Error:)]) {
			[self.delegate videoRecoderSwitchCamerasFailed:self Error:*error];
		}
		return NO;
	}
	
	return YES;
}

- (void)autoFocusAndExposureAtPoint:(CGPoint)point error:(NSError **)error{
	
	AVCaptureDevice *device = self.captureVideoInput.device;
	
	
	if ([device lockForConfiguration:error]) {
		
		if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
			device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
			device.focusPointOfInterest = point;
		}
		
		if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
			device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
			device.exposurePointOfInterest = point;
		}
		
		[device unlockForConfiguration];
		
	} else {
		
		*error = DWVideoRecoderError(@"Failed to Focus And Exposure.",DWVideoRecoderErrorFailedToFocusAndExposure);
		if ([self.delegate respondsToSelector:@selector(videoRecoderFocusAndExposureFailed:Error:)]) {
			[self.delegate videoRecoderFocusAndExposureFailed:self Error:*error];
		}
		
	}
	
}
#pragma mark - getter && setter

- (NSString *)sessionPreset {
	return AVCaptureSessionPresetHigh;
}




@end
