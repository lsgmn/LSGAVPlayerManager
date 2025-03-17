//
//  LSGAVPlayerManager.m
//  LSGPlayer
//
//  Created by jack on 2025/3/17.
//

#import "LSGAVPlayerManager.h"
@interface LSGAVPlayerManager ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic, strong) NSURL *localFileURL;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isUsingSpeaker;  // 记录当前播放模式

@end

@implementation LSGAVPlayerManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _player = [[AVPlayer alloc] init];
        _isPlaying = NO;
        _isUsingSpeaker = YES;  // 默认使用扬声器
        [self toggleSpeaker:YES]; // 默认扬声器播放
        [self addAudioRouteChangeObserver]; // 监听耳机插拔

    }
    return self;
}

- (void)setPlayURL:(NSURL *)url localFileURL:(NSURL *)localFileURL {
    _originalURL = url;
    _localFileURL = localFileURL;
    
    if (url) {
        [self setupPlayerWithURL:url];
    } else if (localFileURL) {
        [self setupPlayerWithURL:localFileURL];
    } else {
        NSLog(@"❌ 无效的播放 URL");
    }
}

- (void)setupPlayerWithURL:(NSURL *)url {
    if (!url) return;
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.currentItem = item;
    [self.player replaceCurrentItemWithPlayerItem:item];
    
    [self addObservers];
}

/// 监听耳机 & 蓝牙耳机插拔事件
- (void)addAudioRouteChangeObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

/// 处理耳机 & 蓝牙耳机插拔
- (void)handleAudioRouteChange:(NSNotification *)notification {
    AVAudioSessionRouteChangeReason reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    [AVAudioSession sharedInstance];

    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"🎧 新音频设备连接，尝试切换播放方式");
            [self updateAudioRoute];
            break;

        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"🔌 音频设备断开，切换到扬声器");
            [self toggleSpeaker:YES];
            break;

        default:
            break;
    }
}

/// 检测当前音频输出设备并调整
- (void)updateAudioRoute {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *route = session.currentRoute;

    for (AVAudioSessionPortDescription *output in route.outputs) {
        if ([output.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
            [output.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [output.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            NSLog(@"🎧 连接的是 %@，切换到耳机播放", output.portType);
            [self toggleSpeaker:NO];
            return;
        }
    }

    NSLog(@"🔊 没有检测到耳机，切换到扬声器");
    [self toggleSpeaker:YES];
}

/// 切换扬声器 / 耳机 / 蓝牙耳机
- (void)toggleSpeaker:(BOOL)useSpeaker {
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];

    if (useSpeaker) {
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    } else {
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                       error:&error];
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    }

    [session setActive:YES error:&error];

    if (error) {
        NSLog(@"⚠️ 切换音频失败: %@", error.localizedDescription);
    }
}




#pragma mark - 播放控制

- (void)play {
    if (self.player && self.currentItem) {
        [self.player play];
        self.isPlaying = YES;
        [self updatePlayerStatus:PlayerSimpleStatusPlaying];
    }
}

- (void)pause {
    if (self.player) {
        [self.player pause];
        self.isPlaying = NO;
        [self updatePlayerStatus:PlayerSimpleStatusNotPlaying];
    }
}

- (void)stop {
    [self.player pause];
    self.isPlaying = NO;
    [self updatePlayerStatus:PlayerSimpleStatusNotPlaying];
}

#pragma mark - 观察者处理

- (void)addObservers {
    if (self.currentItem) {
        [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    }
}

- (void)removeObservers {
    if (self.currentItem) {
        [self.currentItem removeObserver:self forKeyPath:@"status"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerDidFinishPlaying {
    self.isPlaying = NO;
    [self updatePlayerStatus:PlayerSimpleStatusNotPlaying];
}

#pragma mark - 监听播放状态

- (void)updatePlayerStatus:(PlayerSimpleStatus)status {
    if ([self.delegate respondsToSelector:@selector(playerStatusChanged:)]) {
        [self.delegate playerStatusChanged:status];
    }
}

/// KVO 监听 AVPlayerItem 状态
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.currentItem.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                break;
            case AVPlayerItemStatusFailed:
                [self handlePlaybackFailure];
                break;
            default:
                break;
        }
    }
}

#pragma mark - 处理播放失败

- (void)handlePlaybackFailure {
    if (self.localFileURL) {
        NSLog(@"网络播放失败，尝试播放本地文件...");
        [self setupPlayerWithURL:self.localFileURL];
        [self play];
    } else {
        NSLog(@"播放失败（无本地文件可用）");
        self.isPlaying = NO;
        [self updatePlayerStatus:PlayerSimpleStatusNotPlaying];
    }
}

#pragma mark - 释放资源

- (void)dealloc {
    [self removeObservers];
}

@end
