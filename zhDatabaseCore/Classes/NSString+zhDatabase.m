//
//  Created by zhanghao on 2017/4/9.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "NSString+zhDatabase.h"

@implementation NSString (zhDatabase)

+ (BOOL)isBlank:(NSString *)string {
    if (!string) return YES;
    if ([string isKindOfClass:[NSNull class]]) return YES;
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) return YES;
    return NO;
}

+ (NSString *)stringWithRepeat:(NSString*)string count:(NSInteger)repeatCount {
    return [@"" stringByPaddingToLength:string.length * repeatCount withString:string startingAtIndex:0];
}

+ (NSString *)createTable:(NSString *)tableName columnDescription:(NSString *)columns {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)", tableName, columns];
}

+ (NSString *)alterTable:(NSString *)tableName newColumn:(NSString *)column type:(NSString *)columnType {
    NSString *s = [NSString stringWithFormat:@"%@ %@", column, columnType];
    return [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ", tableName, s];
}

+ (NSString *)dropTable:(NSString *)tableName {
    return [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
}

+ (NSString *)renameTable:(NSString *)tableName newName:(NSString *)newName {
    return [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO '%@'", tableName, newName];
}

+ (NSString *)replaceIntoTable:(NSString *)tableName column:(NSString *)column columnCount:(NSUInteger)columnCount {
    NSParameterAssert(columnCount);
    NSString *vs = [NSString stringWithRepeat:@"?," count:columnCount - 1];
    if ([NSString isBlank:column]) {
        return [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (%@?)", tableName, vs];
    }
    return [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@(%@) VALUES (%@?)", tableName, column, vs];
}

+ (NSString *)ignoreIntoTable:(NSString *)tableName column:(NSString *)column columnCount:(NSUInteger)columnCount {
    NSParameterAssert(columnCount);
    NSString *vs = [NSString stringWithRepeat:@"?," count:columnCount - 1];
    if ([NSString isBlank:column]) {
        return [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ VALUES (%@?)", tableName, vs];
    }
    return [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(%@) VALUES (%@?)", tableName, column, vs];
}

+ (NSString *)deleteTable:(NSString *)tableName criteria:(NSString *)criteria {
    NSString *s = [NSString stringWithFormat:@"DELETE FROM %@ ", tableName];
    if ([NSString isBlank:criteria]) {
        return s;
    }
    return [s stringByAppendingFormat:@"WHERE %@ ", criteria];
}

+ (NSString *)updateTable:(NSString *)tableName set:(NSString *)s criteria:(NSString *)criteria {
    return [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", tableName, s, criteria];
}

+ (NSString *)selectTable:(NSString *)tableName criteria:(NSString *)criteria {
    NSString *s = [NSString stringWithFormat:@"SELECT * FROM %@ ", tableName];
    if ([NSString isBlank:criteria]) {
        return s;
    }
    return [s stringByAppendingFormat:@"WHERE %@ ", criteria];
}

+ (NSString *)selectTable:(NSString *)tableName criteria:(NSString *)criteria orderKey:(NSString *)key limitCount:(NSInteger)limitCount isDesc:(BOOL)isDesc {
    if (isDesc) {
        return [self selectTable:tableName criteria:criteria orderKey:key sort:@"DESC" count:limitCount];
    }
    return [self selectTable:tableName criteria:criteria orderKey:key sort:@"ASC" count:limitCount];
}

+ (NSString *)selectTable:(NSString *)tableName criteria:(NSString *)criteria orderKey:(NSString *)key sort:(NSString *)sort count:(NSInteger)limitCount {
    NSMutableString *s = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", tableName];
    if (![NSString isBlank:criteria]) {
        [s appendString:[NSString stringWithFormat:@"WHERE %@ ", criteria]];
    }
    if (![NSString isBlank:key]) {
        [s appendString:[NSString stringWithFormat:@"ORDER BY %@ %@ ", key, sort]];
    }
    if (limitCount > 0) {
        [s appendString:[NSString stringWithFormat:@"LIMIT %lu", limitCount]];
    }
    return s;
}

@end
