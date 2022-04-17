//
//  ListViewController.m
//  Checking
//
//  Created by 杜俊楠 on 2022/4/12.
//  Copyright © 2022 杜俊楠. All rights reserved.
//
#define AllCountsKey @"allCounts"
#define CheckDaysKey @"Days"
#define RefreshDataNoti @"refreshData"

#import "ListViewController.h"

@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;


@property (nonatomic,strong) NSMutableArray *dataSource;


@end

@implementation ListViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.editing = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setData];
    [self setUI];
    
}

- (void)setUI {
    UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
//    headerLab.backgroundColor = [UIColor redColor];
    headerLab.text = self.dateStr;
    headerLab.textAlignment = NSTextAlignmentCenter;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.tableHeaderView = headerLab;
    [self.view addSubview:self.tableView];
}
     
- (void)setData {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self readFromPlistWithPlistName:self.dateStr]];
    self.dataSource = [[NSMutableArray alloc] initWithArray:dict[@"array"]];
}

- (void)DeleteData {
    NSDictionary *wiriteDict = @{@"count":[NSString stringWithFormat:@"%lu",(unsigned long)self.dataSource.count],@"array":self.dataSource};
//    NSLog(@"%@",wiriteDict);
    [self writeToPlist:wiriteDict plistName:self.dateStr];
  
    NSString *key = AllCountsKey;
    NSInteger counts = [self getCheckingCounts:key];
    counts--;
    [self saveCheckingCounts:key andCheckingCounts:counts];
    
    if (!self.dataSource.count) {
        [self deleteDateStrWithDateStr:self.dateStr];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma delegeMethod
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [[NSString stringWithFormat:@"第%ld次打卡记录: %@",(long)indexPath.row+1,self.dataSource[indexPath.row]] substringToIndex:14];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //数组删掉
        [self.dataSource removeObjectAtIndex:indexPath.row];
        //本地删除
        [self DeleteData];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


#pragma 工具方法

- (void)deleteDateStrWithDateStr:(NSString *)dateStr {
    NSMutableArray *dateStrArray;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self readFromPlistWithPlistName:CheckDaysKey]];
    dateStrArray = [[NSMutableArray alloc] initWithArray:dict[@"array"]];
    NSInteger flag = 0;
    for (int i = 0; i<dateStrArray.count; i++) {
        NSString *str = dateStrArray[i];
        if ([str isEqualToString:dateStr]) {
            flag = i;
        }
    }
    [dateStrArray removeObjectAtIndex:flag];
    NSDictionary *wiriteDict = @{@"count":[NSString stringWithFormat:@"%lu",(unsigned long)dateStrArray.count],@"array":dateStrArray};
    [self writeToPlist:wiriteDict plistName:CheckDaysKey];
}

- (NSDictionary *)readFromPlistWithPlistName:(NSString *)plistName{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:plistName];
    NSDictionary *resultDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return resultDict;
}

- (BOOL)writeToPlist:(NSDictionary *)dict plistName:(NSString *)plistName{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:plistName];
    BOOL isSucceed = [dict writeToFile:filePath atomically:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshDataNoti object:nil];
    return isSucceed;
}

- (void)saveCheckingCounts:(NSString *)CheckingCountsKey andCheckingCounts:(NSInteger)saveCheckingCounts {
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setInteger:saveCheckingCounts forKey:CheckingCountsKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshDataNoti object:nil];
    [userDefaultes synchronize];
}

- (NSInteger )getCheckingCounts:(NSString *)CheckingCountsKey {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSInteger checkingCounts = [userDefaultes integerForKey:CheckingCountsKey];
    return checkingCounts;
}




@end
