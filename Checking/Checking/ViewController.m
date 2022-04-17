//
//  ViewController.m
//  Checking
//
//  Created by 杜俊楠 on 2022/4/12.
//  Copyright © 2022 杜俊楠. All rights reserved.
//

#define AllCountsKey @"allCounts"
#define CheckDaysKey @"Days"
#define RefreshDataNoti @"refreshData"

#import "ViewController.h"
#import "ListViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *checkingBtn;

@property (nonatomic,strong) UIDatePicker *myDatePicker;

@property (nonatomic,strong) UIView *datePickerBg;

@property (nonatomic,strong) UILabel *checkingCountsLab;

@property (nonatomic,strong) UILabel *checkingDaysLab;

@property (nonatomic,strong) UILabel *countinueToNowLab;

@property (nonatomic,strong) UILabel *countinueMaxDaysLab;

//总打卡次数
@property (nonatomic,assign) NSInteger allCounts;
//总打卡天数
@property (nonatomic,assign) NSInteger allDaysCounts;
//至今连续
@property (nonatomic,assign) NSInteger continueDays;
//最大连续
@property (nonatomic,assign) NSInteger countinueMaxDays;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:RefreshDataNoti object:nil];
    
    [self getBaseData];
    
    [self setUI];
}

- (void)setUI {
    
    self.checkingCountsLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, self.view.frame.size.width-40, 40)];
    self.checkingCountsLab.backgroundColor = [UIColor whiteColor];
    self.checkingCountsLab.text = [NSString stringWithFormat:@"总打卡次数:%ld",(long)_allCounts];
    [self.view addSubview:self.checkingCountsLab];
    
    self.checkingDaysLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, self.view.frame.size.width-40, 40)];
    self.checkingDaysLab.backgroundColor = [UIColor whiteColor];
    self.checkingDaysLab.text = [NSString stringWithFormat:@"总打卡天数:%ld",(long)_allDaysCounts];
    [self.view addSubview:self.checkingDaysLab];
    
    self.countinueToNowLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 145, self.view.frame.size.width-40, 40)];
    self.countinueToNowLab.backgroundColor = [UIColor whiteColor];
    self.countinueToNowLab.text = [NSString stringWithFormat:@"至今连续打卡天数:%ld",(long)_continueDays];
    [self.view addSubview:self.countinueToNowLab];
    
    self.countinueMaxDaysLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 195, self.view.frame.size.width-40, 40)];
    self.countinueMaxDaysLab.backgroundColor = [UIColor whiteColor];
    self.countinueMaxDaysLab.text = [NSString stringWithFormat:@"最多连续打卡天数:%ld",(long)_countinueMaxDays];
    [self.view addSubview:self.countinueMaxDaysLab];
    
    self.checkingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkingBtn setTitle:@"打卡" forState:UIControlStateNormal];
    [self.checkingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.checkingBtn.backgroundColor = [UIColor whiteColor];
    self.checkingBtn.layer.cornerRadius = 15;
    self.checkingBtn.frame = CGRectMake(50, self.view.bounds.size.height/2+100, 100, 100);
    [self.view addSubview:self.checkingBtn];
    [self.checkingBtn addTarget:self action:@selector(checkingBtnAction) forControlEvents:UIControlEventTouchDown];
        
    
    UIButton *lookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lookBtn setTitle:@"查卡" forState:UIControlStateNormal];
    [lookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    lookBtn.backgroundColor = [UIColor whiteColor];
    lookBtn.layer.cornerRadius = 15;
    lookBtn.frame = CGRectMake(self.view.bounds.size.width-150, self.view.bounds.size.height/2+100, 100, 100);
    [self.view addSubview:lookBtn];
    [lookBtn addTarget:self action:@selector(lookBtnAction) forControlEvents:UIControlEventTouchDown];
    
    
    [self.view addSubview:self.datePickerBg];
}

