//
//  ViewController.m
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import "ViewController.h"
#import "HTCapture.h"
#import "HTVideoEncoder.h"

@interface ViewController ()<HTCaptureDelegate,HTVideoEncoderDelegate>
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *liveBtn;

@property (nonatomic, strong)HTCapture        *capture;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *previedLayer;

@property (nonatomic, strong) HTVideoEncoder   *encoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_switchBtn addTarget:self.capture action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    
    // 编码
    _encoder = [[HTVideoEncoder alloc]init];
    _encoder.delegate = self;
    HTVideoConfig config;
    config.width = 540;
    config.height = 960;
    config.bitrate = 1000000;
    config.fps = 20;
    [_encoder openWithConfig:config];
    
    // 录制
    _capture = [[HTCapture alloc]init];
    _capture.delegate = self;
    AVCaptureSession  *session = [_capture setupCaptureSessionWithConfig];

    // 预览录制
    _previedLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previedLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:_previedLayer atIndex:0];
    [session startRunning];
    
    
    
}


- (void)ht_captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    [_encoder encodeVideoWithSampleBuffer:sampleBuffer];
}


- (void)videoEncoderGetNALUData:(NSData *)data keyFrame:(BOOL)isKeyFrame{
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    NSMutableData *h264Data = [[NSMutableData alloc] init];
    [h264Data appendData:ByteHeader];
    [h264Data appendData:data];
//    [[rtmpManager getInstance] send_rtmp_video:(uint8_t *)[h264Data bytes] andLength:(uint32_t)h264Data.length];
}


- (void)videoEncoderSPS:(NSData *)sps pps:(NSData *)pps{
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    
    
    //发sps
    NSMutableData *h264Data = [[NSMutableData alloc] init];
    [h264Data appendData:ByteHeader];
    [h264Data appendData:sps];
    
    //发pps
    NSMutableData *ppsData = [[NSMutableData alloc]init];
    
    [ppsData setLength:0];
    [ppsData appendData:ByteHeader];
    [ppsData appendData:pps];
    
//    [[rtmpManager getInstance] send_video_sps_pps:(uint8_t *)[h264Data bytes] andSpsLength:(uint32_t)h264Data.length andPPs:(uint8_t *)[ppsData bytes] andPPsLength:(uint32_t)ppsData.length];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
