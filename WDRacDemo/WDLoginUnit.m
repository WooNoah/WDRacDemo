//
//  WDLoginUnit.m
//  WDRacDemo
//
//  Created by tb on 16/11/10.
//  Copyright © 2016年 com.tb. All rights reserved.
//

#import "WDLoginUnit.h"

@implementation WDLoginUnit

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(void (^)(BOOL))completeBlock {
    
    double delay = 2.f;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay*NSEC_PER_SEC));
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        BOOL whether = [username isEqualToString:@"username"] && [password isEqualToString:@"password"];
        completeBlock(whether);
    });
}

@end
