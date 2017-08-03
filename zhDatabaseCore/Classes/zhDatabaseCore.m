//
//  Created by zhanghao on 2017/4/30.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "zhDatabaseCore.h"
#import "zhDatabaseFile.h"
#import "NSString+zhDatabase.h"
#import <objc/runtime.h>
#import "FMDB.h"

#ifndef __OPTIMIZE__
#define NSLog(s, ...) NSLog(@"\n =======> [%@ in line %d] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSLog(...) {}
#endif

@interface zhDatabaseCore ()

@property (nonatomic, strong) NSDictionary<NSString*, FMDatabaseQueue*> *queueDict;

@end

@implementation zhDatabaseCore

+ (instancetype)sharedInstance {
    static zhDatabaseCore *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[zhDatabaseCore alloc] init];
    });
    return _instance;
}

- (FMDatabaseQueue *)dbQueueAtPath:(NSString *)path {
    zhDatabaseFile *file = [zhDatabaseFile fileWithPathName:path];
//    [file skipBackupIcloud];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:file.pathName];
    return queue;
}

- (FMDatabaseQueue *)databaseQueueAtPath:(NSString*)pathName {
    id object = [self.queueDict objectForKey:pathName];
    if (!object) {
        @synchronized ([zhDatabaseCore class]) {
            object = self.queueDict[pathName];
            if (!object) {
                object = [self dbQueueAtPath:pathName];
                NSMutableDictionary *dict = (self.queueDict ? : [NSDictionary dictionary]).mutableCopy;
                [self setObj:object forKey:pathName dict:dict];
                self.queueDict = dict.copy;
            }
        }
    }
    return object;
}

- (void)inDatabase:(id<zhDatabaseProtocol>)object database:(void (^)(FMDatabase *))block {
    NSString *pathName = [object respondsToSelector:@selector(zh_databaseName)] ? object.zh_databaseName : self.databaseNameDefault;
    [[self databaseQueueAtPath:pathName] inDatabase:^(FMDatabase *db) {
        if (!db.hasDateFormatter) {
            [db setDateFormat:[self dateFormatter]];
        }
        block(db);
    }];
}

- (void)inDatabase:(id<zhDatabaseProtocol>)object transaction:(void (^)(FMDatabase *, BOOL *))block {
    NSString *pathName = [object respondsToSelector:@selector(zh_databaseName)] ? object.zh_databaseName : self.databaseNameDefault;
    [[self databaseQueueAtPath:pathName] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (!db.hasDateFormatter) {
            [db setDateFormat:[self dateFormatter]];
        }
        block(db, rollback);
    }];
}

#pragma mark - Tools

- (NSString *)databaseNameDefault { // Documents目录下默认数据库名称
    return @"user_db.sqlite";
}

- (NSArray *)sqliteTypes { // 由于sqlite3接受的数据类型较多，所以只考虑了以下几种常用数据类型
    return @[@"integer", @"text", @"varchar", @"char", @"timestamp", @"blob", @"real"];
}

void printError(NSString *explain, NSString *tableName, NSString *msg, NSString *sql) {
    NSLog(@"error: %@ %@! %@", tableName, explain, msg);
    NSLog(@"sql: %@", sql);
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        formatter.locale = [NSLocale currentLocale];
    });
    return formatter;
}

- (void)setValue:(id)value forKey:(NSString*)key obj:(id)obj {
    if (value != nil) [obj setValue:value forKey:key];
}

- (void)setObj:(id)i forKey:(NSString*)key dict:(NSMutableDictionary *)dict {
    if (i != nil) dict[key] = i;
}

- (void)setLongLong:(long long)i forKey:(NSString*)key dict:(NSMutableDictionary *)dict {
    dict[key] = @(i);
}

-(void)setDouble:(double)i forKey:(NSString*)key dict:(NSMutableDictionary *)dict {
    dict[key] = @(i);
}

