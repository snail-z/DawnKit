# FMDBManager

* 基于[FMDB](https://github.com/ccgus/fmdb)进行的简单封装，减少sql语句编写，可自动判断表中是否有新增字段并进行更新，提供多种查询方法；

* 具体方法如下：

 ``` objc
 
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

 ```


* 详细使用方法请参见Demo

####TODO: 

1. 将表更新放在插入数据时进行判断，更加简化代码方便使用
2. 增加更多的删除和更新操作
