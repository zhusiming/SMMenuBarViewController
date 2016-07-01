//
//  RootViewController.m
//  SMMenuBarViewController
//
//  Created by 朱思明 on 15/11/19.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//

#import "RootViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 01 设置当前控制器的子视图控制器
    FirstViewController *firstVC = [[FirstViewController alloc] init];
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    ThirdViewController *thirdVC = [[ThirdViewController alloc] init];
    
    self.viewControllers = @[firstVC,secondVC,thirdVC];
    
    // 设置滑动视图的位置
    self.scrollView.frame = CGRectMake(0, 100, self.scrollView.frame.size.width, self.scrollView.frame.size.height - 100);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
