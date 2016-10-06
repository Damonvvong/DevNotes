//
//  DWPreviewView.m
//  VideoDemo
//
//  Created by Damon on 16/8/27.
//  Copyright © 2016年 damon. All rights reserved.
//

#import "DWPreviewView.h"

@interface DWPreviewView ()

@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;

@end


@implementation DWPreviewView


#pragma mark - init

+ (Class)layerClass {
	return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession*)session {
	return [(AVCaptureVideoPreviewLayer*)self.layer session];
}

- (void)setSession:(AVCaptureSession *)session {
	[(AVCaptureVideoPreviewLayer*)self.layer setSession:session];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupView];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setupView];
	}
	return self;
}

- (void)setupView {
	
	[(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	
	[self addGestureRecognizer:({
		
		_singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		_singleTapRecognizer;
		
	})];
	
	[self addGestureRecognizer:({
		
		_doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		_doubleTapRecognizer.numberOfTapsRequired = 2;
		_doubleTapRecognizer;
		
	})];
	
	[_singleTapRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];

	[self addSubview:({
		
		_focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
		_focusView.backgroundColor = [UIColor clearColor];
		_focusView.layer.borderColor = [UIColor blueColor].CGColor;
		_focusView.layer.borderWidth = 5.0f;
		_focusView.hidden = YES;
		_focusView;
		
	})];
}


#pragma mark - respose method

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
	
	CGPoint point = [recognizer locationInView:self];
	
	DWShowFocusView(self.focusView,point);
	
	if ([self.delegate respondsToSelector:@selector(previewView:singleClickAtPoint:)]) {
		//	return [ captureDevicePointOfInterestForPoint:point];
		[self.delegate previewView:self singleClickAtPoint:DWCoverUIViewPointToCapturePoint(self.layer,point)];
	}
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer {
	
	CGPoint point = [recognizer locationInView:self];
	
	DWShowFocusView(self.focusView,point);
	
	if ([self.delegate respondsToSelector:@selector(previewView:doubleClickAtPoint:)]) {
		[self.delegate previewView:self doubleClickAtPoint:DWCoverUIViewPointToCapturePoint(self.layer,point)];
	}
	
}





@end

