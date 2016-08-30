//
//  ViewController.m
//  DWShortVideoRecoder
//
//  Created by Damon on 16/8/30.
//  Copyright © 2016年 damonvvong. All rights reserved.
//
#import "ViewController.h"
#import "DWPreviewView.h"
#import "DWVideoRecoder.h"

@interface ViewController ()<DWPreviewViewDelegate>

@property (nonatomic, strong) DWVideoRecoder *videoRecoder;
@property (nonatomic, strong) DWPreviewView *previewView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.videoRecoder = [[DWVideoRecoder alloc] init];
	
	self.previewView = [[DWPreviewView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 240 * [UIScreen mainScreen].bounds.size.width / 320)];
	
	NSError *error;
	if ([self.videoRecoder setupSession:&error]) {
		
		self.previewView.session = self.videoRecoder.captureSession;
		self.previewView.delegate = self;
		
		[self.videoRecoder startSession];
	}
	
	[self.view addSubview:self.previewView];
	
}


#pragma mark -

- (void)previewView:(DWPreviewView *)previewView singleClickAtPoint:(CGPoint)point {
	
	
	NSError *error = nil;
	[self.videoRecoder autoFocusAndExposureAtPoint:point error:&error];
	NSLog(@"%@",error);
}
- (void)previewView:(DWPreviewView *)previewView doubleClickAtPoint:(CGPoint)point {
	
	NSError *error = nil;
	[self.videoRecoder switchCamerasWithError:&error];
	NSLog(@"%@",error);
	
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	
	
	if (!self.videoRecoder.isRecording) {
		NSError *error = nil;
		[self.videoRecoder startRecordingWithError:&error];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			NSError *error = nil;
			[self.videoRecoder stopRecordingWithError:&error];
		});
	} else {
		NSError *error = nil;
		[self.videoRecoder stopRecordingWithError:&error];
	}
	
}




@end
