//
//  NSObject+SnailDatabase.m
//  FMDBManagerExample
//
//  Created by zhanghao on 2017/4/19.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "NSObject+SnailDatabase.h"

@implementation NSObject (SnailDatabase)

- (id <SnailDatabaseProtocol>)checkObject {
    NSAssert([self conformsToProtocol:@protocol(SnailDatabaseProtocol)],
             @"必须遵守SnailDatabaseProtocol协议!");
    NSAssert([self respondsToSelector:@selector(sl_tableName)],
             @"必须实现sl_tableName!");
    id <SnailDatabaseProtocol>object = (id<SnailDatabaseProtocol>)self;
    return object;
}

- (BOOL)sl_tableExists {
    return [FMDB tableExists:self.checkObject];
}

- (BOOL)sl_dropTable {
    return [FMDB dropTableWithObject:self.checkObject];
}

- (BOOL)sl_tableRename:(NSString *)newName {
    return [FMDB renameTableWithObject:self.checkObject newName:newName];
}

- (BOOL)sl_createTable {
    return [FMDB createTableWithObject:self.checkObject];
}

- (BOOL)sl_saveValues:(NSArray *)values {
    return [FMDB saveObject:self.checkObject values:values];
}

- (BOOL)sl_saveIgnoreValues:(NSArray *)values {
    return [FMDB saveIgnoreObject:self.checkObject values:values];
}

- (BOOL)sl_deleteByCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB deleteObject:self.checkObject byCriteriaWithFormat:format];
}

- (BOOL)sl_deleteSqlWithFormat:(NSString *)format, ... {
    return [FMDB deleteObject:self.checkObject sqlWithFormat:format];
}

- (BOOL)sl_updateKeys:(NSString *)setKeys byCriteria:(NSString *)criteria {
    return [FMDB updateObject:self.checkObject setKeys:setKeys byCriteria:criteria];
}

- (BOOL)sl_updateSqlWithFormat:(NSString *)format, ... {
    return [FMDB updateObject:self.checkObject sqlWithFormat:format];
}

- (NSArray *)sl_selectByCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject byCriteriaWithFormat:format];
}

- (NSArray *)sl_selectSqlWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject sqlWithFormat:format];
}

- (NSArray *)sl_descendingSelectOrderKey:(NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject orderKey:orderKey descSort:YES limitCount:limitCount byCriteriaWithFormat:format];
}

- (NSArray *)sl_ascendingSelectOrderKey:(NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject orderKey:orderKey descSort:NO limitCount:limitCount byCriteriaWithFormat:format];
}

#pragma mark - map / 自动映射方法

- (BOOL)sl_mapColumnCreateTableWithPrimaryKeyAndUniqueKeys:(NSString *)description {
    return [FMDB mapColumnCreateTableWithObject:self.checkObject appendPrimaryKeyAndUniqueKeys:description];
}

- (BOOL)sl_mapColumnSave {
    return [FMDB mapColumnSaveObject:self.checkObject];
}

- (BOOL)sl_mapColumnIgnoreSave {
    return [FMDB mapColumnSaveIgnoreObject:self.checkObject];
}

- (NSArray *)sl_mapColumnSelectByCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB mapColumnSelectObject:self.checkObject byCriteriaWithFormat:format];
}

- (NSArray *)sl_mapColumnSelectOrderKey:(NSString *)orderKey descSort:(BOOL)descSort limitCount:(NSInteger)limitCount byCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB mapColumnSelectObject:self.checkObject orderKey:orderKey descSort:descSort limitCount:limitCount byCriteriaWithFormat:format];
}

- (NSArray *)sl_mapColumnSelectSqlWithFormat:(NSString *)format, ... {
    return [FMDB mapColumnSelectObject:self.checkObject sqlWithFormat:format];
}

@end
