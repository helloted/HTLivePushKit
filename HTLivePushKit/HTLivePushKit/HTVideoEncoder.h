//
//  HTVideoEncoder.h
//  VideoCapture
//
//  Created by iMac on 2018/5/18.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef struct {
    NSUInteger    width;
    NSUInteger    height;
    NSUInteger    bitrate;
    NSUInteger    fps;
} HTVideoConfig;

@protocol HTVideoEncoderDelegate <NSObject>

- (void)videoEncoderSPS:(NSData *)sps pps:(NSData *)pps;
- (void)videoEncoderGetNALUData:(NSData*)data keyFrame:(BOOL)isKeyFrame;

@end

@interface HTVideoEncoder : NSObject

@property (nonatomic, assign)HTVideoConfig              config;
@property (nonatomic, assign)BOOL                       hasSPSPPS;
@property (nonatomic, weak)id<HTVideoEncoderDelegate>   delegate;

- (void)openWithConfig:(HTVideoConfig)config;

- (void)encodeVideoWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
