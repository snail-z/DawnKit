//
//  ViewController2.h
//  FMDBManagerDemo
//
//  Created by zhanghao on 16/11/16.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBManager.h"
#import "ChildrenInfos.h"

static NSString *const _tableName = @"Children";

@interface ViewController2 : UITableViewController

@property (nonatomic, assign) NSInteger flag;

@end
