//
//  NSString+SnailDatabase.h
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/4/9.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SnailDatabase)

+ (NSString *)createTable:(NSString *)tableName columnDescription:(NSString *)columns;

+ (NSString *)alterTable:(NSString *)tableName newColumn:(NSString *)column type:(NSString *)columnType;

+ (NSString *)dropTable:(NSString *)tableName;

+ (NSString *)renameTable:(NSString *)tableName newName:(NSString *)newName;

+ (NSString *)replaceIntoTable:(NSString *)tableName column:(nullable NSString *)column columnCount:(NSUInteger)columnCount;

+ (NSString *)ignoreIntoTable:(NSString *)tableName column:(nullable NSString *)column columnCount:(NSUInteger)columnCount;

+ (NSString *)deleteTable:(NSString *)tableName criteria:(nullable NSString *)criteria;

+ (NSString *)updateTable:(NSString *)tableName set:(NSString *)s criteria:(NSString *)criteria;

+ (NSString *)selectTable:(NSString *)tableName criteria:(nullable NSString *)criteria;

+ (NSString *)selectTable:(NSString *)tableName criteria:(nullable NSString *)criteria orderKey:(nullable NSString *)key limitCount:(NSInteger)limitCount isDesc:(BOOL)isDesc;

+ (NSString *)selectTable:(NSString *)tableName criteria:(NSString *)criteria orderKey:(NSString *)key sort:(NSString *)sort count:(NSInteger)limitCount;
@end

NS_ASSUME_NONNULL_END
