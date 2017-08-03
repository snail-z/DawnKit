#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSObject+zhDatabase.h"
#import "NSString+zhDatabase.h"
#import "zhDatabaseCore.h"
#import "zhDatabaseFile.h"
#import "zhDatabaseProtocol.h"

FOUNDATION_EXPORT double zhDatabaseCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char zhDatabaseCoreVersionString[];