- (NSDictionary *)takeColumnTypeWithDescription:(NSString *)columnDescription {
    __block NSInteger i = 0;
    NSMutableArray *words = [NSMutableArray array], *indexes = [NSMutableArray array];
    [columnDescription enumerateSubstringsInRange:NSMakeRange(0, columnDescription.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if ([self.sqliteTypes containsObject:substring.lowercaseString]) {
            [indexes addObject:@(i)];
        }
        [words addObject:substring];
        i++;
    }];
    NSMutableDictionary *columnTypeDict = [NSMutableDictionary dictionary];
    for (NSNumber *number in indexes) {
        id column = [words objectAtIndex:number.integerValue - 1];
        id type = [words objectAtIndex:number.integerValue];
        [self setObj:type forKey:column dict:columnTypeDict];
    }
    return columnTypeDict;
}

#pragma mark - table exists / 是否存在表

- (BOOL)tableExists:(id<zhDatabaseProtocol>)object {
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase * _Nonnull db) {
        result = [db tableExists:object.zh_tableName];
    }];
    return result;
}

#pragma mark - drop table / 删除表

- (BOOL)dropTableWithObject:(id<zhDatabaseProtocol>)object {
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        NSString *sql = [NSString dropTable:object.zh_tableName];
        result = [db executeUpdate:sql];
        if (!result) {
            printError(@"drop failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
    }];
    return result;
}

#pragma mark - rename table / 修改表名

- (BOOL)renameTableWithObject:(id<zhDatabaseProtocol>)object newName:(NSString *)newName {
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        NSString *sql = [NSString renameTable:object.zh_tableName newName:newName];
        result = [db executeUpdate:sql];
        if (!result) {
            printError(@"rename failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
    }];
    return result;
}

#pragma mark - create table / 创建表

- (BOOL)createTableWithObject:(id <zhDatabaseProtocol>)object {
    NSAssert([object respondsToSelector:@selector(zh_columnDescription)],
             @"非映射方法创建表需要实现zh_columnDescription方法!");
    NSDictionary *takeDict = [self takeColumnTypeWithDescription:object.zh_columnDescription];
    NSArray *takeColumn = takeDict.allKeys, *takeTypes = takeDict.allValues;
    return [self createTableWithObject:object description:object.zh_columnDescription allColumn:takeColumn types:takeTypes];
}

- (BOOL)createTableWithObject:(id <zhDatabaseProtocol>)object description:(NSString *)description allColumn:(NSArray *)allColumn types:(NSArray *)allTypes {
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        NSString *sql = [NSString createTable:object.zh_tableName columnDescription:description];
        result = [db executeUpdate:sql];
        if (!result) {
            printError(@"create failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
        
        NSMutableArray *existColumn = [NSMutableArray array];
        FMResultSet *resultSet = [db getTableSchema:object.zh_tableName];
        while (resultSet.next) {
            [existColumn addObject:[resultSet stringForColumn:@"name"]];
        }
        if (existColumn.count != allColumn.count && existColumn.count > 0) {
            NSArray *newColumns = [allColumn filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", existColumn]];
            for (NSString *column in newColumns) {
                NSInteger idx = [allColumn indexOfObject:column];
                NSString *columnType = [allTypes objectAtIndex:idx];
                NSString *alterSql = [NSString alterTable:object.zh_tableName newColumn:column type:columnType];
                if (![db executeUpdate:alterSql]) {
                    result = NO;
                    printError(@"alter failed", object.zh_tableName, db.lastErrorMessage, alterSql);
                }
            }
        }
    }];
    return result;
}

#pragma mark - save / 保存数据

- (BOOL)saveObject:(id<zhDatabaseProtocol>)object values:(NSArray *)values {
    NSString *sql = [NSString replaceIntoTable:object.zh_tableName column:nil columnCount:values.count];
    return [self saveObject:object values:values sql:sql];
}

- (BOOL)saveIgnoreObject:(id<zhDatabaseProtocol>)object values:(NSArray *)values {
    NSString *sql = [NSString ignoreIntoTable:object.zh_tableName column:nil columnCount:values.count];
    return [self saveObject:object values:values sql:sql];
}

- (BOOL)saveObject:(id<zhDatabaseProtocol>)object values:(NSArray *)values sql:(NSString *)sql {
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        NSLog(@"%@", sql);
        result = [db executeUpdate:sql withArgumentsInArray:values];
        if (!result) {
            printError(@"save failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
    }];
    return result;
}

#pragma mark - delete / 删除数据

- (BOOL)deleteObject:(id<zhDatabaseProtocol>)object byCriteriaWithFormat:(NSString *)format, ... {
    NSString *criteria = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        
        criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
        
        va_end(args);
    }
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        NSString *sql = [NSString deleteTable:[object zh_tableName] criteria:criteria];
        result = [db executeUpdate:sql];
        if (!result) {
            printError(@"delete failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
    }];
    return result;
}

