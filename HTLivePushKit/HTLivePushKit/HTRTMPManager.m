//
//  HTRTMPManager.m
//  HTLivePushKit
//
//  Created by iMac on 2018/5/21.
//  Copyright © 2018年 HelloTed. All rights reserved.
//

#import "HTRTMPManager.h"

@implementation HTRTMPManager

+ (instancetype)shareInstance
{
    static HTRTMPManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}


@end
