//
//  ViewController.m
//  SRCamera
//
//  Created by SarielTang on 16/4/26.
//  Copyright © 2016年 Sariel. All rights reserved.
//

#import "ViewController.h"
#import "SRAVCaptureController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    SRAVCaptureController *vc = [[SRAVCaptureController alloc]init];
    vc.tipTitle = @"请保持证件平整，拍摄环境明亮";
    vc.maskImage = [UIImage imageNamed:@"take_photo_idcard"];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
