//
//  ViewController.m
//  SKVideoListDemo
//
//  Created by AY on 2017/11/24.
//  Copyright © 2017年 AY. All rights reserved.
//

#import "ViewController.h"
#define kVideoCellHeight SCREENH_HEIGHT *  0.3
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#import "SKVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 主 tableview */
@property (nonatomic,strong)UITableView *mainTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self createMainTB];
}
#pragma mark - 1 UI 搭建
- (void)createMainTB
{
	
    self.mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, SCREENH_HEIGHT - 44) style:UITableViewStylePlain];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.mainTableView.showsVerticalScrollIndicator = NO;
	self.mainTableView.bounces = NO;
    [self.view addSubview:self.mainTableView];

}
#pragma mark - 2 数据请求

#pragma mark - 3 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
	
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cellID";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
	
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	SKVideoPlayView *videoView = [[SKVideoPlayView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kVideoCellHeight)];
	// @"http://flv2.bn.netease.com/tvmrepo/2017/3/M/1/ECEIM9AM1/SD/ECEIM9AM1-mobile.mp4"
	NSString *path = [[NSBundle mainBundle]pathForResource:@"test.mp4" ofType:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://flv2.bn.netease.com/tvmrepo/2017/3/M/1/ECEIM9AM1/SD/ECEIM9AM1-mobile.mp4"]];
	
	[videoView setPlayerItem:item];
	
	[cell addSubview:videoView];
	
    return cell;
	

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	return kVideoCellHeight;
	
}
#pragma mark - 4 方法抽取

#pragma mark - 5 事件响应



- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
