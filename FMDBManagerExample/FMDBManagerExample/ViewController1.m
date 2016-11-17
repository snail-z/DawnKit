//
//  ViewController1.m
//  FMDBManagerDemo
//
//  Created by zhanghao on 16/11/16.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import "ViewController1.h"
#import "ViewController2.h"

@interface ViewController1 ()

@property (nonatomic, strong) NSMutableArray *arrays;
@end

@implementation ViewController1

- (NSMutableArray *)arrays {
    if (!_arrays) {
        NSArray *arr = @[@"查找所有孩子",
                         @"查找所有男孩",
                         @"查找ID为1的孩子",
                         @"查找10岁以下的女孩",
                         @"查找年龄最大的孩子",
                         @"按年龄查出5名3岁以上的孩子",
                         @"修改ID为2的孩子姓名与家长电话",
                         @"删除名字叫刘佳的孩子",
                         @"更新表"];
        _arrays = [NSMutableArray arrayWithArray:arr];
    }
    return _arrays;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setRowHeight:60];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(saveData)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearData)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
}

#pragma mark - 保存所有孩子信息

- (void)saveData {
    NSString *column = @"childID INTEGER, childAge INTEGER, childName TEXT, parentsMobile TEXT, gender TEXT";
    
    // create table and set unique
    [FMDBManager createTableWithName:_tableName columns:column pk:nil unique:@"childID"];
    
    [[ChildrenInfos childrenList] enumerateObjectsUsingBlock:^(ChildrenInfos *infos, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *values = @[@(infos.childID),
                            @(infos.childAge),
                            infos.childName,
                            infos.parentsMobile,
                            infos.gender];
        
        // insert or ignore into data
        [FMDBManager insertIgnore:_tableName columns:@"childID, childAge, childName, parentsMobile, gender" values:values];
    }];
}

- (void)clearData {
    if ([FMDBManager isExistTable:_tableName]) {
        [FMDBManager clearTable:_tableName];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor colorWithRed:18/255.f green:130/255.f blue:254/255.f alpha:1];
    }
    cell.textLabel.text = self.arrays[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ViewController2 *vc = [ViewController2 new];
    vc.title = self.arrays[indexPath.row];
    vc.flag = indexPath.row + 1;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
