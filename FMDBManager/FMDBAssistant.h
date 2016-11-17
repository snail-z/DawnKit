//
//  FMDatabaseAssistant.h
//  <https://github.com/snail-z/FMDBManager.git>
//
//  Created by zhanghao on 16/5/1.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

#ifdef DEBUG
#define FMDBLog(s, ... ) NSLog( @"\n[%@ in line %d]-------------------->%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define FMDBLog(s, ... )
#endif

#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"

/* 数据库所在的目录
 */
static NSString *sqliteInDirectory = @"User_db";

/* 数据库名称
 */
static NSString *sqliteName = @"User_db.sqlite";

/* 若shouldOutputPath为YES，输出数据库路径
 */
static BOOL shouldOutputPath = YES;

/* 若shouldOutputSql为YES，输出sql执行语句
 */
static BOOL shouldOutputSql = NO;

@interface FMDBAssistant : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
+ (instancetype)sharedAssistant;

/** 数据库路径
*/
+ (NSString *)databasePath;

/** 删除数据库及所在的目录
*/
+ (void)databasePathDele;

@end
