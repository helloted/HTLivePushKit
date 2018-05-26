//
//  ViewController.m
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import "ViewController.h"
#import "HTLivePushKit.h"

@interface ViewController ()<HTCaptureDelegate,HTVideoEncoderDelegate>
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *liveBtn;

@property (nonatomic, strong)HTCapture        *capture;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *previedLayer;

@property (nonatomic, strong) HTVideoEncoder   *videoEncoder;
@property (nonatomic, strong) HTAudioEncoder   *audioEncoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_switchBtn addTarget:self.capture action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    
    [[HTRTMPManager shareInstance] startRtmpConnect:@"rtmp://192.168.0.12:1935/zbcs/room"];
    
    // 编码
    _videoEncoder = [[HTVideoEncoder alloc]init];
    _videoEncoder.delegate = self;
    HTVideoConfig config;
    config.width = 540;
    config.height = 960;
    config.bitrate = 1000000;
    config.fps = 20;
    [_videoEncoder openWithConfig:config];
    
    // 录制
    _capture = [[HTCapture alloc]init];
    _capture.delegate = self;
    AVCaptureSession  *session = [_capture setupCaptureSessionWithConfig];

    // 预览录制
    _previedLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previedLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:_previedLayer atIndex:0];
    [session startRunning];
    
    _audioEncoder = [[HTAudioEncoder alloc]init];
    
}


- (void)ht_captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if ([connection.output isKindOfClass:[AVCaptureVideoDataOutput class]] ) {
        [_videoEncoder encodeVideoWithSampleBuffer:sampleBuffer];
    }else{
        [_audioEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
            [[HTRTMPManager shareInstance] sendAudioFrame:encodedData];
        }]; 
    }
}


- (void)videoEncoderResultNALUData:(NSData *)data keyFrame:(BOOL)isKeyFrame{
    [[HTRTMPManager shareInstance] sendVideoFrame:data];
}


- (void)videoEncoderResultSPS:(NSData *)sps pps:(NSData *)pps{
    [[HTRTMPManager shareInstance] sendVideoSPS:sps pps:pps];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