- (BOOL)deleteObject:(id<zhDatabaseProtocol>)object sqlWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    
    NSString *sql = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
    
    va_end(args);
    
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
        if (!result) {
            printError(@"(sqlFormat)delete failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
    }];
    return result;
}

#pragma mark - update / 更新数据

- (BOOL)updateObject:(id<zhDatabaseProtocol>)object setKeys:(NSString *)setKeys byCriteria:(NSString *)criteria {
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        NSString *sql = [NSString updateTable:object.zh_tableName set:setKeys criteria:criteria];
        result = [db executeUpdate:sql];
        if (!result) {
            printError(@"update failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
    }];
    return result;
}

- (BOOL)updateObject:(id<zhDatabaseProtocol>)object sqlWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    
    NSString *sql = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
    
    va_end(args);
    
    __block BOOL result = NO;
    [self inDatabase:object database:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
        if (!result) {
            printError(@"(sqlFormat)update failed", object.zh_tableName, db.lastErrorMessage, sql);
        }
    }];
    return result;
}

#pragma mark - select / 查询数据

- (NSArray *)selectObject:(id<zhDatabaseProtocol>)object byCriteriaWithFormat:(NSString *)format, ... {
    NSString *criteria = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        
        criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
        
        va_end(args);
    }
    return [self selectObject:object sql:[NSString selectTable:object.zh_tableName criteria:criteria]];
}

- (NSArray *)selectObject:(id<zhDatabaseProtocol>)object orderKey:(NSString *)orderKey descSort:(BOOL)descSort limitCount:(NSInteger)limitCount byCriteriaWithFormat:(NSString *)format, ... {
    NSString *criteria = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        
        criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
        
        va_end(args);
    }
    return [self selectObject:object sql:[NSString selectTable:object.zh_tableName criteria:criteria orderKey:orderKey limitCount:limitCount isDesc:descSort]];
}

- (NSArray *)selectObject:(id<zhDatabaseProtocol>)object sqlWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    
    NSString *sql = [[NSString alloc] initWithFormat:format locale:NSLocale.currentLocale arguments:args];
    
    va_end(args);
    return [self selectObject:object sql:sql];
}

