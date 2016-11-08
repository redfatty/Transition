//
//  HJModalViewController.h
//  VCTransitionDemo
//
//  Created by huangJiong on 16/11/8.
//  Copyright © 2016年 王 巍. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJModalViewController : UIViewController

@property (nonatomic, copy) void(^clickDismissBtnBlock)(HJModalViewController *targetVC);

+ (instancetype)loadFromStoryboard;

@end
