//
//  ViewController.m
//  AVPlayerTest
//
//  Created by niuniuzhang on 17/5/5.
//  Copyright © 2017年 niuniuzhang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupURL];
    [self setupUI];

    [self.player play];
}

-(void)setupUI {
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.container.bounds;
    [self.container.layer addSublayer:playerLayer];
    
    [playerLayer setPlayer:self.player];
}

-(void)setupURL {
    NSURL *videoUrl = [NSURL URLWithString:@"http://dldir1.qq.com/qqtv/exp/VRdemo-1080p.mp4"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDir = [documentPaths objectAtIndex:0];
    NSError* error = nil;
    NSArray* fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    for (NSString* file in fileList) {
        NSString* path = [documentDir stringByAppendingPathComponent:file];
        NSLog(@"file: %@", path);
        NSURL* url = [NSURL fileURLWithPath:path];
        videoUrl = url;
    }
    NSLog(@"setupURL, %@", videoUrl);
    
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CMTime currentTime = self.player.currentTime;
        CMTime totalTime = self.player.currentItem.duration;
        NSLog(@"playing, %f/%f", CMTimeGetSeconds(currentTime), CMTimeGetSeconds(totalTime));
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem*)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            CMTime duration = self.playerItem.duration;
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale; // 转换成秒
            NSLog(@"duration, %f", totalSecond);
            
        } else if ([playerItem status] == AVPlayerItemStatusFailed) {
            NSLog(@"AVPlayerStatusFailed!");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
//        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        NSLog(@"Buffering, %f%%", timeInterval / totalDuration * 100);
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

-(void)moviePlayDidEnd {
    NSLog(@"moviePlayDidEnd");
    Float64 seconds = 0.0f;
    CMTime targetTime = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
    [self.player seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished){
        [self.player play];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
