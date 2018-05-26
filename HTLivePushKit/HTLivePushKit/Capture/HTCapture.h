//
//  HTCapture.h
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol HTCaptureDelegate <NSObject>

- (void)ht_captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

@interface HTCapture : NSObject


@property (nonatomic, weak)id <HTCaptureDelegate>    delegate;
@property (nonatomic, strong)AVCaptureSession        *captureSession;


- (AVCaptureSession *)setupCaptureSessionWithConfig;

- (void)switchCamera;

@end
