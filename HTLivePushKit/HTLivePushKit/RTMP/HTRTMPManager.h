//
//  HTRTMPManager.h
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rtmp.h"

@interface HTRTMPManager : NSObject
{
    RTMP* rtmp;
    double start_time;
    dispatch_queue_t workQueue;//异步Queue
}

@property (nonatomic,copy) NSString* rtmpUrl;//rtmp服务器流地址

/**
 *  获取单例
 *
 *  @return 单例
 */
+ (instancetype)shareInstance;

/**
 *  开始连接服务器
 *  urlString: 流媒体服务器地址
 *  @return 是否成功
 */
- (BOOL)startRtmpConnect:(NSString *)urlString;

/**
 *  停止连接服务器
 *
 *  @return 是否成功
 */
- (BOOL)stopRtmpConnect;

/**
 *  发送视频
 */
- (void)sendVideoSPS:(NSData *)spsData pps:(NSData *)ppsData;

- (void)sendVideoFrame:(NSData *)videoData;



- (void)sendAudioFrame:(NSData *)audioData;

/**
 *  发送音频spec
 *
 *  @param spec_buf spec数据
 *  @param spec_len spec长度
 */
- (void)send_rtmp_audio_spec:(unsigned char *)spec_buf andLength:(uint32_t) spec_len;

@end

