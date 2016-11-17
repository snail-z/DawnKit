//
//  FMDatabaseManager.m
//  <https://github.com/snail-z/FMDBManager.git>
//
//  Created by zhanghao on 16/5/1.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import "FMDBManager.h"

@implementation FMDBManager

#pragma mark - get table column name or type

+ (NSArray *)getColumnsName:(NSString *)tableName {
    return [self getColumns:tableName columnOrTypes:@"name"];
}

+ (NSArray *)getColumnsType:(NSString *)tableName {
    return [self getColumns:tableName columnOrTypes:@"type"];
}

+ (NSArray *)getColumns:(NSString*)tableName columnOrTypes:(NSString *)string {
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    NSMutableArray *columns = [NSMutableArray array];
    [assistant.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:string];
            [columns addObject:column];
        }
        [resultSet close];
    }];
    return [columns copy];
}

#pragma mark - utility methods

+ (BOOL)isBlankString:(NSString *)string {
    if (!string) return YES;
    if ([string isKindOfClass:[NSNull class]]) return YES;
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) return YES;
    return NO;
}

+ (NSString *)lastCharacterDele:(NSString *)string {
    if ([self isBlankString:string]) return @"";
    return [string substringToIndex:string.length - 1];
}

+ (void)setObj:(id)i forKey:(NSString*)key dict:(NSMutableDictionary *)dict {
    if (i != nil) dict[key] = i;
}

+ (void)setLongLong:(long long)i forKey:(NSString*)key dict:(NSMutableDictionary *)dict {
    dict[key] = @(i);
}

+ (NSArray *)collectColumns:(NSString *)string isCol:(BOOL)isCol {
    NSMutableArray *words = @[].mutableCopy;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [words addObject:substring];
    }];
    NSMutableArray *columns = @[].mutableCopy, *types = @[].mutableCopy;
    [words enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 2 == 0) {
            [columns addObject:obj];
        } else {
            [types addObject:obj];
        }
    }];
    if ([self lastError:types columns:columns details:string]) {
        return nil;
    }
    if (isCol) {
        return [columns copy];
    } else {
        return [types copy];
    }
}

+ (BOOL)lastError:(NSArray *)types columns:(NSArray *)columns details:(NSString *)details {
    if (types.count != columns.count) {
        FMDBLog(@"(Error) The field type and field does not match: (%@)", details);
        return YES;
    }
    return NO;
}

#pragma mark - create table

+ (BOOL)createTableWithName:(NSString *)tableName columns:(NSString *)columns {
    return [self createTableWithName:tableName columns:columns pk:nil unique:nil];
}

+ (BOOL)createTableWithName:(NSString *)tableName
                    columns:(NSString *)columns
                         pk:(NSString *)pk
                     unique:(NSString *)unique {
    if ([self isBlankString:pk]) {
        pk = @"ids INTEGER primary key autoincrement, ";
    }
    if ([self isBlankString:unique]) {
        unique = @"";
    } else {
        unique = [NSString stringWithFormat:@", UNIQUE(%@)", unique];
    }
    NSArray *existingColumn = [self getColumnsName:tableName];
    __block BOOL res = YES;
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    [assistant.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *exsql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@%@%@);", tableName, pk, columns, unique];
        if (shouldOutputSql) {
            FMDBLog(@"execute SQL:%@", exsql);
        }
        if (![db executeUpdate:exsql]) {
            res = NO;
            FMDBLog(@"(Error)%@ Create Failed: %@", tableName, [db lastErrorMessage]);
            return;
        }
        if (!existingColumn.count) return;
        NSArray *resultColunms = [self collectColumns:columns isCol:YES];
        if (!resultColunms) return;
        NSArray *resultTypes = [self collectColumns:columns isCol:NO];;
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", existingColumn];
        NSArray *resultArray = [resultColunms filteredArrayUsingPredicate:filterPredicate];
        for (NSString *obj in resultArray) {
            NSInteger index = [resultColunms indexOfObject:obj];
            NSString *idxType = [resultTypes objectAtIndex:index];
            NSString *fieldSql = [NSString stringWithFormat:@"%@ %@", obj, idxType];
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ", tableName, fieldSql];
            if (shouldOutputSql) {
                FMDBLog(@"execute SQL:%@", sql);
            }
            if (![db executeUpdate:sql]) {
                res = NO;
                *rollback = YES;
                FMDBLog(@"(Error)%@ Alter Failed: %@", tableName, [db lastErrorMessage]);
                return ;
            }
        }
    }];
    return res;
}

