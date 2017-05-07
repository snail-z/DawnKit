//
//  SnailDatabaseFile.h
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/4/9.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailDatabaseFile : NSObject

+ (instancetype)fileWithPathName:(NSString *)pathName;
- (NSString *)pathName;
- (BOOL)skipBackupIcloud;
- (BOOL)removeDirAtPath:(NSString *)dirName;

@end
