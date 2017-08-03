//
//  Created by zhanghao on 2017/4/9.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol zhDatabaseProtocol <NSObject>

@required
/**
 ///-------------
 /// 必须实现的方法!
 ///-------------
 - zh_tableName: 表名称
 */
- (nonnull NSString *)zh_tableName;

@optional
/** 
 @brief 在Documents目录下配置数据库路径及名称
 - 该方法不实现的话，默认在Documents目录下创建user_db.sqlite(默认数据库名称)文件
 */
- (nonnull NSString *)zh_databaseName;

/**
 @brief 手动设置表中对应的column字段，若不实现该方法则自动映射属性到数据库(属性名称 <=> 字段名称)
 - sl_columnDescription: 每个表中对应的column(标准sql语句)
 */
/* - sqlite数据类型: [@"integer", @"text", @"varchar", @"char", @"timestamp", @"blob", @"real"];
 实现该方法时注意设置的column字段名不要与以上关键字相同）由于sqlite3接受的数据类型较多，目前仅支持以上几种常用数据类型！
 ///-------------------------------
 /// 不使用自动映射属性时，必须实现该方法!
 ///-------------------------------
 */
- (nonnull NSString *)zh_columnDescription;

/**
 @brief 忽略某些属性不需要在数据库中出现的字段，实现这个方法并在数组中返回忽略的property名称(自动映射属性时起作用!)
 - NSArray *ignoreKeys = @[@"hash", @"superclass", @"description", @"debugDescription"];
 */
- (NSArray<NSString *> *)zh_mapColumnIgnoreKeys;
/* 注意:
 `- (nonnull NSString *)sl_columnDescription;`与
 `- (NSArray *)sl_mapColumnIgnoreKeys;`不应该同时实现!
 */

@end

NS_ASSUME_NONNULL_END
