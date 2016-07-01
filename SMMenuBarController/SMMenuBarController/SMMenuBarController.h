//
//  SMMenuBarViewController.h
//  SMMenuBarViewController
//
//  Created by 朱思明 on 15/11/19.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMMenuBarController : UIViewController<UIScrollViewDelegate>

/*
 *  是否打开滚动
 */
@property(nonatomic, assign)BOOL enableScroll;

/*
 *  当前菜单栏控制器-子视图控制器的数组
 */
@property (nonatomic, strong) NSArray<__kindof UIViewController *> *viewControllers;

/*
 *  当前菜单栏控制器-所显示子视图控制器的索引位置
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/*
 *  当前菜单栏控制器-将要显示子视图控制器的索引位置
 */
@property (nonatomic, assign) NSInteger willSelectedIndex;

/*
 *  当前菜单栏控制器-滑动视图
 */
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/*
 *  当前菜单栏控制器-当前视图控制器根视图现实的高度 DEFAULT:当前控制器根视图的高度
 *  注意：如果高度不匹配最好重新指定高度
 */
@property (nonatomic, assign) CGFloat contentSizeHeight;


#pragma mark - 方法
/*
 *  通过单例方式创建菜单栏视图控制器对象
 */
+ (SMMenuBarController *)shareSMMenuBarController;

/*
 *  自定义初始化方法(创建视图控制器就设置子视图控制器的内容)
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

/*
 *  添加菜单栏控制器的子视图控制器
 */
- (void)addSubViewControlerWithViewController:(UIViewController *)viewController;

/*
 *  添加菜单栏控制器的子视图控制器(多个控制器)
 */
- (void)addSubViewControlerWithViewControllers:(NSArray *)viewControllers;

/*
 *  插入指定视图控制器到（菜单栏控制器的子视图控制器数组的指定索引位置）
 */
- (void)intsertSubViewControlerWithViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

/*
 *  移除菜单栏控制器中的子视图控制器
 */
- (void)removeSubViewControlerWithViewController:(UIViewController *)viewController;

/*
 *  移除菜单栏控制器中指定位置的子视图控制器
 */
- (void)removeSubViewControlerWithIndex:(NSInteger)index;


@end

/*
 *  -----------------------------------------------
 *  为UIViewController创建类目，获取控制器所在的菜单控制器
 */

@interface UIViewController (SMMenuBarController)

@property (nonatomic, weak,readonly) SMMenuBarController *menuBarControler;

@end