//
//  DWViewController.m
//  ResourcesOCPod
//
//  Created by Damonvvong on 03/27/2018.
//  Copyright (c) 2018 Damonvvong. All rights reserved.
//

#import "DWViewController.h"
#import <ResourcesOCPod/DWImage.h>

@interface DWViewController ()

@end

@implementation DWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *image1View = [[UIImageView alloc] initWithImage:[[[DWImage alloc] init] image1InPod]];
    image1View.frame = CGRectMake(0, 0, 100, 100);
    image1View.center = self.view.center;

    UIImageView *image2View = [[UIImageView alloc] initWithImage:[[[DWImage alloc] init] image2InPod]];
    image2View.frame = CGRectMake(100, 0, 100, 100);

    [self.view addSubview:image1View];
    [self.view addSubview:image2View];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