- (NSArray *)selectObject:(id<zhDatabaseProtocol>)object sql:(NSString *)sql {
    NSMutableArray *dictionaries = [NSMutableArray array];
    [self inDatabase:object database:^(FMDatabase *db) {
        NSMutableArray *columnNames = [NSMutableArray array], *columnTypes = [NSMutableArray array];
        FMResultSet *res = [db getTableSchema:object.zh_tableName];
        while ([res next]) {
            [columnNames addObject:[res stringForColumn:@"name"]];
            [columnTypes addObject:[res stringForColumn:@"type"]];
        }
        [res close];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            NSMutableDictionary *columnDict = [NSMutableDictionary dictionary];
            for (NSInteger i = 0; i < columnNames.count; i++) {
                NSString *name = columnNames[i], *type = columnTypes[i];
                NSString *typeToLower = [type lowercaseStringWithLocale:[NSLocale currentLocale]];
                if ([typeToLower isEqualToString:@"text"] ||
                    [typeToLower rangeOfString:@"varchar"].length ||
                    [typeToLower rangeOfString:@"char"].length) {
                    [self setObj:[resultSet stringForColumn:name] forKey:name dict:columnDict];
                } else if ([typeToLower isEqualToString:@"timestamp"]) {
                    // 时间戳使用NSString类型获取
                    [self setObj:[resultSet stringForColumn:name] forKey:name dict:columnDict];
                    // NSDate类型
//                    [self setObj:[resultSet dateForColumn:name] forKey:name dict:columnDict];
                } else if ([typeToLower isEqualToString:@"blob"]) {
                    [self setObj:[resultSet dataForColumn:name] forKey:name dict:columnDict];
                } else if ([typeToLower isEqualToString:@"real"]) {
                    [self setDouble:[resultSet doubleForColumn:name] forKey:name dict:columnDict];
                } else {
                    // todo:
                    [self setLongLong:[resultSet longLongIntForColumn:name] forKey:name dict:columnDict];
                }
            }
            [dictionaries addObject:columnDict];
            FMDBRelease(columnDict);
        }
        [resultSet close];
    }];
    return dictionaries.copy;
}


/// -------------------------------------------------
#pragma mark - 映射表或添加表字段 / mapColumnCreateTable

/// 自动映射属性并创建
- (BOOL)mapColumnCreateTableWithObject:(id<zhDatabaseProtocol>)object appendPrimaryKeyAndUniqueKeys:(NSString *)description {
    NSMutableString *columnString = [self getColumnDescription:object].mutableCopy;
    if (description && [description.lowercaseString hasPrefix:@"primary"]) {
        [columnString appendFormat:@", %@", description];
    }
    NSArray *properties = [self getProperties:object];
    NSArray *propertyNames = properties.firstObject, *propertyTypes = properties.lastObject;
    return [self createTableWithObject:object description:columnString allColumn:propertyNames types:propertyTypes];
}

#pragma mark - 映射保存 / mapColumnSave

/// 自动映射属性并保存数据
- (BOOL)mapColumnSaveObject:(id<zhDatabaseProtocol>)object {
    NSMutableArray *values = [NSMutableArray array];
    NSArray *propertyNames = [self getProperties:object].firstObject;
    NSMutableString *columnString = [NSMutableString string];
    [propertyNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([object isKindOfClass:[object class]]) { // 必须是NSObject的子类
            id value = [((NSObject *)object) valueForKey:name];
            if (value) {
                [values addObject:value];
            } else {
                [values addObject:[NSNull null]];
            }
            [columnString appendFormat:@"%@", name];
            if (idx != propertyNames.count - 1) {
                [columnString appendString:@", "];
            }
        }
    }];
    
    NSString *sql = [NSString replaceIntoTable:object.zh_tableName column:columnString columnCount:values.count];
    return [self saveObject:object values:values sql:sql];
}

- (BOOL)mapColumnSaveIgnoreObject:(id<zhDatabaseProtocol>)object {
    NSMutableArray *values = [NSMutableArray array];
    NSArray *propertyNames = [self getProperties:object].firstObject;
    NSMutableString *columnString = [NSMutableString string];
    [propertyNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([object isKindOfClass:[object class]]) {
            id value = [((NSObject *)object) valueForKey:name];
            if (value) {
                [values addObject:value];
            } else {
                [values addObject:[NSNull null]];
            }
            [columnString appendFormat:@"%@", name];
            if (idx != propertyNames.count - 1) {
                [columnString appendString:@", "];
            }
        }
    }];
    
    NSString *sql = [NSString ignoreIntoTable:object.zh_tableName column:columnString columnCount:values.count];
    return [self saveObject:object values:values sql:sql];
}

