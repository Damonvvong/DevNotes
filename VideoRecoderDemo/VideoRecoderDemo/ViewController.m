//
//  ViewController.m
//  VideoRecoderDemo
//
//  Created by Damon on 16/8/29.
//  Copyright © 2016年 damonvvong. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession			 *captureSession;			/**< 捕捉会话 */
@property (nonatomic,   weak) AVCaptureDeviceInput		 *captureVideoInput;		/**< 视频捕捉输出 */
@property (nonatomic, strong) AVCaptureMovieFileOutput	 *captureMovieFileOutput;	/**< 视频输出流 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; /**< 相机拍摄预览图层 */

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.captureSession = ({
		
		AVCaptureSession *session = [[AVCaptureSession alloc] init];
		if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
			[session setSessionPreset:AVCaptureSessionPresetHigh];
		}
		session;
		
	});
	NSError *error = nil;
	[self setupSessionInputs:&error];
	
	//初始化设备输出对象，用于获得输出数据
	self.captureMovieFileOutput = ({
		AVCaptureMovieFileOutput *output = [[AVCaptureMovieFileOutput alloc]init];
		// 设置录制模式
		AVCaptureConnection *captureConnection=[output connectionWithMediaType:AVMediaTypeVideo];
		if ([captureConnection isVideoStabilizationSupported ]) {
			captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
		}
		//将设备输出添加到会话中
		if ([self.captureSession canAddOutput:output]) {
			[self.captureSession addOutput:output];
		}
		output;
	});
	
	
	//创建视频预览层，用于实时展示摄像头状态
	self.captureVideoPreviewLayer = ({
		AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
		previewLayer.frame=  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
		[self.view.layer addSublayer:previewLayer];
		self.view.layer.masksToBounds = YES;
		previewLayer;
		
	});
	
	
	[self.captureSession startRunning];
	
	
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
	}else{
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
		return NO;
	}
	
	return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	if (![self.captureMovieFileOutput isRecording]) {
		AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
		captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
		[self.captureMovieFileOutput startRecordingToOutputFileURL:({
			// 录制 缓存地址。
			NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
				[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
			}
			url;
		}) recordingDelegate:self];
	}else{
		[self.captureMovieFileOutput stopRecording];//停止录制
		
	
	}
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
	[self videoCompression];
}


-(void)videoCompression{
	
	NSLog(@"begin");
	NSURL *tempurl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]];
	//加载视频资源
	AVAsset *asset = [AVAsset assetWithURL:tempurl];
	//创建视频资源导出会话
	AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
	//创建导出视频的URL
	session.outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempLow.mov"]];
	//必须配置输出属性
	session.outputFileType = @"com.apple.quicktime-movie";
	//导出视频
	[session exportAsynchronouslyWithCompletionHandler:^{
		NSLog(@"end");
	}];
	
}
@end
