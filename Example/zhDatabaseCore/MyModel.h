//
//  MyModel.h
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/4/26.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zhDatabaseProtocol.h"
#import "NSObject+zhDatabase.h" // 引入"NSObject+SnailDatabase.h"

@interface MyModel : NSObject <zhDatabaseProtocol> // 必须遵守协议

@property (nonatomic, assign) NSInteger songID;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *singerName;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSString *lyrics;
@property (nonatomic, assign) BOOL isRock;
@property (nonatomic, strong) NSURL *songUrl;
@property (nonatomic, assign) NSInteger myID;
@property (nonatomic, strong) NSDate *myTime;
@property (nonatomic, strong) NSData *myData;

@property (nonatomic, assign) float myFloat;
@property (nonatomic, assign) int myInt;
@property (nonatomic, assign) double myDouble;
@property (nonatomic, assign) BOOL myBOOL;
@property (nonatomic, assign) unsigned myUnsigned;
@property (nonatomic, assign) long myLong;
@property (nonatomic, assign) long long myLongLong;

@property (nonatomic, assign) uint64_t myUint64_t;
@property (nonatomic, assign) uint32_t myUint32_t;
@property (nonatomic, assign) int32_t myInt32_t;

@property (nonatomic, assign) CGFloat myCGFloat;
@property (nonatomic, assign) NSTimeInterval myInterval;
@property (nonatomic, assign) NSInteger myNSInteger;

@property (nonatomic, strong) NSDate *myNSDate;
@property (nonatomic, strong) NSData *myNSData;
@property (nonatomic, strong) NSURL *myNSURL;
@property (nonatomic, strong) NSString *myNSString;

@property (nonatomic, strong) NSDate *myWeek;
@property (nonatomic, strong) NSData *myInfo;

/// 打酱油的☟
@property (nonatomic, assign) CGSize mySize;
@property (nonatomic, strong) NSArray *myArray;
@property (nonatomic, strong) NSDictionary *myDictionary;

@end