#pragma mark - 映射查询 / mapColumnSelect

- (NSArray *)mapColumnSelectObject:(id<zhDatabaseProtocol>)object sqlWithFormat:(NSString *)format, ... {
    NSString *sql = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        
        sql = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
       
        va_end(args);
    }
    return [self mapColumnSelectObject:object sql:sql];
}

- (NSArray *)mapColumnSelectObject:(id<zhDatabaseProtocol>)object byCriteriaWithFormat:(NSString *)format, ... {
    NSString *criteria = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        
        criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
       
        va_end(args);
    }
    NSString *sql = [NSString selectTable:object.zh_tableName criteria:criteria];
    return [self mapColumnSelectObject:object sql:sql];
}

- (NSArray *)mapColumnSelectObject:(id<zhDatabaseProtocol>)object
                          orderKey:(NSString *)orderKey
                          descSort:(BOOL)descSort
                        limitCount:(NSInteger)limitCount
              byCriteriaWithFormat:(NSString *)format, ... {
    NSString *criteria = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        
        criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args];
        
        va_end(args);
    }
    NSString *sql = [NSString selectTable:object.zh_tableName criteria:criteria orderKey:orderKey limitCount:limitCount isDesc:descSort];
    return [self mapColumnSelectObject:object sql:sql];
}

/// 自动映射属性并查询数据
- (NSArray *)mapColumnSelectObject:(id<zhDatabaseProtocol>)object sql:(NSString *)sql {
    NSMutableArray *models = [NSMutableArray array];
    NSArray *properties = [self getProperties:object];
    NSArray *propertyNames = properties.firstObject, *propertyTypes = properties.lastObject;
    [self inDatabase:object database:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]){
            NSObject *model = [[object.class alloc] init];
            [propertyNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *type = [propertyTypes objectAtIndex:idx];
                id value; // 取值
                if ([type isEqualToString:@"INTEGER"]) {
                    value = @([resultSet intForColumn:name]);
                } else if ([type isEqualToString:@"REAL"]) {
                    value = @([resultSet doubleForColumn:name]);
                } else if ([type isEqualToString:@"TEXT"]) {
                    value = [resultSet stringForColumn:name];
                } else if ([type isEqualToString:@"BLOB"]) {
                    value = [resultSet dataForColumn:name];
                } else if ([type isEqualToString:@"TIMESTAMP"]) {
                    value = [resultSet dateForColumn:name];
                } else {
                    // other to do!
                }
                [self setValue:value forKey:name obj:model];
            }];
            [models addObject:model];
            FMDBRelease(model);
        }
        [resultSet close];
    }];
    return models.copy;
}

#pragma mark - dynamic access

- (NSString *)getColumnDescription:(id<zhDatabaseProtocol>)object {
    NSMutableString *columnString = [NSMutableString string];
    NSArray *properties = [self getProperties:object];
    NSArray *propertyNames = properties.firstObject, *propertyTypes = properties.lastObject;
    [propertyNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *type = [propertyTypes objectAtIndex:idx];
        [columnString appendFormat:@"%@ %@", name, type];
        if (idx != propertyNames.count - 1) {
            [columnString appendString:@", "];
        }
    }];
    return columnString.copy;
}

