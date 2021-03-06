//
//  HTCapture.m
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import "HTCapture.h"

@interface HTCapture ()<AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong)AVCaptureDeviceInput   *currentVideoInput;

@end

@implementation HTCapture

- (AVCaptureSession *)setupCaptureSessionWithConfig{
    // 1.创建捕获会话,必须要强引用，否则会被释放
    _captureSession = [[AVCaptureSession alloc] init];
    
    [_captureSession setSessionPreset:AVCaptureSessionPresetiFrame960x540];
    
    // 2.获取摄像头设备，默认是后置摄像头
    AVCaptureDevice *videoDevice = [self getVideoDevice:AVCaptureDevicePositionBack];
    // 3.创建对应视频设备输入对象
    _currentVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    // 4.获取声音设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // 5.创建对应音频设备输入对象
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    
    // 6.添加到会话中
    // 注意“最好要判断是否能添加输入，会话不能添加空的
    // 6.1 添加视频
    if ([_captureSession canAddInput:_currentVideoInput]) {
        [_captureSession addInput:_currentVideoInput];
    }
    // 6.2 添加音频
    if ([_captureSession canAddInput:audioDeviceInput]) {
        [_captureSession addInput:audioDeviceInput];
    }
    //====================以上是硬件捕获输入====================
    
    // 7.获取视频数据输出设备
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    

    // 7.1 设置代理，捕获视频样品数据
    // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
    dispatch_queue_t videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:videoQueue];
    if ([_captureSession canAddOutput:videoOutput]) {
        [_captureSession addOutput:videoOutput];
    }
    
    // 8.获取音频数据输出设备
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    // 8.2 设置代理，捕获视频样品数据
    // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
    dispatch_queue_t audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    [audioOutput setSampleBufferDelegate:self queue:audioQueue];
    if ([_captureSession canAddOutput:audioOutput]) {
        [_captureSession addOutput:audioOutput];
    }
    
    // 视频输出的方向
    AVCaptureConnection *videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    return _captureSession;
}

// 切换摄像头
- (void)switchCamera{
    AVCaptureDevice *newDevice;
    if (self.currentVideoInput.device.position != AVCaptureDevicePositionFront) {
        newDevice = [self getVideoDevice:AVCaptureDevicePositionFront];
    }else{
        newDevice = [self getVideoDevice:AVCaptureDevicePositionBack];
    }
    [_captureSession stopRunning];
    [self.captureSession removeInput:_currentVideoInput];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    if ([_captureSession canAddInput:videoInput]) {
        [_captureSession addInput:videoInput];
        _currentVideoInput = videoInput;
        [_captureSession startRunning];
    }
}

// 获取摄像头
- (AVCaptureDevice *)getVideoDevice:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}


// 获取输入设备数据，有可能是音频有可能是视频
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [self.delegate ht_captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
}

@end