#pragma mark - data insert

+ (BOOL)insertInto:(NSString *)tableName
           columns:(NSString *)columns
            values:(NSArray *)values {
    return [self insertInto:tableName columns:columns values:values type:1];
}

+ (BOOL)insertIgnore:(NSString *)tableName
             columns:(NSString *)columns
              values:(NSArray *)values {
    return [self insertInto:tableName columns:columns values:values type:2];
}

+ (BOOL)insertReplace:(NSString *)tableName
              columns:(NSString *)columns
               values:(NSArray *)values {
    return [self insertInto:tableName columns:columns values:values type:3];
}

+ (BOOL)insertInto:(NSString *)tableName
           columns:(NSString *)columns
            values:(NSArray *)values
              type:(NSInteger)intoType {
    NSMutableString *string = [NSMutableString string];
    NSMutableArray *insertValues = @[].mutableCopy;
    for (int i = 0; i < values.count; i++) {
        id s = [values objectAtIndex:i];
        if (!s) s = @"";
        [insertValues addObject:s];
        [string appendString:@"?,"];
    }
    NSString *valueString = [self lastCharacterDele:string];
    NSMutableString *intoString = [NSMutableString string];
    switch (intoType) {
        case 1:
            [intoString appendString:@"INSERT INTO"];
            break;
        case 2:
            [intoString appendString:@"INSERT OR IGNORE INTO"];
            break;
        case 3:
            [intoString appendString:@"INSERT OR REPLACE INTO"];
            break;
        default:
            break;
    }
    __block BOOL res = NO;
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    [assistant.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *exsql = [NSString stringWithFormat:@"%@ %@(%@) VALUES (%@);", intoString, tableName, columns, valueString];
        if (shouldOutputSql) {
            FMDBLog(@"Execute SQL:%@", exsql);
        }
        res = [db executeUpdate:exsql withArgumentsInArray:insertValues];
        if (!res) {
            FMDBLog(@"(Error)%@ Insert Failed: %@", tableName, [db lastErrorMessage]);
            return;
        }
    }];
    return res;
}


#pragma mark - data delete

+ (BOOL)deleteFrom:(NSString *)tableName
             where:(NSString *)where {
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    __block BOOL res = NO;
    [assistant.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *exsql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ ",tableName, where];
        if (shouldOutputSql) {
            FMDBLog(@"Execute SQL:%@", exsql);
        }
        res = [db executeUpdate:exsql];
        if (!res) {
            FMDBLog(@"(Error)%@ Delete Failed: %@", tableName, [db lastErrorMessage]);
            return;
        }
    }];
    return res;
}

#pragma mark - data update

+ (BOOL)update:(NSString *)tableName
           set:(NSString *)arguments
         where:(NSString *)where {
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    __block BOOL res = NO;
    [assistant.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *exsql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@;", tableName, arguments, where];
        if (shouldOutputSql) {
            FMDBLog(@"Execute SQL:%@", exsql);
        }
        res = [db executeUpdate:exsql];
        if (!res) {
            FMDBLog(@"(Error)%@ Update Failed: %@", tableName, [db lastErrorMessage]);
        }
    }];
    return res;
}

#pragma mark - data select

// select all data
+ (NSArray *)selectAllFrom:(NSString *)tableName {
    return [self selectResultsFrom:tableName statement:[NSString stringWithFormat:@"SELECT * FROM %@", tableName]];
}

+ (NSArray *)selectResultsFrom:(NSString *)tableName where:(NSString *)where {
    return [self selectResultsFrom:tableName statement:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, where]];
}

