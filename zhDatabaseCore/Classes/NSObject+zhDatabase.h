//
//  Created by zhanghao on 2017/4/19.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zhDatabaseCore.h"

NS_ASSUME_NONNULL_BEGIN

/* -------------------------------------------------------------
 该类别是对zhDatabaseCore类进一步封装，可直接使用zhDatabaseCore类中的方法
 - 只有遵守zhDatabaseProtocol协议的类，才能调用该类别中的方法 !!!
-------------------------------------------------------------- */
@interface NSObject (zhDatabase)

/// 是否存在表
- (BOOL)zh_tableExists;

/// 删除表
- (BOOL)zh_dropTable;

/// 修改表名
- (BOOL)zh_tableRename:(NSString *)newName;

/// 创建表
- (BOOL)zh_createTable;

/// 插入数据, 需要按字段顺序设置values, 空值用[NSNull null]代替
- (BOOL)zh_saveValues:(NSArray *)values;

/// 忽略插入相同数据
- (BOOL)zh_saveIgnoreValues:(NSArray *)values;

/// 删除数据（byCriteria传入nil时，清空表中所有数据）
- (BOOL)zh_deleteByCriteriaWithFormat:(nullable NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 手写sql删除语句
/* - example:
 NSString *sql = @"DELETE FROM table_name WHERE songID > '5' and songID < '9'";
 */
- (BOOL)zh_deleteSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 更新数据
/* - example:
 [self zh_updateKeys:[NSString stringWithFormat:@"songName = '%@' , singerName = '%@'", @"父亲写的散文诗", @"许飞"]
 byCriteria:[NSString stringWithFormat:@"id = '%d' and status = '%d'", 5, 9]];
 
 - updateKeys : 使用 , 连接
 - byCriteria : 使用 and 连接
 */
- (BOOL)zh_updateKeys:(NSString *)setKeys byCriteria:(NSString *)criteria;

// 手写sql更新语句
/* - example:
 NSString *sql = @"UPDATE table_name SET singerName = 'newName' WHERE songID = '7'";
 */
- (BOOL)zh_updateSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

// 查询数据（byCriteria传入nil时，查询表中所有数据）
- (NSArray *)zh_selectByCriteriaWithFormat:(nullable NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

// 手写sql查询语句
/* - example:
 NSString *sql = @"SELECT * FROM table_name WHERE songID > '7'";
 */
- (NSArray *)zh_selectSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 根据条件降序查询数据
/* - example:
 [self zh_descendingSelectOrderKey:@"songID"
 limitCount:3
 byCriteriaWithFormat:@"singerID > 7"]
 
 - orderKey  : 根据字段songID降序查询
 - limitCount: 限制查询3条数据
 - byCriteria: 查询条件(singerID > 7)
 */
- (NSArray *)zh_descendingSelectOrderKey:(nullable NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(nullable NSString *)format, ... ;

/// 根据条件升序查询数据
- (NSArray *)zh_ascendingSelectOrderKey:(nullable NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(nullable NSString *)format, ... ;


#pragma mark - Auto Mapping Method / 自动映射方法(以下方法适用于当表中数据是自动映射存储的!)
/*
 - 由于sqlite3接受的数据类型较多，使用自动映射存储时，只使用以下数据类型存入数据库
 REAL: 浮点数字，存储为8-byte IEEE浮点数
 BLOB: 二进制对象
 TEXT: 字符串文本
 INTEGER: 带符号的整型，具体取决有存入数字的范围大小
 
 - 下面是支持的属性类型和存入数据库中的类型对照:
 属性类型            对应在SQLite中类型
 ⎡ int                INTEGER
 ⎢ short              INTEGER
 ⎢ char               INTEGER
 ⎢ long               INTEGER
 ⎢ bool               INTEGER
 ⎢ unsigned           INTEGER
 ⎢ float              REAL
 ⎢ double             REAL
 ⎢
 ⎢ NSInteger          INTEGER
 ⎢ NSString           TEXT
 ⎢ NSDate             TEXT
 ⎢ NSData             BLOB
 ⎣ NSURL              TEXT
 目前仅支持以上属性类型 (由于不支持多级映射，故不检查数组NSArray和字典NSDictionary类型)
 */

/// 创建表并设置主键primary key和unique约束字段(自动映射object类中的属性)
/* - example:
 NSString *description = @"primary key(name), unique(name1, name2)";
 */
- (BOOL)zh_mapColumnCreateTableWithPrimaryKeyAndUniqueKeys:(nullable NSString *)description;

/// 保存数据（自动映射下方法）
- (BOOL)zh_mapColumnSave;

/// 保存数据（有重复记录就会忽略）
- (BOOL)zh_mapColumnIgnoreSave;

/// 查询数据（byCriteria传入nil时，查询全部数据）
- (NSArray *)zh_mapColumnSelectByCriteriaWithFormat:(nullable NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 条件查询（自动映射下方法）
- (NSArray *)zh_mapColumnSelectOrderKey:(nullable NSString *)orderKey descSort:(BOOL)descSort limitCount:(NSInteger)limitCount byCriteriaWithFormat:(nullable NSString *)format, ... ;

/// 手写sql查询语句（自动映射下方法）
/* - example:
 NSString *sql = @"SELECT * FROM table_name WHERE songID > '7'";
 */
- (NSArray *)zh_mapColumnSelectSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

NS_ASSUME_NONNULL_END