- (void)getBaseData {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd"];
    
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    NSMutableArray *dateStrArray;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self readFromPlistWithPlistName:CheckDaysKey]];
    dateStrArray = [[NSMutableArray alloc] initWithArray:dict[@"array"]];
    for (NSString *str in dateStrArray) {
        NSDate *date = [[formatter dateFromString:str] dateByAddingTimeInterval:28801];
        [dateArray addObject:date];
    }
    
    if (dateArray.count) {
        //总打卡次数
        _allCounts = [self getCheckingCounts:AllCountsKey];
        //总打卡天数
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self readFromPlistWithPlistName:CheckDaysKey]];
        _allDaysCounts = [[dict objectForKey:@"count"] integerValue];
        //排序
        dateStrArray = [self sortDateArrayWith:dateArray];
        //至今连续
        NSTimeInterval timeInterval = [[NSDate now] timeIntervalSinceDate:dateStrArray.firstObject];
        if ( timeInterval < 86400) {
            //今天签过到
            _continueDays = [self daysOfCountinueToNowWith:dateStrArray];
        }
        else {
            //今天没签过到
            _continueDays = 0;
        }
        //最大连续
        _countinueMaxDays = [self daysOfCountinueMaxWith:dateStrArray];
    }
    else {
        _allCounts = 0;
        _allDaysCounts = 0;
        _continueDays = 0;
        _countinueMaxDays = 0;
        
    }
}

//获取至今连续签到数
- (NSInteger)daysOfCountinueMaxWith:(NSMutableArray *)array {
    return  [self countDaysWith:array andFromMaxDaysOrNowDays:YES];
}
//获取历时最大签到数
- (NSInteger)daysOfCountinueToNowWith:(NSMutableArray *)array {
    return [self countDaysWith:array andFromMaxDaysOrNowDays:NO];
}
//具体计算
- (NSUInteger)countDaysWith:(NSMutableArray *)daysArray andFromMaxDaysOrNowDays:(BOOL)isFromMaxDays {
    NSInteger max = 1;
    NSInteger flag = 1;
    for (int i=0; i<daysArray.count-1; i++) {
        NSDate *date_left = daysArray[i];
        NSDate *date_right = daysArray[i+1];
        if ([date_left timeIntervalSinceDate:date_right] <= 86400) {
            //签到没断
            flag++;
        }
        else {
            //签到断了
            if (isFromMaxDays) {
                if (max < flag) {
                    max = flag;
                }
                flag = 1;
            }
            else {
                break;
            }
            
        }
    }
    return max>flag?max:flag;
}
//排序
- (NSMutableArray *)sortDateArrayWith:(NSMutableArray *)array {
    if (!array.count) {
        return array;
    }
    
    NSMutableArray *dateArray = array;
    for (int i=0; i<dateArray.count-1; i++) {
        for (int j=0; j<dateArray.count-1-i; j++) {
            NSDate *date_left = dateArray[j];
            NSDate *date_right = dateArray[j+1];
            if ([date_left timeIntervalSinceNow] < [date_right timeIntervalSinceNow]) {
                [dateArray exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            }
        }
    }
    return dateArray;
}

#pragma 触发方法
- (void)checkingBtnAction {
    NSString *dateStr = [self getDateStrWith:[NSDate now]];
    NSString *timeStr = [self getTimeStrWith:[NSDate now]];
    //将每一天的打卡时间写入
    NSString *isSucceed;
    if ([self setTimeStrWithDateStr:dateStr withTmeStr:timeStr]) {
        isSucceed = @"打卡成功";
    }
    else {
        isSucceed = @"打卡失败";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:isSucceed message:nil preferredStyle:UIAlertControllerStyleAlert];
//    __weak weakself
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
    
    //记录打卡天数
    [self setDateStrWithDateStr:dateStr];
    //快速记录打卡次数
    [self setCheckingCounts];
    
}
//查历史打卡
- (void)lookBtnAction {
    self.datePickerBg.hidden = NO;
}

- (void)datePickerCompleteBtnAction {
    NSString *dateStr = [self getDateStrWith:self.myDatePicker.date];
    NSString *timeStr = [self getTimeStrWith:self.myDatePicker.date];
    BOOL _flag = [self didGetCheckingRecord];
    
    if (_flag) {
        //找到了
        ListViewController *vc = [[ListViewController alloc] init];
        vc.dateStr = dateStr;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        //没找到
        NSString *alertMsg = @"您在当天已经打过卡,请问您是否继续补卡";
        NSString *confirmMsg = @"继续";
        [self noCheckingRecordAndActionWith:dateStr with:timeStr with:alertMsg with:confirmMsg];
    }
}

- (void)datePickerCancelBtnAction {
    self.datePickerBg.hidden = YES;
}

- (void)datePickerHistoryBtnAction {
    
    NSString *dateStr = [self getDateStrWith:self.myDatePicker.date];
    NSString *timeStr = [self getTimeStrWith:self.myDatePicker.date];
    BOOL _flag = [self didGetCheckingRecord];
    
    
    NSString *alertMsg;
    NSString *confirmMsg;
    if (_flag) {
        //找到了
        alertMsg = @"您在当天已经打过卡,请问您是否继续补卡";
        confirmMsg = @"继续";
    }
    else {
        //没找到
        alertMsg = @"没有您的补卡记录,请问您是否立即补卡";
        confirmMsg = @"补卡";
    }
    [self noCheckingRecordAndActionWith:dateStr with:timeStr with:alertMsg with:confirmMsg];
}

- (BOOL)didGetCheckingRecord {
    NSString *dateStr = [self getDateStrWith:self.myDatePicker.date];

    NSMutableArray *dateStrArray;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self readFromPlistWithPlistName:CheckDaysKey]];
    BOOL _flag = NO;
    dateStrArray = [[NSMutableArray alloc] initWithArray:dict[@"array"]];
    for (int i=(int)dateStrArray.count; i>0; i--) {
        NSString *str = dateStrArray[i-1];
        if ([str isEqualToString:dateStr]) {
            _flag = YES;
            break;
        }
    }
    return _flag;
}

