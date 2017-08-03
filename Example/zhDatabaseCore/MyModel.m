//
//  MyModel.m
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/4/26.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "MyModel.h"

@implementation MyModel

#pragma mark - SnailDatabaseProtocol

- (NSString *)zh_tableName { // 必须实现的方法
    return @"my_model_table";
}

- (NSString *)sl_databaseName {
    return @"example1.sqlite";
}

@end
