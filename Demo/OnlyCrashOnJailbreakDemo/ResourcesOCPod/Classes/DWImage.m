//
//  DWImage.m
//  ResourcesOCPod
//
//  Created by damonwong on 2018/3/27.
//

#import "DWImage.h"

@implementation DWImage

- (UIImage *) image1InPod {
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"DWImage")];
    NSString *name = [[bundle.bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    NSURL *url = [bundle URLForResource:name withExtension:@"bundle"];
    if (url != NULL) {
        return [UIImage imageNamed:@"image1"
                        inBundle:[NSBundle bundleWithURL:url]
                                           compatibleWithTraitCollection:nil];
    } else {
            return [UIImage imageNamed:@"image1"
                              inBundle:[NSBundle bundleForClass:NSClassFromString(@"DWImage")]
                                                 compatibleWithTraitCollection:nil];
    }
}

- (UIImage *) image2InPod {
    return [UIImage imageNamed:@"image2"
                      inBundle:[NSBundle bundleForClass:NSClassFromString(@"DWImage")]
                                         compatibleWithTraitCollection:nil];
}
    
@end



