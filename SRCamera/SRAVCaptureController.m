//
//  SRAVCaptureController.m
//  SRCamera
//
//  Created by SarielTang on 16/4/6.
//  Copyright © 2016年 SarielTang. All rights reserved.
//

#import "SRAVCaptureController.h"
#import <AVFoundation/AVFoundation.h>

@interface SRAVCaptureController ()

//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong)       AVCaptureSession            * session;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong)       AVCaptureDeviceInput        * videoInput;
//照片输出流对象，当然我的照相机只有拍照功能，所以只需要这个对象就够了
@property (nonatomic, strong)       AVCaptureStillImageOutput   * stillImageOutput;
//预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong)       AVCaptureVideoPreviewLayer  * previewLayer;
//切换前后镜头的按钮
@property (nonatomic, strong)       UIBarButtonItem             * toggleButton;
//拍照按钮
@property (nonatomic, strong)       UIButton                    * shutterButton;

@property (nonatomic, strong)       UIView                      * cameraShowView;

@property (nonatomic,assign,getter=isPreview)BOOL preView;

@property (nonatomic,strong) UIButton *tipBtn;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *agreeBtn;
@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation SRAVCaptureController

-(void)viewDidLoad {
    [super viewDidLoad];
    //设置拍照预览图层的大小位置。
    self.cameraShowView = self.view;
    self.cameraShowView.backgroundColor = [UIColor blackColor];
    [self initUI];
}

//设置UI效果
- (void)initUI {
    //遮罩视图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.cameraShowView.bounds];
    [self.cameraShowView addSubview:imageView];
    _imageView = imageView;
    imageView.image = self.maskImage;
//    imageView.userInteractionEnabled = YES;
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.leading.trailing.bottom.equalTo(self.cameraShowView);
//    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusOn:)];
    [self.cameraShowView addGestureRecognizer:tap];
    
    //底部菜单栏
    UIView *toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.cameraShowView.frame.size.height - 115.0, self.cameraShowView.frame.size.width, 115.0)];
    [self.cameraShowView addSubview:toolBar];
    toolBar.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
//    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.bottom.equalTo(self.cameraShowView);
//        make.height.mas_equalTo(115.0);
//    }];
    
    //顶部的tip提示
    UIButton *tip = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cameraShowView addSubview:tip];
    _tipBtn = tip;
    [tip setImage:[UIImage imageNamed:@"icon_prompt.png"] forState:UIControlStateNormal];
    [tip setTitle:self.tipTitle forState:UIControlStateNormal];
    tip.titleLabel.font = [UIFont systemFontOfSize:15];
    tip.frame = CGRectMake((self.cameraShowView.frame.size.width -200)*0.5, 45, 200, 20);
//    [tip mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.cameraShowView).offset(45);
//        make.centerX.equalTo(self.cameraShowView);
//    }];
    
    //下面的三个按钮
    //拍照按钮,居中
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBar addSubview:takePhotoBtn];
    [takePhotoBtn setImage:[UIImage imageNamed:@"icon_photos.png"] forState:UIControlStateNormal];
    [takePhotoBtn setImage:[UIImage imageNamed:@"icon_photos_highlighted.png"] forState:UIControlStateHighlighted];
    [takePhotoBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    takePhotoBtn.frame = CGRectMake((toolBar.frame.size.width - 64) * 0.5, (toolBar.frame.size.height - 64)*0.5, 64, 64);
//    [takePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(toolBar);
//    }];
    
    //取消\重拍 按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBar addSubview:cancelBtn];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:23];
    cancelBtn.frame = CGRectMake(20, (toolBar.frame.size.height - 30)*0.5, 60, 30);
//    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(toolBar).offset(20);
//        make.centerY.equalTo(toolBar);
//    }];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn = cancelBtn;
    
    //使用照片按钮,默认隐藏
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBar addSubview:agreeBtn];
    [agreeBtn setTitle:@"使用照片" forState:UIControlStateNormal];
    agreeBtn.titleLabel.font = [UIFont systemFontOfSize:23];
    agreeBtn.hidden = YES;
    agreeBtn.frame = CGRectMake(toolBar.frame.size.width - 140, (toolBar.frame.size.height - 30)*0.5, 120, 30);
