//
//  SRAVCaptureController.h
//  SRCamera
//
//  Created by SarielTang on 16/4/6.
//  Copyright © 2016年 SarielTang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRAVCaptureController : UIViewController

/**
 *  遮罩视图
 */
@property (nonatomic,strong) UIImage *maskImage;

/**
 *  提示文字
 */
@property (nonatomic,copy) NSString *tipTitle;

@end
