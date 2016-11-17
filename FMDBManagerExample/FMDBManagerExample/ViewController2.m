//
//  ViewController2.m
//  FMDBManagerDemo
//
//  Created by zhanghao on 16/11/16.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()

@property (nonatomic, strong) NSArray *list;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setRowHeight:125];
    self.view.backgroundColor = [UIColor whiteColor];
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"example%lu", _flag]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:sel]) [self performSelector:sel];
#pragma clang diagnostic pop
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    ChildrenInfos *info = _list[indexPath.row];
    NSMutableString *detailText = [NSMutableString new];
    [detailText appendFormat:@"id: %lu\n性别: %@\n年龄: %lu\n家长电话: %@", info.childID, info.gender, info.childAge, info.parentsMobile];
    if (info.love) {
        [detailText appendFormat:@"\n喜欢: %@", info.love];
    }
    cell.textLabel.text = info.childName;
    cell.detailTextLabel.text = detailText;
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

#pragma mark - Example

- (void)example1 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        // 查找所有孩子
        NSArray *results = [FMDBManager selectAllFrom:_tableName];
        
        [self reloadData:results];
    });
}

- (void)example2 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 查找所有男孩
        NSArray *results = [FMDBManager selectResultsFrom:_tableName where:@"gender = '男'"];
       
        [self reloadData:results];
    });
}

- (void)example3 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 查找id为1的孩子
        NSDictionary *results = [FMDBManager selectSingleFrom:_tableName where:@"childID = '1'"];
        if (results) {
            [self reloadData:@[results]];
        }
    });
}

- (void)example4 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 查找10岁以下的女孩
        NSArray *results = [FMDBManager selectResultsFrom:_tableName
                                                    where:@"childAge < '10' and gender = '女'"];
        
        [self reloadData:results];
    });
}

- (void)example5 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 查找年龄最大的孩子
        NSArray *results = [FMDBManager selectResultsDescendingFrom:_tableName
                                                              where:nil
                                                            orderBy:@"childAge"
                                                              limit:1];
        
        [self reloadData:results];
    });
}

- (void)example6 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 按年龄查出5名3岁以上的孩子
        NSArray *results = [FMDBManager selectResultsAscendingFrom:_tableName
                                                             where:@"childAge > '3'"
                                                           orderBy:@"childAge"
                                                             limit:5];
        [self reloadData:results];
    });
}

- (void)example7 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *name = @[@"李然", @"汪晓汇", @"赵照", @"张子闵", @"叶辉"];
        NSInteger i = arc4random() % name.count;
        NSInteger j = (arc4random() % 1001) + 10000;
        NSString *sql = [NSString stringWithFormat:@"childName = '%@', parentsMobile = '%lu'", name[i], j];
        
        // 修改id为2的孩子姓名与家长电话
        BOOL result = [FMDBManager update:_tableName set:sql where:@"childID = '2'"];

        if (result) {
            NSArray *results = [FMDBManager selectResultsFrom:_tableName where:@"childID = '2'"];
            [self reloadData:results];
        }
    });
}

- (void)example8 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 删除名字叫刘佳的孩子
        BOOL result = [FMDBManager deleteFrom:_tableName where:@"childName = '刘佳'"];
        
        if (result) {
            NSArray *results = [FMDBManager selectResultsAscendingFrom:_tableName orderBy:@"childID"];
            [self reloadData:results];
        }
    });
}

- (void)example9 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *column = @"childID INTEGER, childAge INTEGER, childName TEXT, parentsMobile TEXT, gender TEXT, love TEXT";
        
        // 更新表，增加字段love
        [FMDBManager createTableWithName:_tableName columns:column pk:nil unique:@"childID"];
        
        [[ChildrenInfos childrenList] enumerateObjectsUsingBlock:^(ChildrenInfos *infos, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *values = @[@(infos.childID),
                                @(infos.childAge),
                                infos.childName,
                                infos.parentsMobile,
                                infos.gender,
                                infos.love];
            
            // insert or replace into data
            [FMDBManager insertReplace:_tableName columns:@"childID, childAge, childName, parentsMobile, gender, love" values:values];
        }];
        
        NSArray *results = [FMDBManager selectAllFrom:_tableName];
        [self reloadData:results];
    });
}

- (void)reloadData:(NSArray *)results {
    _list = [ChildrenInfos infoFrom:results];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
