//
//  ViewController.m
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import "ViewController.h"
#import "HTCapture.h"

@interface ViewController ()<HTCaptureDelegate>

@property (nonatomic, strong)HTCapture        *capture;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *previedLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _capture = [[HTCapture alloc]init];
    _capture.delegate = self;
    AVCaptureSession  *session = [_capture setupCaptureSessionWithConfig];

    _previedLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previedLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:_previedLayer atIndex:0];
    
    [session startRunning];
    
}


- (void)ht_captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"capture out");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