- (NSArray *)getProperties:(id<zhDatabaseProtocol>)object {
    // 使用数组有序存储属性及对应的类型
    NSMutableArray *propertyNames = [NSMutableArray array];
    NSMutableArray *propertyTypes = [NSMutableArray array];
    // 标记URL的数组
    NSMutableArray *markUrls = [NSMutableArray array];
    // 获取需要忽略的属性
    NSSet *ignoreProperties = [self getIgnoreProperties:object];
    // 获取属性列表
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        // 获取属性名称
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 对应的属性类型编码
        NSString *attributes = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        if ([ignoreProperties containsObject:propertyName]) continue;
        
//        NSLog(@"propertyName - :%@, - propertyAttributes: %@", propertyName, attributes);
        /*
         属性类型对应的类型编码: <https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1>
         - c 基本数据类型     编码类型         对应在SQLite中类型
         int                Ti              INTEGER
         short              Ts              INTEGER
         char               Tc              INTEGER
         long               Tq              INTEGER
         bool               TB              INTEGER
         unsigned           TI              INTEGER
         float              Tf              REAL
         double             Td              REAL
         - OC 类型
         NSInteger          Tq              INTEGER
         NSString           T@"NSString"    TEXT
         NSDate             T@"NSDate"      TEXT
         NSData             T@"NSData"      BLOB
         NSURL              T@"NSURL"       TEXT
         目前仅支持以上属性类型 (NSDictionary:T@"NSDictionary", NSArray:T@"NSArray"不支持多级映射，故不检查数组和字典类型)
         - 由于sqlite3接受的数据类型较多，使用自动映射存储时，只使用以下数据类型!
         REAL: 浮点数字，存储为8-byte IEEE浮点数
         BLOB: 二进制对象
         TEXT: 字符串文本
         INTEGER: 带符号的整型，具体取决有存入数字的范围大小
         */
        if ([attributes hasPrefix:@"Ti"] || [attributes hasPrefix:@"TI"] ||
            [attributes hasPrefix:@"Ts"] || [attributes hasPrefix:@"TS"] ||
            [attributes hasPrefix:@"Tq"] || [attributes hasPrefix:@"TQ"] ||
            [attributes hasPrefix:@"TB"] ||
            [attributes hasPrefix:@"Tc"]) {
            [propertyNames addObject:propertyName];
            [propertyTypes addObject:@"INTEGER"];
        } else if ([attributes hasPrefix:@"Tf"] ||
                   [attributes hasPrefix:@"Td"]) {
            [propertyNames addObject:propertyName];
            [propertyTypes addObject:@"REAL"];
        } else if ([attributes hasPrefix:@"T@\"NSString\""]) {
            [propertyNames addObject:propertyName];
            [propertyTypes addObject:@"TEXT"];
        } else if ([attributes hasPrefix:@"T@\"NSDate\""]) {
            // NSDate存在数据库中的是TEXT类型
            [propertyNames addObject:propertyName];
            [propertyTypes addObject:@"TEXT"];
            //            [propertyTypes addObject:@"TIMESTAMP"];
        } else if ([attributes hasPrefix:@"T@\"NSData\""]) {
            [propertyNames addObject:propertyName];
            [propertyTypes addObject:@"BLOB"];
        } else if ([attributes hasPrefix:@"T@\"NSURL\""]) {
            [propertyNames addObject:propertyName];
            [propertyTypes addObject:@"TEXT"];
            // NSURL存在数据库中的也是TEXT类型
            [markUrls addObject:propertyName];
        } else {
            // other to do!
        }
    }
    free(properties);
    return @[propertyNames, markUrls, propertyTypes];
}

- (NSSet *)getIgnoreProperties:(id<zhDatabaseProtocol>)object {
    // NSObject has some "new" properties (hash、superclass、description、debugDescription) in iOS 8 <http://www.redwindsoftware.com/blog/post/2014/08/20/NSObject-has-some-new-properties-in-iOS-8.aspx>
    // 过滤掉需要忽略的属性和NSObject系统自带属性
    NSMutableSet *mutableSet = [NSMutableSet setWithObjects:@"hash", @"superclass", @"description", @"debugDescription", nil];
    if ([object conformsToProtocol:@protocol(zhDatabaseProtocol)] &&
        [object respondsToSelector:@selector(zh_mapColumnIgnoreKeys)]) {
        id <zhDatabaseProtocol>obj = (id<zhDatabaseProtocol>)object;
        NSSet *ignoreKeys = [NSSet setWithArray:obj.zh_mapColumnIgnoreKeys];
        [mutableSet unionSet:ignoreKeys];
    }
    return mutableSet.copy;
}

@end
