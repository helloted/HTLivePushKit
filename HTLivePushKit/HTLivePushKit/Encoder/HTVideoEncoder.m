//
//  HTVideoEncoder.m
//  VideoCapture
//
//  Created by iMac on 2018/5/18.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import "HTVideoEncoder.h"
#import <VideoToolbox/VideoToolbox.h>

@interface HTVideoEncoder()

@property (nonatomic, strong)NSOperationQueue                       *encodeQueue;
@property (nonatomic, unsafe_unretained)VTCompressionSessionRef     compressionSession;
@property (nonatomic, unsafe_unretained)uint32_t                    timestamp;

@end

@implementation HTVideoEncoder

- (instancetype)init{
    if ([super init]) {
        _encodeQueue = [[NSOperationQueue alloc] init];
        _encodeQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

-(void)openWithConfig:(HTVideoConfig)config{
    self.config = config;
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //创建 video encode session
        // 创建 video encode session
        // 传入视频宽高，编码类型：kCMVideoCodecType_H264
        // 编码回调：vt_compressionSessionCallback，这个回调函数为编码结果回调，编码成功后，会将数据传入此回调中。
        // (__bridge void * _Nullable)(self)：这个参数会被原封不动地传入compressionSessionCallback中，此参数为编码回调同外界通信的唯一参数。
        // &_compressionSession，c语言可以给传入参数赋值。在函数内部会分配内存并初始化_compressionSession。
        
        OSStatus status = VTCompressionSessionCreate(NULL, (int32_t)weakSelf.config.width, (int32_t)weakSelf.config.height, kCMVideoCodecType_H264, NULL, NULL, NULL, compressionSessionCallback, (__bridge void * _Nullable)(weakSelf), &_compressionSession);
        if (status == noErr) {
            // 设置参数
            // ProfileLevel，h264的协议等级，不同的清晰度使用不同的ProfileLevel。
            VTSessionSetProperty(weakSelf.compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
            // 设置码率
            VTSessionSetProperty(weakSelf.compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(self.config.bitrate));
            // 设置实时编码
            VTSessionSetProperty(weakSelf.compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
            // 关闭重排Frame，因为有了B帧（双向预测帧，根据前后的图像计算出本帧）后，编码顺序可能跟显示顺序不同。此参数可以关闭B帧。
            VTSessionSetProperty(weakSelf.compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
            // 关键帧最大间隔，关键帧也就是I帧。此处表示关键帧最大间隔为2s。
            VTSessionSetProperty(weakSelf.compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(self.config.fps * 2));
            // 关于B帧 P帧 和I帧，请参考：http://blog.csdn.net/abcjennifer/article/details/6577934
            
            //参数设置完毕，准备开始，至此初始化完成，随时来数据，随时编码
            status = VTCompressionSessionPrepareToEncodeFrames(weakSelf.compressionSession);
            if (status != noErr) {
                NSLog(@"硬编码compressionSession 准备失败");
            }else{
                NSLog(@"硬编码compressionSession 准备完毕");
            }
        }else{
            NSLog(@"硬编码compressionSession创建失败");
        }
    });
}

static void compressionSessionCallback (void * CM_NULLABLE outputCallbackRefCon,
                                          void * CM_NULLABLE sourceFrameRefCon,
                                          OSStatus status,
                                          VTEncodeInfoFlags infoFlags,
                                          CM_NULLABLE CMSampleBufferRef sampleBuffer ){
    //通过outputCallbackRefCon获取AWHWH264Encoder的对象指针，将编码好的h264数据传出去。
    HTVideoEncoder *encoder = (__bridge HTVideoEncoder *)(outputCallbackRefCon);

    //判断是否编码成功
    if (status != noErr) {
        NSLog(@"encode video frame error 1");
        return;
    }

    //是否数据是完整的
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"encode video frame error 2");
        return;
    }

    //是否是关键帧，关键帧和非关键帧要区分清楚。推流时也要注明。
    BOOL isKeyFrame = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);

    if (isKeyFrame) {
        NSLog(@"====keyFrame");
    }

    //首先获取sps 和pps
    //sps pss 也是h264的一部分，可以认为它们是特别的h264视频帧，保存了h264视频的一些必要信息。
    //没有这部分数据h264视频很难解析出来。
    //数据处理时，sps pps 数据可以作为一个普通h264帧，放在h264视频流的最前面。
    if (!encoder.hasSPSPPS) {
        if (isKeyFrame)
        {
            CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
            size_t sparameterSetSize, sparameterSetCount;
            const uint8_t *sparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
            if (statusCode == noErr)
            {
                size_t pparameterSetSize, pparameterSetCount;
                const uint8_t *pparameterSet;
                OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
                if (statusCode == noErr)
                {
                    NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                    NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                    if (encoder->_delegate)
                    {
                        [encoder->_delegate videoEncoderResultSPS:[encoder naluDataWrapper:sps] pps:[encoder naluDataWrapper:pps]];
                    }
                }
            }
        }
    }

    //获取真正的视频帧数据
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t blockDataLen;
    uint8_t *blockData;
    status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &blockDataLen, (char **)&blockData);
    if (status == noErr) {
        size_t currReadPos = 0;
        //一般情况下都是只有1帧，在最开始编码的时候有2帧，取最后一帧
        while (currReadPos < blockDataLen - 4) {
            uint32_t naluLen = 0;
            memcpy(&naluLen, blockData + currReadPos, 4);
            naluLen = CFSwapInt32BigToHost(naluLen);

            //naluData 即为一帧h264数据。
            //如果保存到文件中，需要将此数据前加上 [0 0 0 1] 4个字节，按顺序写入到h264文件中。
            //如果推流，需要将此数据前加上4个字节表示数据长度的数字，此数据需转为大端字节序。
            //关于大端和小端模式，请参考此网址：http://blog.csdn.net/hackbuteer1/article/details/7722667
            NSData *naluData = [NSData dataWithBytes:blockData+currReadPos+4 length:naluLen];
            currReadPos += (4+naluLen);
            
            if (encoder.delegate && [encoder.delegate respondsToSelector:@selector(videoEncoderResultNALUData:keyFrame:)]) {
                [encoder.delegate videoEncoderResultNALUData:[encoder naluDataWrapper:naluData] keyFrame:isKeyFrame];
            }
        }
    }else{
        NSLog(@"got h264 data failed");
    }
}

- (NSData *)naluDataWrapper:(NSData *)data{
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendData:ByteHeader];
    [result appendData:data];
    return result;
}

- (void)encodeVideoWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CFRetain(sampleBuffer);
    __weak typeof(self) weakSelf = self;
    [_encodeQueue addOperationWithBlock:^{
        [weakSelf handleSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
    }];
}

- (void)handleSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (!_compressionSession) {
        return;
    }
    //时间戳
    uint32_t ptsMs = self.timestamp + 1; //self.vFrameCount++ * 1000.f / self.videoConfig.fps;
    
    // 采集默认的帧率是25FPS，所以时间戳是1000/25
    self.timestamp += 40;
    
    CMTime pts = CMTimeMake(ptsMs, 1000);
    CVImageBufferRef pixelBuf = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //硬编码主要其实就这一句。将携带NV12数据的PixelBuf送到硬编码器中，进行编码。
    OSStatus status = VTCompressionSessionEncodeFrame(_compressionSession, pixelBuf, pts, kCMTimeInvalid, NULL, pixelBuf, NULL);
    
    if (status != noErr) {
        NSLog(@"encode video frame error");
    }
}


@end
