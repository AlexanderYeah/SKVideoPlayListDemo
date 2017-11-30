//
//  SKVideoPlayView.h
//  SKVideoListDemo
//
//  Created by AY on 2017/11/24.
//  Copyright © 2017年 AY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface SKVideoPlayView : UIView

/** play item */
@property (nonatomic,strong)AVPlayerItem *playerItem;
/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;
@end
