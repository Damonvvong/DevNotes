//
//  DWVideoConstant.h
//  VideoDemo
//
//  Created by Damon on 16/8/28.
//  Copyright © 2016年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern NSString * const DWVideoRecoderErrorDomain;

typedef NS_ENUM(NSInteger, DWVideoRecoderErrorCode) {
	
	DWVideoRecoderErrorFailedToSetSessionPreset = 901,
	
	DWVideoRecoderErrorFailedToAddVideoInput  = 1000,
	DWVideoRecoderErrorFailedToAddAudioInput  = 1001,
	
	DWVideoRecoderErrorFailedToAddVideoOutput = 2000,
	DWVideoRecoderErrorFailedToAddAudioOutput = 2000,
	
	DWVideoRecoderErrorFailedToSwitchCameras	  = 3000,
	DWVideoRecoderErrorFailedToFocusAndExposure = 3001,
	
	DWVideoRecoderErrorFailedToCreatWriter	  = 4000,
	DWVideoRecoderErrorFailedToStartwriting   = 4001,
	DWVideoRecoderErrorFailedToCreatePixelBuffer = 4002,
	DWVideoRecoderErrorFailedToAppendVideoBuffer = 4003,
	DWVideoRecoderErrorFailedToAppendAudioBuffer = 4004,
	
	DWVideoRecoderErrorFailedToAddVideoInputWriter = 5000,
	DWVideoRecoderErrorFailedToAddAudioInputWriter = 5001,
	
	
};

NS_INLINE NSError* DWVideoRecoderError(NSString *description,DWVideoRecoderErrorCode code)
{
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description};
	NSError *error = [NSError errorWithDomain:DWVideoRecoderErrorDomain code:code userInfo:userInfo];
	return error;
}

NS_INLINE void DWShowFocusView(UIView *view, CGPoint point) {
	view.center = point;
	view.hidden = NO;
	[UIView animateWithDuration:0.25f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
					 }
					 completion:^(BOOL complete) {
						 double delayInSeconds = 0.5f;
						 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
						 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
							 view.hidden = YES;
							 view.transform = CGAffineTransformIdentity;
						 });
					 }];
}

NS_INLINE CGPoint DWCoverUIViewPointToCapturePoint(CALayer *layer,CGPoint point){
	
	return [(AVCaptureVideoPreviewLayer *)layer captureDevicePointOfInterestForPoint:point];
	
}

