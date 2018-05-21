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

- (void)connectWithURL:(NSString *)url;


@end
