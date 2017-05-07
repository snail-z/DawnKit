//
//  MyModel2.m
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/5/6.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "MyModel2.h"

@implementation MyModel2

- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self sl_createTable]; // 非映射方法
        });
    }
    return self;
}

- (void)writeInfos {
    NSArray *cities = @[@"北京", @"上海", @"广州", @"深圳", @"杭州"];
    for (NSInteger i = 0; i < 5; i++) {
        self.zID = i + 1;
        self.zInteger = i + 100;
        self.zString = [NSString stringWithFormat:@"zString%lu", i];
        self.zEndTime = [NSString stringWithFormat:@"晚%lu点", 12 - i];
        self.zSubway = cities[i];
        
        NSArray *values = @[@(self.zID),
                            @(self.zInteger),
                            self.zString,
                            self.zEndTime,
                            self.zSubway,
                            [NSNull null],
                            self.zSubway];
        
        [self sl_saveValues:values];
    }
}

- (void)selectInfos {
    NSArray *array1 = [self sl_ascendingSelectOrderKey:@"zID"
                                            limitCount:3
                                  byCriteriaWithFormat:nil];
    NSLog(@"array1 : %@", array1);
    
    
    NSArray *array2 = [self sl_descendingSelectOrderKey:@"zID"
                                             limitCount:3
                                   byCriteriaWithFormat:@"zInteger < 104"];
    NSLog(@"array2 : %@", array2);
}

#pragma mark - SnailDatabaseProtocol

- (NSString *)sl_tableName {
    return @"MyModel2_table";
}

- (NSString *)sl_databaseName {
    return @"example2.sqlite";
}

- (NSString *)sl_columnDescription {
    return @""
    "zID integer not null, "
    "zInteger integer not null, "
    "zString text not null, "
    "zEndTime varchar(64), "
    "zSubway varchar(256), "
    "zTime TIMESTAMP NOT NULL DEFAULT (datetime('now','localtime')), "
    "zSubway varchar(256), "
    "primary key(zID) " ;
}

@end
