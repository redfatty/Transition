//
//  HJModalViewController.m
//  VCTransitionDemo
//
//  Created by huangJiong on 16/11/8.
//  Copyright © 2016年 王 巍. All rights reserved.
//

#import "HJModalViewController.h"

@interface HJModalViewController ()

@end

@implementation HJModalViewController

+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HJModalViewController *vc = [sb instantiateViewControllerWithIdentifier:@"HJModalViewController"];
    return vc;
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickDismissBtn:(id)sender {
    if (_clickDismissBtnBlock) {
        _clickDismissBtnBlock(self);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
