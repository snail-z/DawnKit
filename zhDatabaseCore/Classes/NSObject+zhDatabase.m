//
//  Created by zhanghao on 2017/4/19.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "NSObject+zhDatabase.h"
#import "zhDatabaseCore.h"

@implementation NSObject (zhDatabase)

- (id <zhDatabaseProtocol>)checkObject {
    NSAssert([self conformsToProtocol:@protocol(zhDatabaseProtocol)],
             @"必须遵守zhDatabaseProtocol协议!");
    NSAssert([self respondsToSelector:@selector(zh_tableName)],
             @"必须实现zh_tableName!");
    id <zhDatabaseProtocol>object = (id<zhDatabaseProtocol>)self;
    return object;
}

- (BOOL)zh_tableExists {
    return [FMDB tableExists:self.checkObject];
}

- (BOOL)zh_dropTable {
    return [FMDB dropTableWithObject:self.checkObject];
}

- (BOOL)zh_tableRename:(NSString *)newName {
    return [FMDB renameTableWithObject:self.checkObject newName:newName];
}

- (BOOL)zh_createTable {
    return [FMDB createTableWithObject:self.checkObject];
}

- (BOOL)zh_saveValues:(NSArray *)values {
    return [FMDB saveObject:self.checkObject values:values];
}

- (BOOL)zh_saveIgnoreValues:(NSArray *)values {
    return [FMDB saveIgnoreObject:self.checkObject values:values];
}

- (BOOL)zh_deleteByCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB deleteObject:self.checkObject byCriteriaWithFormat:format];
}

- (BOOL)zh_deleteSqlWithFormat:(NSString *)format, ... {
    return [FMDB deleteObject:self.checkObject sqlWithFormat:format];
}

- (BOOL)zh_updateKeys:(NSString *)setKeys byCriteria:(NSString *)criteria {
    return [FMDB updateObject:self.checkObject setKeys:setKeys byCriteria:criteria];
}

- (BOOL)zh_updateSqlWithFormat:(NSString *)format, ... {
    return [FMDB updateObject:self.checkObject sqlWithFormat:format];
}

- (NSArray *)zh_selectByCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject byCriteriaWithFormat:format];
}

- (NSArray *)zh_selectSqlWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject sqlWithFormat:format];
}

- (NSArray *)zh_descendingSelectOrderKey:(NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject orderKey:orderKey descSort:YES limitCount:limitCount byCriteriaWithFormat:format];
}

- (NSArray *)zh_ascendingSelectOrderKey:(NSString *)orderKey limitCount:(NSInteger)limitCount byCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB selectObject:self.checkObject orderKey:orderKey descSort:NO limitCount:limitCount byCriteriaWithFormat:format];
}

#pragma mark - map / 自动映射方法

- (BOOL)zh_mapColumnCreateTableWithPrimaryKeyAndUniqueKeys:(NSString *)description {
    return [FMDB mapColumnCreateTableWithObject:self.checkObject appendPrimaryKeyAndUniqueKeys:description];
}

- (BOOL)zh_mapColumnSave {
    return [FMDB mapColumnSaveObject:self.checkObject];
}

- (BOOL)zh_mapColumnIgnoreSave {
    return [FMDB mapColumnSaveIgnoreObject:self.checkObject];
}

- (NSArray *)zh_mapColumnSelectByCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB mapColumnSelectObject:self.checkObject byCriteriaWithFormat:format];
}

- (NSArray *)zh_mapColumnSelectOrderKey:(NSString *)orderKey descSort:(BOOL)descSort limitCount:(NSInteger)limitCount byCriteriaWithFormat:(NSString *)format, ... {
    return [FMDB mapColumnSelectObject:self.checkObject orderKey:orderKey descSort:descSort limitCount:limitCount byCriteriaWithFormat:format];
}

- (NSArray *)zh_mapColumnSelectSqlWithFormat:(NSString *)format, ... {
    return [FMDB mapColumnSelectObject:self.checkObject sqlWithFormat:format];
}

@end