+ (NSArray *)selectResultsFrom:(NSString *)tableName
                     statement:(NSString *)statement {
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    NSMutableArray *objs = [NSMutableArray array];
    NSArray *columnNames = [self getColumnsName:tableName];
    NSArray *columnTypes = [self getColumnsType:tableName];
    [assistant.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:statement];
        if (shouldOutputSql) {
            FMDBLog(@"Execute SQL:%@", statement);
        }
        while ([resultSet next]) {
            NSMutableDictionary *dicColumn = [NSMutableDictionary dictionary];
            for (int i = 0; i < columnNames.count; i++) {
                NSString *columnName = [columnNames objectAtIndex:i];
                NSString *columnType = [columnTypes objectAtIndex:i];
                BOOL isEqual = [columnType.uppercaseString isEqualToString:SQLTEXT.uppercaseString];
                if (isEqual) {
                    [self setObj:[resultSet stringForColumn:columnName] forKey:columnName dict:dicColumn];
                } else {
                    // todo:
                    [self setLongLong:[resultSet longLongIntForColumn:columnName] forKey:columnName dict:dicColumn];
                }
            }
            [objs addObject:dicColumn];
            FMDBRelease(dicColumn);
        }
        [resultSet close];
    }];
    return objs;
}

// select a single data
+ (NSDictionary *)selectSingleFrom:(NSString *)tableName where:(NSString *)where {
    NSArray *results = [self selectResultsFrom:tableName statement:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, where]];
    if (results.count < 1) {
        return nil;
    }
    return [results firstObject];
}

+ (NSArray *)selectResultsAscendingFrom:(NSString *)tableName orderBy:(NSString *)orderBy {
    return [self selectResultsFrom:tableName where:nil orderBy:orderBy sort:@"DESC" limit:0];
}

+ (NSArray *)selectResultsDescendingFrom:(NSString *)tableName orderBy:(NSString *)orderBy {
    return [self selectResultsFrom:tableName where:nil orderBy:orderBy sort:@"ASC" limit:0];
}

+ (NSArray *)selectResultsAscendingFrom:(NSString *)tableName
                                  where:(NSString *)where
                                orderBy:(NSString *)orderBy
                                 limit:(NSInteger)limit {
    return [self selectResultsFrom:tableName where:where orderBy:orderBy sort:@"ASC" limit:limit];
}

+ (NSArray *)selectResultsDescendingFrom:(NSString *)tableName
                                   where:(NSString *)where
                                 orderBy:(NSString *)orderBy
                                   limit:(NSInteger)limit {
    return [self selectResultsFrom:tableName where:where orderBy:orderBy sort:@"DESC" limit:limit];
}

// select data by conditions
+ (NSArray *)selectResultsFrom:(NSString *)tableName
                         where:(NSString *)where
                       orderBy:(NSString *)orderBy
                          sort:(NSString *)sortType
                         limit:(NSInteger)limit {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", tableName];
    if (![self isBlankString:where]) {
        [sql appendString:[NSString stringWithFormat:@"WHERE %@", where]];
    }
    if (![self isBlankString:orderBy]) {
        [sql appendString:[NSString stringWithFormat:@" ORDER BY %@ %@", orderBy, sortType]];
    }
    if (limit > 0) {
        [sql appendString:[NSString stringWithFormat:@" LIMIT %lu", (unsigned long)limit]];
    }
    return [self selectResultsFrom:tableName statement:sql];
}

#pragma mark - is exist table

+ (BOOL)isExistTable:(NSString *)tableName {
    __block BOOL res = NO;
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    [assistant.dbQueue inDatabase:^(FMDatabase *db) {
        res = [db tableExists:tableName];
    }];
    return res;
}

#pragma mark - delete table

+ (BOOL)clearTable:(NSString *)tableName {
    FMDBAssistant *assistant = [FMDBAssistant sharedAssistant];
    __block BOOL res = NO;
    [assistant.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *exsql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        if (shouldOutputSql) {
            FMDBLog(@"Execute SQL:%@", exsql);
        }
        res = [db executeUpdate:exsql];
        if (!res) {
            FMDBLog(@"(Error)%@ Delete Table Failed: %@", tableName, [db lastErrorMessage]);
        }
    }];
    return res;
}

@end