//    [agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.equalTo(toolBar).offset(-20);
//        make.centerY.equalTo(toolBar);
//    }];
    [agreeBtn addTarget:self action:@selector(agreeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _agreeBtn = agreeBtn;
}

//拍照
- (void)takePhoto {
    if (self.isPreview) {
        //如果是预览页，拍照不可用
        return;
    }
    [self shutterCamera];
}
//点击取消\重新拍照按钮
- (void)cancelBtnClick {
    if (self.isPreview) {
        //如果是预览页，则为重新拍照|| 点击重新拍照按钮，回到拍照页面 ||重新展示遮罩视图
        self.preView = NO;
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.agreeBtn.hidden = YES;
        self.tipBtn.hidden = NO;
        self.imageView.image = self.maskImage;
    }else {
        //点击取消按钮，dismiss
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//点击使用照片按钮
- (void) agreeBtnClick {
    //dismiss
}

//对焦
- (void) focusOn:(UIGestureRecognizer *)gesture {
    AVCaptureDevice *device = [self backCamera];
    //先进行判断是否支持控制对焦
    if (device.isFocusPointOfInterestSupported &&[device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error = nil;
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [device lockForConfiguration:&error];
        [device setFocusMode:AVCaptureFocusModeAutoFocus];
        CGPoint point = [gesture locationInView:self.cameraShowView];
        CGPoint pointofInterest = CGPointMake(point.x/self.cameraShowView.bounds.size.width, point.y/self.cameraShowView.bounds.size.height);
        [device setFocusPointOfInterest:pointofInterest];
        //操作完成后，记得进行unlock。
        [device unlockForConfiguration];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initialSession];
    [self setUpCameraLayer];
}

//注意以下的方法，在viewDidAppear和viewDidDisappear方法中启动和关闭session
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.session) {
        [self.session startRunning];
        
        AVCaptureDevice *device = [self backCamera];
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        if ([device.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
            [connection setPreferredVideoStabilizationMode:stabilizationMode];
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    if (self.session) {
        [self.session stopRunning];
    }
}

//在init方法执行的时候创建这些对象，然后在viewWillAppear方法里加载预览图层。现在就让我们看一下代码就清楚了。
- (void) initialSession
{
    //这个方法的执行我放在init方法里了
    self.session = [[AVCaptureSession alloc] init];
    //设置采集的质量
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    //初始化输入流
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
    //初始化图像输出流
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
}
//放置预览图层的View
//接下来在viewWillAppear方法里执行加载预览图层的方法
- (void) setUpCameraLayer
{
//    if (_cameraAvaible == NO) return;
    
    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        UIView * view = self.cameraShowView;
        CALayer * viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [view bounds];
        [self.previewLayer setFrame:bounds];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
    }
}

//这是获取前后摄像头对象的方法
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

//接着我们就来实现切换前后镜头的按钮，按钮的创建我就不多说了
- (void)toggleCamera {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        else
            return;
        
        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

//这是拍照方法
- (void) shutterCamera
{
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    AVCaptureDevice *device = [self backCamera];
    //先进行判断是否支持控制对焦
    if (device.isFocusPointOfInterestSupported &&[device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error = nil;
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [device lockForConfiguration:&error];
        [device setFocusMode:AVCaptureFocusModeAutoFocus];
        [device setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
        //操作完成后，记得进行unlock。
        [device unlockForConfiguration];
    }
    sleep(1);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        //        NSLog(@"image size = %@",NSStringFromCGSize(image.size));
        NSLog(@"%.2fKB",imageData.length/1000.0);
        
        //拍照成功，展示预览视图下面按钮变化
        self.preView = YES;
        //展示使用照片按钮
        self.agreeBtn.hidden = NO;
        //隐藏提示tip
        self.tipBtn.hidden = YES;
        //修改取消按钮文案为重拍
        [self.cancelBtn setTitle:@"重拍" forState:UIControlStateNormal];
        //展示拍到的图片
        self.imageView.image = image;
    }];
}

@end
