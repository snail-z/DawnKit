//
//  MyModel2.h
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/5/6.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zhDatabaseProtocol.h"
#import "NSObject+zhDatabase.h"

@interface MyModel2 : NSObject <zhDatabaseProtocol>

@property (nonatomic, assign) NSInteger zID;
@property (nonatomic, assign) NSInteger zInteger;
@property (nonatomic, strong) NSString *zString;
@property (nonatomic, strong) NSString *zEndTime;
@property (nonatomic, strong) NSString *zSubway;

- (void)writeInfos;
- (void)selectInfos;

@end
