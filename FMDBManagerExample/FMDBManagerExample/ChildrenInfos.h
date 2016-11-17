//
//  ChildrenInfos.h
//  FMDBManagerDemo
//
//  Created by zhanghao on 16/11/16.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChildrenInfos : NSObject

@property (nonatomic, assign) NSInteger childID;
@property (nonatomic, assign) NSInteger childAge;
@property (nonatomic, strong) NSString *childName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *parentsMobile;
@property (nonatomic, strong) NSString *love;

+ (instancetype)infoWithDict:(NSDictionary *)dict;
+ (NSArray *)infoFrom:(NSArray *)array;
+ (NSArray *)childrenList;

@end
