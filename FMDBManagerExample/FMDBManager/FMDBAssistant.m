//
//  FMDatabaseAssistant.m
//  <https://github.com/snail-z/FMDBManager.git>
//
//  Created by zhanghao on 16/5/1.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import "FMDBAssistant.h"

@implementation FMDBAssistant

+ (instancetype)sharedAssistant {
    static FMDBAssistant *_sharedAssistant = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAssistant = [[FMDBAssistant alloc] init];
    });
    return _sharedAssistant;
}

- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self.class databasePath]];
        if (shouldOutputPath) {
            FMDBLog(@"Database Path:\n%@\n", [self.class databasePath]);
        }
    }
    return _dbQueue;
}

+ (NSString *)databasePath {
    return [self createDirectoryAtPath:nil];
}

+ (void)databasePathDele {
    [self removeDirectoryAtPath:nil];
}

// Sandbox directory
+ (NSString *)documentDirectory {
    return [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Create a database in the sandbox directory
+ (NSString *)dbpathInDocument {
    return [[self documentDirectory] stringByAppendingPathComponent:sqliteName];;
}

+ (NSString *)createDirectoryAtPath:(NSString *)path {
    NSString *documentDirectory = [self documentDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!path || !path.length) {
        documentDirectory = [documentDirectory stringByAppendingPathComponent:sqliteInDirectory];
    } else {
        documentDirectory = [documentDirectory stringByAppendingPathComponent:path];
    }
    BOOL isDirectory;
    BOOL exits =[fileManager fileExistsAtPath:documentDirectory isDirectory:&isDirectory];
    if (!exits || !isDirectory) {
        [fileManager createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [documentDirectory stringByAppendingPathComponent:sqliteName];
}

+ (void)removeDirectoryAtPath:(NSString *)path {
    NSString *documentDirectory = [self documentDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!path || !path.length) {
        documentDirectory = [documentDirectory stringByAppendingPathComponent:sqliteInDirectory];
    } else {
        documentDirectory = [documentDirectory stringByAppendingPathComponent:path];
    }
    BOOL isExists = [fileManager fileExistsAtPath:documentDirectory];
    BOOL isDele = [fileManager isDeletableFileAtPath:documentDirectory];
    if (isExists && isDele) {
        [fileManager removeItemAtPath:documentDirectory error:nil];
    }
}

@end
