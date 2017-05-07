//
//  NSDictionary+Extend.h
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/4/26.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(Extend)

- (NSArray*)arrayForKey: (NSString*)key;
- (NSDictionary*)dictionaryForKey: (NSString*)key;
- (NSNumber*)numberForKey:(NSString*)key;
- (NSString*)stringForKey: (NSString*)key;

- (int)intValueForKey:(NSString*)key;
- (double)doubleValueForKey:(NSString *)key;
- (int64_t)longLongValueForKey: (NSString *)key;
- (BOOL)boolValueForKey:(NSString*)key;
- (NSInteger)integerValueForKey:(NSString*)key;

- (NSData*)JSONData;
- (NSString*)JSONString;

@end
