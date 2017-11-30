//
//  SKVideoPlayView.m
//  SKVideoListDemo
//
//  Created by AY on 2017/11/24.
//  Copyright © 2017年 AY. All rights reserved.
//

#import "SKVideoPlayView.h"
#define SFRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface SKVideoPlayView()


/** 播放器的Layer*/
@property (weak, nonatomic) AVPlayerLayer *playerLayer;
/**记录当前是否显示了工具栏*/
@property (assign, nonatomic) BOOL isShowToolView;
/** 定时器 */
@property (nonatomic, strong) NSTimer *progressTimer;
/** imageView */
@property (nonatomic,strong)UIImageView *videoBgImgView;
/** 播放和暂停按钮 */
@property (nonatomic,strong)UIButton *playAndPauseBtn;
/** 工具栏view */
@property (nonatomic,strong)UIView *toolView;
/** 进度条 */
@property (strong, nonatomic)UISlider *progressSlider;
/** 时间显示 */
@property (strong, nonatomic)UILabel *timeLabel;
/**记录当前视频正在播放*/
@property (assign, nonatomic) BOOL isPlayNow;

@end

@implementation SKVideoPlayView

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self createUI];
	}
	return self;
}

/** 创建UI界面 */
- (void)createUI
{
	
	//http://flv2.bn.netease.com/tvmrepo/2017/3/M/1/ECEIM9AM1/SD/ECEIM9AM1-mobile.mp4
	self.videoBgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	self.videoBgImgView.userInteractionEnabled = YES;
	// self.videoBgImgView.backgroundColor = SFRandomColor;
	[self addSubview:self.videoBgImgView];
	
	self.player = [[AVPlayer alloc] init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.frame = self.bounds;
    [self.videoBgImgView.layer addSublayer:self.playerLayer];
	
	self.isPlayNow = NO;
	self.isShowToolView = NO;
	// 给背景图加一个Tap 点击显示toolView 再次点击消失
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoImgViewTap:)];
	
	tap.numberOfTapsRequired = 1;
	[self.videoBgImgView addGestureRecognizer:tap];
	
	
	
	// 播放和暂停按钮
	_playAndPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[_playAndPauseBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
	_playAndPauseBtn.frame = CGRectMake(SCREEN_WIDTH/2 - 25, self.frame.size.height/2 - 25, 50, 50);
	[_playAndPauseBtn addTarget:self action:@selector(playAndPauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[self.videoBgImgView addSubview:_playAndPauseBtn];
	
	[self createToolView];
	
	
}

/** 添加process slider */
- (void)createToolView
{
	// 背景view
	self.toolView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 35, SCREEN_WIDTH, 35)];
	self.toolView.userInteractionEnabled = YES;
	self.toolView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];
	[self.videoBgImgView addSubview:self.toolView];
	
	
	// 进度条
	CGFloat slider_left_padding = 15;
	self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(slider_left_padding, 0, SCREEN_WIDTH/3 * 2, 35)];
	[self.progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.progressSlider addTarget:self action:@selector(sliderHasDone:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.progressSlider setThumbImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.progressSlider setMinimumTrackImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
	[self.toolView addSubview:self.progressSlider];
	
	// 时间显示Lbl
	_timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/3 * 2 + slider_left_padding, 0, SCREEN_WIDTH/3 - slider_left_padding, 30)];
	_timeLabel.text = [self stringWithCurrentTime:0 duration:CMTimeGetSeconds(self.player.currentItem.duration)];
	_timeLabel.textAlignment = NSTextAlignmentCenter;
	[self.toolView addSubview:_timeLabel];
	
	
	
}

/** 创建一个定时器,当视频开始播放的时候,更新slider value 和 时间的显示 */
- (void)addProcessTimer
{
	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateToolInfo) userInfo:nil repeats:YES];
	
	// 加入主运行循环
	[[NSRunLoop mainRunLoop]addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

// 移除定时器
- (void)removeTimer{
	
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

#pragma mark - 设置播放的视频
- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    _playerItem = playerItem;
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
	
	_timeLabel.text = [self stringWithCurrentTime:0 duration:CMTimeGetSeconds(self.player.currentItem.duration)];
	
	
}

#pragma mark - 播放
- (void)playAndPauseBtnClick:(UIButton *)btn
{
	// 播放或者暂停按钮的点击

	
		// 1 开启定时器
		[self addProcessTimer];
		// 2 播放
		[self.player play];
		// 3 按钮移除
		self.playAndPauseBtn.hidden = YES;
	
		self.isPlayNow = YES;
	
		[UIView animateWithDuration:0.5 animations:^{
			self.toolView.alpha = 0;
			self.isShowToolView = NO;
		}];
	
}

#pragma mark -  背景tap 点击
- (void)videoImgViewTap:(UITapGestureRecognizer *)tap
{
	[UIView animateWithDuration:0.5 animations:^{
        if (self.isShowToolView) {
            self.toolView.alpha = 0;
            self.isShowToolView = NO;

			
        } else {
            self.toolView.alpha = 1;
            self.isShowToolView = YES;
			self.playAndPauseBtn.hidden = NO;
			// 1 移除定时器
			[self removeTimer];
			// 2 暂停
			[self.player pause];
			
			self.isPlayNow = NO;
        }
    }];

}

#pragma mark - 定时器调用的方法
-(void)updateToolInfo{

	// 1.更新时间
	NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    self.timeLabel.text = [self stringWithCurrentTime:currentTime duration:duration];
    
    // 2.设置进度条的value
    self.progressSlider.value = CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);

}

#pragma mark - sliderValueChanged
- (void)sliderValueChanged:(UISlider *)slider
{
	// 进度条当前显示的值
	NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * self.progressSlider.value;
	// player 视频的总长度
	NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
	
	// 显示在时间Lbl上面
	self.timeLabel.text = [self stringWithCurrentTime:currentTime duration:duration];

}

#pragma mark - slider has done 滑动完成 更新视频进度
- (void)sliderHasDone:(UISlider *)slider
{
	
	
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * self.progressSlider.value;
	// 设置当前播放时间
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	
	if (self.isPlayNow) {
			
		[self addProcessTimer];
		[self.player play];
	}else{
	
		
	}

}

#pragma mark - 将时间显示在timeLbl 上面
- (NSString *)stringWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration
{
	// 总长度
	NSInteger totalMin = duration/60;
	NSInteger totalSec = (NSInteger)duration % 60;
	
	// 当前长度
	NSInteger curMin = currentTime / 60;
	NSInteger curSec = (NSInteger)currentTime % 60;
	
	NSString *totalString = [NSString stringWithFormat:@"%02ld:%02ld", totalMin, totalSec];
	NSString *curString = [NSString stringWithFormat:@"%02ld:%02ld", curMin, curSec];
	
	NSString *resStr = [NSString stringWithFormat:@"%@/%@",curString,totalString];
	return resStr;
}



@end
