//
//  SnailDatabaseFile.m
//  FMDBManagerExample
//
//  Created by zhanghao on 2017/4/9.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "SnailDatabaseFile.h"

@implementation SnailDatabaseFile {
    NSString *_filePath;
}

+ (instancetype)fileWithPathName:(NSString *)pathName {
    return [[self alloc] initWithPathName:pathName];;
}

- (instancetype)initWithPathName:(NSString *)pathName {
    if (self = [super init]) {
        _filePath = pathName;
    }
    return self;
}

- (NSString *)pathName {
    NSString *path = [self createDirectoryAtPath:_filePath];
    NSLog(@"DBPath: %@", path);
    return path;
}

- (NSString *)createDirectoryAtPath:(NSString *)dirName {
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSRange r = [dirName rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, dirName.length) locale:nil];
    if (r.location != NSNotFound) {
        NSString *inPath = [dirName substringToIndex:r.location];
        paths = [paths stringByAppendingPathComponent:inPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:paths]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:paths withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *dbName = [dirName substringFromIndex:r.location + 1];
        return [paths stringByAppendingPathComponent:dbName];
    }
    return [paths stringByAppendingPathComponent:dirName];
}

- (BOOL)removeDirAtPath:(NSString *)dirName {
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    paths = [paths stringByAppendingPathComponent:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:paths] && [fileManager isDeletableFileAtPath:paths]) {
        return [fileManager removeItemAtPath:paths error:nil];
    }
    return YES;
}

- (BOOL)skipBackupIcloud {
    if (nil == self.pathName || [[NSFileManager defaultManager] fileExistsAtPath:self.pathName]) {
        return NO;
    }
    NSURL *url = [NSURL fileURLWithPath:self.pathName];
    NSError *error = nil;
    BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", url.lastPathComponent, error);
    }
    return success;
}

@end
