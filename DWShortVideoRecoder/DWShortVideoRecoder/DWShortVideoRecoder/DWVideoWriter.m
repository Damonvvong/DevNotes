//
//  DWVideoWriter.m
//  VideoDemo
//
//  Created by Damon on 16/8/27.
//  Copyright © 2016年 damon. All rights reserved.
//

#import "DWVideoWriter.h"
#import <CoreImage/CoreImage.h>

@interface DWVideoWriter ()

@property (nonatomic, strong) AVAssetWriter							*assetWriter;
@property (nonatomic, strong) AVAssetWriterInput					*assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput					*assetWriterAudioInput;

@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor	*assetWriterInputPixelBufferAdaptor;

@property (nonatomic, strong) dispatch_queue_t						dispatchQueue;

@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, strong) NSDictionary *audioSettings;

@property (nonatomic) BOOL firstSample;


@end

@implementation DWVideoWriter


- (id)initWithVideoSettings:(NSDictionary *)videoSettings
			  audioSettings:(NSDictionary *)audioSettings
			  dispatchQueue:(dispatch_queue_t)dispatchQueue {
	
	self = [super init];
	if (self) {
		_videoSettings = videoSettings;
		_audioSettings = audioSettings;
		_dispatchQueue = dispatchQueue;
	
	}
	return self;
}

- (void)startWritingWith:(NSError **)error{
	
	dispatch_async(self.dispatchQueue, ^{
		
		self.assetWriter = [AVAssetWriter assetWriterWithURL:({
			
			// 录制 缓存地址。
			NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
				[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
			}
			url;
			
		}) fileType:AVFileTypeQuickTimeMovie error:error];

		
		if (!self.assetWriter || *error) {

			*error = DWVideoRecoderError(@"Could not create writer",DWVideoRecoderErrorFailedToCreatWriter);
			
			return;
		}
		
		self.assetWriterVideoInput = ({
			
			AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:({
			
				// 录制参数。 根据调节参数实现压缩
				@{ AVVideoCodecKey : AVVideoCodecH264,
				   AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
				   AVVideoWidthKey : @(240),
				   AVVideoHeightKey : @(320),
				   // 压缩参数 ，10 表示清晰度。
				   AVVideoCompressionPropertiesKey : ({
					   @{ AVVideoAverageBitRateKey : @(240 * 320 * 10),
						  AVVideoMaxKeyFrameIntervalKey : @(10),
						  AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
						  };
				   })
				   };
				
			})];
			// yes指明输入应针对实时进行优化
			writerInput.expectsMediaDataInRealTime = YES;
			
			writerInput.transform = ({
				// 根据手机当前位置，旋转写入位置，以达到视频位置水平。
				CGAffineTransform transform;
				switch ([UIDevice currentDevice].orientation) {
					case UIDeviceOrientationLandscapeRight:
						transform = CGAffineTransformMakeRotation(M_PI);
						break;
					case UIDeviceOrientationPortraitUpsideDown:
						transform = CGAffineTransformMakeRotation((M_PI_2 * 3));
						break;
					case UIDeviceOrientationPortrait:
					case UIDeviceOrientationFaceUp:
					case UIDeviceOrientationFaceDown:
						transform = CGAffineTransformMakeRotation(M_PI_2);
						break;
					default:
						transform = CGAffineTransformIdentity;
						break;
				}
				transform;
			});
			writerInput;
		
		});

		// 视频输出添加到写入者中
		if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
			[self.assetWriter addInput:self.assetWriterVideoInput];
		} else {
			*error = DWVideoRecoderError(@"Failed to add writer video input.",DWVideoRecoderErrorFailedToAddVideoInputWriter);
			return;
		}
		
		// 音频输出
		self.assetWriterAudioInput = ({
			AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:self.audioSettings];
			writerInput.expectsMediaDataInRealTime = YES;
			writerInput;
		});
		
		if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
			[self.assetWriter addInput:self.assetWriterAudioInput];
		} else {
			*error = DWVideoRecoderError(@"Failed to add writer audio input.",DWVideoRecoderErrorFailedToAddAudioInputWriter);
			return;
		}
		
		// 视频输出添加到写入适配器中
		
		self.assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.assetWriterVideoInput sourcePixelBufferAttributes:({
			// 截取参数
			@{
			  (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
			  (id)kCVPixelBufferWidthKey : @(480),
			  (id)kCVPixelBufferHeightKey : @(320),
			  (id)kCVPixelFormatOpenGLESCompatibility : (id)kCFBooleanTrue
			  };
		})];
		
		self.isWriting = YES;
		self.firstSample = YES;
	});
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer error:(NSError **)error{
	
	if (!self.isWriting) {
		return;
	}
	CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	
	CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
	
	if (mediaType == kCMMediaType_Video) {
		
		CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
		
		if (self.firstSample) {                                             // 2
			if ([self.assetWriter startWriting]) {
				[self.assetWriter startSessionAtSourceTime:timestamp];
			} else {
				
				*error = DWVideoRecoderError(@"Failed to start writing.",DWVideoRecoderErrorFailedToStartwriting);
			}
			self.firstSample = NO;
		}

		CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
		
		/**
			======= 在这里可以利用 fiter 把 imageBuffer 处理后写入文件中
		 */
		
		if (self.assetWriterVideoInput.readyForMoreMediaData) {
			
			
//			if (![self.assetWriterVideoInput appendSampleBuffer:sampleBuffer]) {
//    
//			}
			// assetWriterInputPixelBufferAdaptor 应该是 从 imageBuffer 截取某一部分画面 然后再加入到 assetWriterVideoInput 中去
			if (![self.assetWriterInputPixelBufferAdaptor appendPixelBuffer:imageBuffer withPresentationTime:timestamp]) {
				
				*error = DWVideoRecoderError(@"Failed to Appending Video Buffer",DWVideoRecoderErrorFailedToAppendVideoBuffer);

			}
		}
	}else if (!self.firstSample && mediaType == kCMMediaType_Audio) {
		
		if (self.assetWriterAudioInput.isReadyForMoreMediaData) {
			// 直接将音频通过默认参数写入到 mov 中去
			if (![self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
				
				*error = DWVideoRecoderError(@"Failed to Appending audio Buffer",DWVideoRecoderErrorFailedToAppendAudioBuffer);
			}
		}
	}
	
}


- (void)stopWritingWithError:(NSError **)error {
	
	self.isWriting = NO;
	
	dispatch_async(self.dispatchQueue, ^{
		
		[self.assetWriter finishWritingWithCompletionHandler:^{
			
			if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
				
				dispatch_async(dispatch_get_main_queue(), ^{
					if ([self.delegate respondsToSelector:@selector(videoWriter:didOutputVideoAtPath:)]) {
						[self.delegate videoWriter:self didOutputVideoAtPath:self.assetWriter.outputURL];
					}
				});
				
			} else {
				
				*error = self.assetWriter.error;
				
			}
		}];
	});
}


@end
