//
//  HTRTMPManager.m
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import "HTRTMPManager.h"
#import "rtmp.h"

#define RTMP_HEAD_SIZE (sizeof(RTMPPacket)+RTMP_MAX_HEADER_SIZE)

@interface HTRTMPManager(){
    RTMP* rtmp;
    double start_time;
    dispatch_queue_t workQueue;//异步Queue
}

@end

@implementation HTRTMPManager

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self->workQueue = dispatch_queue_create("rtmpSendQueue", NULL);
    }
    return self;
}

+ (instancetype)shareInstance
{
    static HTRTMPManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}


- (BOOL)connectWithURL:(NSString *)url{
    if(self->rtmp)
    {
        [self stopConnect];
    }
    
    self->rtmp = RTMP_Alloc();
    RTMP_Init(self->rtmp);
    int err = RTMP_SetupURL(self->rtmp, (char*)[url cStringUsingEncoding:NSASCIIStringEncoding]);
    
    if(err < 0)
    {
        NSLog(@"RTMP_SetupURL failed");
        RTMP_Free(self->rtmp);
        return false;
    }
    
    RTMP_EnableWrite(self->rtmp);
    
    err = RTMP_Connect(self->rtmp, NULL);
    
    if(err < 0)
    {
        NSLog(@"RTMP_Connect failed");
        RTMP_Free(self->rtmp);
        return false;
    }
    
    err = RTMP_ConnectStream(self->rtmp, 0);
    
    if(err < 0)
    {
        NSLog(@"RTMP_ConnectStream failed");
        RTMP_Close(self->rtmp);
        RTMP_Free(self->rtmp);
        exit(0);
        return false;
    }
    
    self->start_time = [[NSDate date] timeIntervalSince1970]*1000;
    
    return TRUE;
    
}

- (void)stopConnect{
    if(self->rtmp != NULL)
    {
        RTMP_Close(self->rtmp);
        RTMP_Free(self->rtmp);
        return;
    }
}


- (void)send_video_sps_pps:(unsigned char*)sps andSpsLength:(int)sps_len andPPs:(unsigned char*)pps andPPsLength:(uint32_t)pps_len
{
    dispatch_async(self->workQueue, ^{
        if(self->rtmp!= NULL)
        {
            RTMPPacket * packet;
            unsigned char * body;
            int i;
            
            packet = (RTMPPacket *)malloc(RTMP_HEAD_SIZE+1024);
            memset(packet,0,RTMP_HEAD_SIZE);
            
            packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
            body = (unsigned char *)packet->m_body;
            i = 0;
            body[i++] = 0x17;
            body[i++] = 0x00;
            
            body[i++] = 0x00;
            body[i++] = 0x00;
            body[i++] = 0x00;
            
            /*AVCDecoderConfigurationRecord*/
            body[i++] = 0x01;
            body[i++] = sps[1];
            body[i++] = sps[2];
            body[i++] = sps[3];
            body[i++] = 0xff;
            
            /*sps*/
            body[i++]   = 0xe1;
            body[i++] = (sps_len >> 8) & 0xff;
            body[i++] = sps_len & 0xff;
            memcpy(&body[i],sps,sps_len);
            i +=  sps_len;
            
            /*pps*/
            body[i++]   = 0x01;
            body[i++] = (pps_len >> 8) & 0xff;
            body[i++] = (pps_len) & 0xff;
            memcpy(&body[i],pps,pps_len);
            i +=  pps_len;
            
            packet->m_packetType = RTMP_PACKET_TYPE_VIDEO;
            packet->m_nBodySize = i;
            packet->m_nChannel = 0x04;
            packet->m_nTimeStamp = 0;
            packet->m_hasAbsTimestamp = 0;
            packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
            packet->m_nInfoField2 = self->rtmp->m_stream_id;
            
            if(RTMP_IsConnected(self->rtmp))
            {
                //调用发送接口
                int success = RTMP_SendPacket(self->rtmp,packet,TRUE);
                if(success != 1)
                {
                    NSLog(@"send_video_sps_pps fail");
                }
            }
            free(packet);
        }
        else
        {
            NSLog(@"send_video_sps_pps RTMP is not ready");
        }
    });
    
}


- (void)send_rtmp_video:(unsigned char*)buf andLength:(uint32_t)len
{
    __block unsigned char* buffer = buf;
    __block uint32_t length = len;
    dispatch_async(self->workQueue, ^{
        if(self->rtmp != NULL)
        {
            int type;
            RTMPPacket * packet;
            unsigned char * body;
            
            uint32_t timeoffset = [[NSDate date] timeIntervalSince1970]*1000 - self->start_time;  /*start_time为开始直播时的时间戳*/
            
            
            
            /*去掉帧界定符(这里可能2种,但是sps or  pps只能为 00 00 00 01)*/
            if (buffer[2] == 0x00){ /*00 00 00 01*/
                buffer += 4;
                length -= 4;
            } else if (buffer[2] == 0x01){ /*00 00 01*/
                buffer += 3;
                length -= 3;
            }
            type = buffer[0]&0x1f;
            
            packet = (RTMPPacket *)malloc(RTMP_HEAD_SIZE + length + 9);
            memset(packet,0,RTMP_HEAD_SIZE);
            
            packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
            packet->m_nBodySize = length + 9;
            
            /*send video packet*/
            body = (unsigned char *)packet->m_body;
            memset(body,0,length + 9);
            
            /*key frame*/
            body[0] = 0x27;
            if (type == 5)//此为关键帧
            {
                body[0] = 0x17;
            }
            
            body[1] = 0x01;   /*nal unit*/
            body[2] = 0x00;
            body[3] = 0x00;
            body[4] = 0x00;
            
            body[5] = (length >> 24) & 0xff;
            body[6] = (length >> 16) & 0xff;
            body[7] = (length >>  8) & 0xff;
            body[8] = (length ) & 0xff;
            
            /*copy data*/
            memcpy(&body[9],buffer,length);
            
            packet->m_hasAbsTimestamp = 0;
            packet->m_packetType = RTMP_PACKET_TYPE_VIDEO;
            packet->m_nInfoField2 = self->rtmp->m_stream_id;
            packet->m_nChannel = 0x04;
            packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
            packet->m_nTimeStamp = timeoffset;
            
            if(RTMP_IsConnected(self->rtmp))
            {
                // 调用发送接口
                
                int success = RTMP_SendPacket(self->rtmp,packet,TRUE);
                if(success != 1)
                {
                    NSLog(@"send_rtmp_video fail");
                }
            }
            free(packet);
        }
        else
        {
            NSLog(@"send_rtmp_video RTMP is not ready");
        }
    });
}



@end
