//
//  LSGAVPlayerManager.h
//  LSGPlayer
//
//  Created by jack on 2025/3/17.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, PlayerSimpleStatus) {
    PlayerSimpleStatusPlaying,    // 播放中
    PlayerSimpleStatusNotPlaying  // 非播放中（暂停、停止、失败）
};

@protocol LSGAVPlayerManagerDelegate <NSObject>
@optional
- (void)playerStatusChanged:(PlayerSimpleStatus)status;
@end
NS_ASSUME_NONNULL_BEGIN

@interface LSGAVPlayerManager : NSObject

@property (nonatomic, weak) id<LSGAVPlayerManagerDelegate> delegate;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, assign, readonly) BOOL isPlaying;  // 公开的播放状态（YES = 播放中）
@property (nonatomic, assign, readonly) BOOL isUsingSpeaker;  // 是否使用扬声器


/// 初始化播放器（不需要立即提供播放地址）
- (instancetype)init;

/// 设置播放 URL（支持网络 URL + 本地文件）
- (void)setPlayURL:(NSURL *_Nullable)url localFileURL:(NSURL * _Nullable)localFileURL;

/// 切换扬声器 / 听筒播放
- (void)toggleSpeaker:(BOOL)useSpeaker;

/// 开始播放
- (void)play;

/// 暂停播放
- (void)pause;

/// 停止播放
- (void)stop;
@end

NS_ASSUME_NONNULL_END