- (void)noCheckingRecordAndActionWith:(NSString *)dateStr with:(NSString *)timeStr with:(NSString *)AlertMsg with:(NSString *)confirBtnMsg {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:AlertMsg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:confirBtnMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self historyCheckingActionWith:dateStr WithTimeStr:timeStr];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"不了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)historyCheckingActionWith:(NSString *)dateStr WithTimeStr:(NSString *)timeStr {
    [self setTimeStrWithDateStr:dateStr withTmeStr:timeStr];
    [self setCheckingCounts];
    [self setDateStrWithDateStr:dateStr];
    UIAlertController *alertInside = [UIAlertController alertControllerWithTitle:nil message:@"补卡成功" preferredStyle:UIAlertControllerStyleAlert];
    [alertInside addAction:[UIAlertAction actionWithTitle:@"补卡" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alertInside animated:YES completion:^{}];
}

- (void)refreshData {
    
    dispatch_queue_t t = dispatch_queue_create("refresh", DISPATCH_QUEUE_SERIAL);
    dispatch_async(t, ^{
        [self getBaseData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.checkingCountsLab.text = [NSString stringWithFormat:@"总打卡次数:%ld",(long)[self getCheckingCounts:AllCountsKey]];
            self.checkingDaysLab.text = [NSString stringWithFormat:@"总打卡天数:%@",[[self readFromPlistWithPlistName:CheckDaysKey] objectForKey:@"count"]?[[self readFromPlistWithPlistName:CheckDaysKey] objectForKey:@"count"]:@"0"];
            self.countinueToNowLab.text = [NSString stringWithFormat:@"至今连续打卡天数:%ld",(long)self->_continueDays];
            self.countinueMaxDaysLab.text = [NSString stringWithFormat:@"最多连续打卡天数:%ld",(long)self->_countinueMaxDays];
        });

    });
}

#pragma 工厂方法
- (UIDatePicker *)myDatePicker {
    if (!_myDatePicker) {
        _myDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 200)];
//        _myDatePicker.backgroundColor = [UIColor whiteColor];
        _myDatePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        //显示方式是只显示年月日
        _myDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _myDatePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        _myDatePicker.maximumDate = [NSDate now];
    }
    
    return _myDatePicker;
}

