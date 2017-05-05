//
//  ViewController.h
//  AVPlayerTest
//
//  Created by niuniuzhang on 17/5/5.
//  Copyright © 2017年 niuniuzhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;

@property (weak, nonatomic) IBOutlet UIView *container;

@end

