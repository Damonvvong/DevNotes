//
//  DWPreviewView.h
//  VideoDemo
//
//  Created by Damon on 16/8/27.
//  Copyright © 2016年 damon. All rights reserved.
//

#import "DWVideoConstant.h"

@class DWPreviewView;
@protocol DWPreviewViewDelegate <NSObject>

- (void)previewView:(DWPreviewView *)previewView singleClickAtPoint:(CGPoint)point;
- (void)previewView:(DWPreviewView *)previewView doubleClickAtPoint:(CGPoint)point;

@end

@interface DWPreviewView : UIView


@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic,   weak) id<DWPreviewViewDelegate> delegate;


@end







