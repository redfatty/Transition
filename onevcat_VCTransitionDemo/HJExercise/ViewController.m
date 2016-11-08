//
//  ViewController.m
//  HJExercise
//
//  Created by huangJiong on 16/11/8.
//  Copyright © 2016年 王 巍. All rights reserved.
//

#import "ViewController.h"
#import "HJModalViewController.h"
#import "HJBouncePresentAnimation.h"

@interface ViewController ()<UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) HJBouncePresentAnimation *presentAnimation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (HJBouncePresentAnimation *)presentAnimation {
    if (_presentAnimation == nil) {
        _presentAnimation = [[HJBouncePresentAnimation alloc] init];
    }
    return _presentAnimation;
}


- (IBAction)clickPresentBtn:(id)sender {
    HJModalViewController *toVC = [HJModalViewController loadFromStoryboard];
    toVC.transitioningDelegate = self;
    __weak typeof(self) weakSelf = self;
    [toVC setClickDismissBtnBlock:^(HJModalViewController *targetVC) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:toVC animated:YES completion:nil];
}


#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.presentAnimation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0) {
    return nil;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
