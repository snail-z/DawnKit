//
//  ChildrenInfos.m
//  FMDBManagerDemo
//
//  Created by zhanghao on 16/11/16.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import "ChildrenInfos.h"

@implementation ChildrenInfos

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

+ (instancetype)infoWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (NSArray *)infoFrom:(NSArray *)array {
    NSMutableArray *infos = @[].mutableCopy;
    for (NSDictionary *dict in array) {
        ChildrenInfos *info = [ChildrenInfos infoWithDict:dict];
        [infos addObject:info];
    }
    return infos;
}

+ (NSArray *)childrenList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ChildrenInfos" ofType:@"plist"];
    return [self infoFrom:[[NSArray alloc] initWithContentsOfFile:path]];
}

@end
