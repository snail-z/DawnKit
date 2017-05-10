# SnailDatabase

* 基于[FMDB](https://github.com/ccgus/fmdb)进行的简单封装，减少sql语句编写，可自动判断表中是否有新增字段并进行更新，提供多种查询方法；

* 具体方法如下：
 
``` objc
/// 是否存在表
- (BOOL)sl_tableExists;

/// 删除表
- (BOOL)sl_dropTable;

/// 修改表名
- (BOOL)sl_tableRename:(NSString *)newName;

/// 创建表
- (BOOL)sl_createTable;

/// 插入数据, 需要按字段顺序设置values, 空值用[NSNull null]代替
- (BOOL)sl_saveValues:(NSArray *)values;

/// 忽略插入相同数据
- (BOOL)sl_saveIgnoreValues:(NSArray *)values;

/// 删除数据（byCriteria传入nil时，清空表中所有数据）
- (BOOL)sl_deleteByCriteriaWithFormat:(nullable NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 手写sql删除语句
/* - example:
 NSString *sql = @"DELETE FROM table_name WHERE songID > '5' and songID < '9'";
 */
- (BOOL)sl_deleteSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 更新数据
/* - example:
 [self sl_updateKeys:[NSString stringWithFormat:@"songName = '%@' , singerName = '%@'", @"父亲写的散文诗", @"许飞"]
 byCriteria:[NSString stringWithFormat:@"id = '%d' and status = '%d'", 5, 9]];
 
 - updateKeys : 使用 , 连接
 - byCriteria : 使用 and 连接
 */
- (BOOL)sl_updateKeys:(NSString *)setKeys byCriteria:(NSString *)criteria;

// 手写sql更新语句
/* - example:
 NSString *sql = @"UPDATE table_name SET singerName = 'newName' WHERE songID = '7'";
 */
- (BOOL)sl_updateSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

// 查询数据（byCriteria传入nil时，查询表中所有数据）
- (NSArray *)sl_selectByCriteriaWithFormat:(nullable NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

// 手写sql查询语句
/* - example:
 NSString *sql = @"SELECT * FROM table_name WHERE songID > '7'";
 */
- (NSArray *)sl_selectSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 根据条件降序查询数据
/* - example:
 [self sl_descendingSelectOrderKey:@"songID"
 limitCount:3
 byCriteriaWithFormat:@"singerID > 7"]
 
 - orderKey  : 根据字段songID降序查询
 - limitCount: 限制查询3条数据
 - byCriteria: 查询条件(singerID > 7)
 */
- (NSArray *)sl_descendingSelectOrderKey:(nullable NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(nullable NSString *)format, ... ;

/// 根据条件升序查询数据
- (NSArray *)sl_ascendingSelectOrderKey:(nullable NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(nullable NSString *)format, ... ;


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
- (BOOL)sl_mapColumnCreateTableWithPrimaryKeyAndUniqueKeys:(nullable NSString *)description;

/// 保存数据（自动映射下方法）
- (BOOL)sl_mapColumnSave;

/// 保存数据（有重复记录就会忽略）
- (BOOL)sl_mapColumnIgnoreSave;

/// 查询数据（byCriteria传入nil时，查询全部数据）
- (NSArray *)sl_mapColumnSelectByCriteriaWithFormat:(nullable NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 条件查询（自动映射下方法）
- (NSArray *)sl_mapColumnSelectOrderKey:(nullable NSString *)orderKey descSort:(BOOL)descSort limitCount:(NSInteger)limitCount byCriteriaWithFormat:(nullable NSString *)format, ... ;

/// 手写sql查询语句（自动映射下方法）
/* - example:
 NSString *sql = @"SELECT * FROM table_name WHERE songID > '7'";
 */
- (NSArray *)sl_mapColumnSelectSqlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
```

* SnailDatabaseProtocol协议
```objc
@protocol SnailDatabaseProtocol <NSObject>

@required
/**
 ///-------------
 /// 必须实现的方法!
 ///-------------
 - sl_tableName: 表名称
 */
- (nonnull NSString *)sl_tableName;

@optional
/** 
 @brief 在Documents目录下配置数据库路径及名称
 - 该方法不实现的话，默认在Documents目录下创建user_db.sqlite(默认数据库名称)文件
 */
- (nonnull NSString *)sl_databaseName;

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
- (nonnull NSString *)sl_columnDescription;

/**
 @brief 忽略某些属性不需要在数据库中出现的字段，实现这个方法并在数组中返回忽略的property名称(自动映射属性时起作用!)
 - NSArray *ignoreKeys = @[@"hash", @"superclass", @"description", @"debugDescription"];
 */
- (NSArray<NSString *> *)sl_mapColumnIgnoreKeys;
/* 注意:
 `- (nonnull NSString *)sl_columnDescription;`与
 `- (NSArray *)sl_mapColumnIgnoreKeys;`不应该同时实现!
 */
```
* 更多详细的使用方法请参见Demo

