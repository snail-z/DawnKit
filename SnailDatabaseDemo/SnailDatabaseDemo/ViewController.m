//
//  ViewController.m
//  SnailDatabaseDemo
//
//  Created by zhanghao on 2017/4/29.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "ViewController.h"
#import "NextViewController.h"
#import "MyModel.h"
#import "MyModel2.h"
#import "NSDictionary+Extend.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray *_styles;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MyModel *model;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInitialization];
}

- (void)commonInitialization
{
    if (!_model) {
        _model = [[MyModel alloc] init];
        [_model sl_mapColumnCreateTableWithPrimaryKeyAndUniqueKeys:@"primary key(songID)"];
    }
    
    MyModel2 *model2 = [[MyModel2 alloc] init];
    [model2 writeInfos];
    [model2 selectInfos];
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.delaysContentTouches = NO;
        _tableView.rowHeight = 80;
        _tableView.tableFooterView = [UIView new];
    }
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(restore)];
    
    if (!_styles) {
        _styles = @[@"保存全部歌曲信息",
                    @"查询全部歌曲信息",
                    @"查询所有摇滚歌曲信息", @"条件查询\n（根据歌曲ID降序查询三条摇滚歌曲信息）",
                    @"更新数据\n（歌曲《分分钟需要你》改为林忆莲演唱）",
                    @"清空表数据",
                    @"条件删除\n（将歌曲ID大于2且小于6的歌删除）"];
    }
}

- (void)restore
{
    if ([_model sl_tableExists]) {
        [_model sl_dropTable];
    }
    [_model sl_mapColumnCreateTableWithPrimaryKeyAndUniqueKeys:@"primary key(songID)"];
}

- (NSArray *)getProducts {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"products" ofType:@"plist"];
    return [[NSMutableArray alloc] initWithContentsOfFile:filePath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _styles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _styles[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selName = [NSString stringWithFormat:@"example%lu", indexPath.row + 1];
    SEL sel = NSSelectorFromString(selName);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:nil afterDelay:0];
    }
}

- (void)example1
{
    NSArray *results = [self getProducts].copy;
    for (NSDictionary *dict in results) {
        MyModel *model = [[MyModel alloc] init];
        model.isRock = [dict boolValueForKey:@"isRock"];
        model.lyrics = [dict stringForKey:@"lyrics"];
        model.myData = (NSData *)[dict objectForKey:@"myData"];
        model.myFloat = [dict doubleValueForKey:@"myFloat"];
        model.myID = [dict integerValueForKey:@"myID"];
        model.myTime = (NSDate *)[dict objectForKey:@"myTime"];
        model.singerName = [dict stringForKey:@"singerName"];
        model.songID = [dict integerValueForKey:@"songID"];
        model.songName = [dict stringForKey:@"songName"];
        model.songUrl = [NSURL URLWithString:[dict stringForKey:@"songUrl"]];
        model.style = [dict stringForKey:@"style"];
        [model sl_mapColumnIgnoreSave];
    }
}

- (void)example2
{
//    NSArray *models = [_model sl_mapColumnSelectSqlWithFormat:@"SELECT * FROM my_model_table"];
    NSArray *models = [_model sl_mapColumnSelectByCriteriaWithFormat:nil];
    [self next:models];
}

- (void)example3
{
    NSArray *models = [_model sl_mapColumnSelectByCriteriaWithFormat:@"isRock = '1'"];
    [self next:models];
}

- (void)example4
{
    NSArray *models = [_model sl_mapColumnSelectOrderKey:@"songID"
                                                descSort:YES
                                              limitCount:3
                                    byCriteriaWithFormat:@"style = '摇滚'"];
    [self next:models];
}

- (void)example5
{
//    [_model sl_updateSqlWithFormat:@"UPDATE my_model_table SET singerName = '李健' where songID = '2'"];
    [_model sl_updateKeys:@"singerName = '林忆莲'" byCriteria:@"songID = '8'"];
   
    NSArray *models = [_model sl_mapColumnSelectByCriteriaWithFormat:@"songID = '8'"];
    [self next:models];
}

- (void)example6
{
    if ([_model sl_deleteByCriteriaWithFormat:nil]) {
        NSLog(@"成功清空表数据");
    }
}

- (void)example7
{
//    BOOL res = [_model sl_deleteSqlWithFormat:@"DELETE FROM my_model_table WHERE songID > '5' and songID < '9'"];
    BOOL res = [_model sl_deleteByCriteriaWithFormat:@"songID > '2' and songID < '6'"];
    if (res) {
        NSLog(@"删除成功");
        [self example2];
    }
}


#pragma mark - NextViewController

- (void)next:(NSArray *)array
{
    NextViewController *vc = [[NextViewController alloc] initWithModels:array];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
