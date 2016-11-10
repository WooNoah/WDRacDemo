//
//  WDLoginUnit.h
//  WDRacDemo
//
//  Created by tb on 16/11/10.
//  Copyright © 2016年 com.tb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WDLoginUnit : NSObject

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(void(^)(BOOL))completeBlock;

@end
