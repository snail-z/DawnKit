//
//  NSDictionary+Extend.m
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/4/26.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "NSDictionary+Extend.h"

@implementation NSDictionary(Extend)

- (NSArray *)arrayForKey:(NSString *)key {
    id result = [self objectForKey:key];
    if ([result isKindOfClass:[NSArray class]]) {
        return result;
    }
    return nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    id result = [self objectForKey:key];
    if ([result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    return nil;
}

- (NSString *)stringForKey:(NSString*)key {
    id result = [self objectForKey:key];
    if ([result isKindOfClass:[NSString class]]) {
        return result;
    } else if (result) {
        return [NSString stringWithFormat:@"%@", result];
    }
    return @"";
}

- (NSNumber *)numberForKey:(NSString *)key {
    id result = [self objectForKey:key];
    if ([result isKindOfClass:[NSNumber class]]) {
        return result;
    } else if ([result isKindOfClass:[NSString class]]) {
        static NSNumberFormatter *formatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
        });
        return [formatter numberFromString:result];
    }
    return nil;
}

- (int)intValueForKey: (NSString*)key {
    return [self numberForKey:key].intValue;
}

- (double)doubleValueForKey:(NSString *)key {
    return [self numberForKey:key].doubleValue;
}

- (int64_t)longLongValueForKey: (NSString *)key {
    return [self numberForKey:key].longLongValue;
}

- (BOOL)boolValueForKey: (NSString *)key {
    return [self numberForKey:key].boolValue;
}

- (NSInteger)integerValueForKey:(NSString *)key {
    return [self numberForKey:key].integerValue;
}

- (NSData *)JSONData {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    } else {
        return nil;
    }
}

- (NSString *)JSONString {
    NSData *data = self.JSONData;
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

@end