- (UIView *)datePickerBg {
    if (!_datePickerBg) {
        _datePickerBg = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-240, self.view.bounds.size.width, 240)];
        _datePickerBg.backgroundColor = [UIColor whiteColor];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"确认" forState:UIControlStateNormal];
        btn.frame = CGRectMake(self.view.bounds.size.width-60, 0, 50, 40);
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(datePickerCompleteBtnAction) forControlEvents:UIControlEventTouchDown];
        [_datePickerBg addSubview:btn];
        
        UIButton *btn_cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_cancel setTitle:@"取消" forState:UIControlStateNormal];
        btn_cancel.frame = CGRectMake(20, 0, 50, 40);
        [btn_cancel setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn_cancel addTarget:self action:@selector(datePickerCancelBtnAction) forControlEvents:UIControlEventTouchDown];
        [_datePickerBg addSubview:btn_cancel];
        
        UIButton *btn_historry = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_historry setTitle:@"历史补卡" forState:UIControlStateNormal];
        btn_historry.frame = CGRectMake(self.view.bounds.size.width/2-45, 0, 90, 40);
        [btn_historry setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn_historry addTarget:self action:@selector(datePickerHistoryBtnAction) forControlEvents:UIControlEventTouchDown];
        [_datePickerBg addSubview:btn_historry];

        [_datePickerBg addSubview:self.myDatePicker];
        _datePickerBg.hidden = YES;
    }
    return _datePickerBg;
}

#pragma 工具方法
//将每一天的打卡时间写入
- (BOOL)setTimeStrWithDateStr:(NSString *)dateStr withTmeStr:(NSString *)timeStr {
    
    NSMutableArray *timeStrArray;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self readFromPlistWithPlistName:dateStr]];
    timeStrArray = [[NSMutableArray alloc] initWithArray:dict[@"array"]];
    [timeStrArray addObject:timeStr];
    NSDictionary *wiriteDict = @{@"count":[NSString stringWithFormat:@"%lu",(unsigned long)timeStrArray.count],@"array":timeStrArray};
    BOOL isSucceed = [self writeToPlist:wiriteDict plistName:dateStr];
    return isSucceed;
}
//记录打卡天数
- (BOOL)setDateStrWithDateStr:(NSString *)dateStr {
    NSMutableArray *dateStrArray;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self readFromPlistWithPlistName:CheckDaysKey]];
    dateStrArray = [[NSMutableArray alloc] initWithArray:dict[@"array"]];
    for (int i=(int)dateStrArray.count; i>0; i--) {
        NSString *str = dateStrArray[i-1];
        if ([str isEqualToString:dateStr]) {
            return NO;
        }
//        NSLog(@"%@",str);
    }
    [dateStrArray addObject:dateStr];
    NSDictionary *wiriteDict = @{@"count":[NSString stringWithFormat:@"%lu",(unsigned long)dateStrArray.count],@"array":dateStrArray};
    BOOL isSucceed = [self writeToPlist:wiriteDict plistName:CheckDaysKey];
    
    return isSucceed;
}
//记录总打卡数
- (void)setCheckingCounts {
    NSString *key = AllCountsKey;
    NSInteger counts = [self getCheckingCounts:key];
    counts++;
    [self saveCheckingCounts:key andCheckingCounts:counts];
}
//返回"@"yyyy_MM_dd""日期串
- (NSString *)getDateStrWith:(NSDate *)nowDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd"];
    NSString *dateStr = [dateFormatter stringFromDate:nowDate];
    return dateStr;
}
//返回"@"HH:mm:ss""日期串
- (NSString *)getTimeStrWith:(NSDate *)nowDate {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeStr = [timeFormatter stringFromDate:nowDate];
    return timeStr;
}
//写入 @{@"日期":打卡时间详情}
- (BOOL)writeToPlist:(NSDictionary *)dict plistName:(NSString *)plistName{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:plistName];
    BOOL isSucceed = [dict writeToFile:filePath atomically:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshDataNoti object:nil];
    return isSucceed;
}
- (NSDictionary *)readFromPlistWithPlistName:(NSString *)plistName{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:plistName];
    NSDictionary *resultDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return resultDict;
}
//写入 @{@"Days":打卡日期详情}
- (void)saveCheckingCounts:(NSString *)CheckingCountsKey andCheckingCounts:(NSInteger)saveCheckingCounts {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setInteger:saveCheckingCounts forKey:CheckingCountsKey];
    [userDefaultes synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshDataNoti object:nil];
}
- (NSInteger )getCheckingCounts:(NSString *)CheckingCountsKey {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSInteger checkingCounts = [userDefaultes integerForKey:CheckingCountsKey];
    return checkingCounts;
}


/*
//清理所有打卡记录,用于调试
- (void)deleSometings {
    
    NSString *key = AllCountsKey;
    [self saveCheckingCounts:key andCheckingCounts:0];
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"filePath:%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}
 */
@end
