//
//  NextViewController.m
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/5/1.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "NextViewController.h"
#import "MyModel.h"

@interface NextViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray *_array;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation NextViewController

- (instancetype)initWithModels:(NSArray *)models {
    if (self = [super init]) {
        _array = [NSArray arrayWithArray:models];
        [_tableView reloadData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInitialization];
}

- (void)commonInitialization {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.delaysContentTouches = NO;
        _tableView.rowHeight = 150;
    }
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    MyModel *model = _array[indexPath.row];
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"songID: %lu\n歌手: %@\n风格: %@\n歌词: %@", model.songID, model.singerName, model.style, model.lyrics];
    cell.textLabel.text = model.songName;
    cell.detailTextLabel.text = string;
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

@end
