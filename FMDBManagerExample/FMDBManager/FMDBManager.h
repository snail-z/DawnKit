//
//  FMDatabaseManager.h
//  <https://github.com/snail-z/FMDBManager.git>
//
//  Created by zhanghao on 16/5/1.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBAssistant.h"

@interface FMDBManager : NSObject

/** 创建表
*/
+ (BOOL)createTableWithName:(NSString *)tableName columns:(NSString *)columns;

/** 创建表并设置PrimaryKey、UNIQUE
*/
+ (BOOL)createTableWithName:(NSString *)tableName columns:(NSString *)columns pk:(NSString *)pk unique:(NSString *)unique;

/** 插入数据
*/
+ (BOOL)insertInto:(NSString *)tableName columns:(NSString *)columns values:(NSArray *)values;

/** 若该数据不存在则插入，存在则忽略（仅对UNIQUE约束字段起作用）
*/
+ (BOOL)insertIgnore:(NSString *)tableName columns:(NSString *)columns values:(NSArray *)values;

/** 若该数据不存在则插入，存在则更新（仅对UNIQUE约束的字段起作用）
*/
+ (BOOL)insertReplace:(NSString *)tableName columns:(NSString *)columns values:(NSArray *)values;

/** 删除数据
*/
+ (BOOL)deleteFrom:(NSString *)tableName where:(NSString *)where;

/** 修改数据
*/
+ (BOOL)update:(NSString *)tableName set:(NSString *)arguments where:(NSString *)where;

/** 查找全部
*/
+ (NSArray *)selectAllFrom:(NSString *)tableName;

/** 根据条件查找
*/
+ (NSArray *)selectResultsFrom:(NSString *)tableName where:(NSString *)where;

/** 查找单条
*/
+ (NSDictionary *)selectSingleFrom:(NSString *)tableName where:(NSString *)where;

/** 升序查询所有
*/
+ (NSArray *)selectResultsAscendingFrom:(NSString *)tableName orderBy:(NSString *)orderBy;

/** 降序查询所有
*/
+ (NSArray *)selectResultsDescendingFrom:(NSString *)tableName orderBy:(NSString *)orderBy;

/** 按条件升序查询n条
*/
+ (NSArray *)selectResultsAscendingFrom:(NSString *)tableName where:(NSString *)where orderBy:(NSString *)orderBy limit:(NSInteger)limit;

/** 按条件降序查询n条
*/
+ (NSArray *)selectResultsDescendingFrom:(NSString *)tableName where:(NSString *)where orderBy:(NSString *)orderBy limit:(NSInteger)limit;

/** 数据库中是否存在该表
*/
+ (BOOL)isExistTable:(NSString *)tableName;

/** 清空表
*/
+ (BOOL)clearTable:(NSString *)tableName;

@end
