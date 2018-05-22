//
//  HTRTMPManager.h
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTRTMPManager : NSObject

+ (instancetype)shareInstance;

- (BOOL)connectWithURL:(NSString *)url;

- (void)stopConnect;

- (void)send_video_sps_pps:(unsigned char*)sps andSpsLength:(int)sps_len andPPs:(unsigned char*)pps andPPsLength:(uint32_t)pps_len;

- (void)send_rtmp_video:(unsigned char*)buf andLength:(uint32_t)len;

@end
