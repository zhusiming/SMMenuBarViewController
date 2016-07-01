//
//  SMMenuBarViewController.m
//  SMMenuBarViewController
//
//  Created by 朱思明 on 15/11/19.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//

#import "SMMenuBarController.h"

@interface SMMenuBarController ()

@end

@implementation SMMenuBarController

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"frame"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化子视图
    [self _initMenuBarSubViews];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
/*
 *  通过单例方式创建菜单栏视图控制器对象
 */
+ (SMMenuBarController *)shareSMMenuBarController
{
    static SMMenuBarController *menuBarController = nil;
    @synchronized(self) {
        if (menuBarController == nil) {
            menuBarController = [[SMMenuBarController alloc] init];
        }
    }
    return menuBarController;
}

/*
 *  代码创建对象或者xib文件创建对象调用的初始化方法
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 取消滑动视图内填充
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
            
    }
    return self;
}

/*
 *  storyboard创建控制器对象调用的初始化方法
 */
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // 取消滑动视图内填充
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

/*
 *  自定义初始化方法(创建视图控制器就设置子视图控制器的内容)
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        // 取消滑动视图内填充
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        // 保存属性
        self.viewControllers = viewControllers;
    }
    return self;
}

/*
 *  初始化子视图
 */
- (void)_initMenuBarSubViews
{
    // 1.创建滑动视图
    // 01 子视图控制器内容视图的高度（设置默认高度）
    _contentSizeHeight = self.view.bounds.size.height;
    // 02 创建滑动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _contentSizeHeight)];
    _scrollView.pagingEnabled = YES;
    
/*
#warning 如果模拟器无法滑动可临时设置为yes，真机无问题！如果没有滑动手势冲突可直接设置为yes
    _scrollView.canCancelContentTouches = NO;
*/
    _scrollView.canCancelContentTouches = YES;
    
    _scrollView.delegate = self;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    // 添加滑动视图的观察者模式
    [_scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setEnableScroll:(BOOL)enableScroll {
    
    _enableScroll = enableScroll;
    _scrollView.scrollEnabled = enableScroll;
}

#pragma mark - 设置滑动视图内容高度的 setter
- (void)setContentSizeHeight:(CGFloat)contentSizeHeight
{
    if (_contentSizeHeight != contentSizeHeight) {
        _contentSizeHeight = contentSizeHeight;
        
        // 设置视图的高度
        _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _contentSizeHeight);
        // 设置内容视图的大小
        for (UIView *subView in _scrollView.subviews) {
            subView.frame = CGRectMake(subView.frame.origin.x, 0, subView.frame.size.width, _scrollView.frame.size.height);
        }
    }
}


#pragma mark - viewControlelrs setter
- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
    if (_viewControllers != viewControllers) {
    
        for (UIViewController *viewController in _viewControllers) {
            // 01 移除之前子视图控制器绑定
            [viewController removeFromParentViewController];
            // 02 移除子视图控制器的根视图
            [viewController.view removeFromSuperview];
        }
        // 03 保存当前所有的子视图控制器
        _viewControllers = viewControllers;
        // 04 保存所有的子视图控制器
        for (UIViewController *viewController in _viewControllers) {
            [self addChildViewController:viewController];
        }

        // 05 设置滑动视图内容视图的大小和显示位置
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _viewControllers.count, _scrollView.frame.size.height);
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * _selectedIndex, 0);
        
        // 06 把当前视图控制器的根视图添加到滑动视图上
        // 获取当前显示视图控制器
        UIViewController *displayViewController = _viewControllers[_selectedIndex];
        // 设置将要显示视图控制器根视图的大小和位置
        displayViewController.view.frame = CGRectMake(_scrollView.frame.size.width * _selectedIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        // 将要显示视图控制器的根视图添加到滑动视图上
        [_scrollView addSubview:displayViewController.view];
    }
}

#pragma mark - selectedIndex setter
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex ) {
        // 设置之前视图控制器视图视图消失状态
        UIViewController *disappearViewController = _viewControllers[_selectedIndex];
        // 把当前控制器的根视图从滑动视图上移除
        [disappearViewController.view removeFromSuperview];
        // 设置当前视图选中位置
        _selectedIndex = selectedIndex;
        
        // 01 设置当前滑动视图要显示的位置
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * _selectedIndex, 0);
        // 02 判断将要显示的视图控制器的根视图是否已经添加到滑动视图上
        // 获取当前显示视图控制器
        UIViewController *displayViewController = _viewControllers[_selectedIndex];
        if (displayViewController.view.superview == nil) {
            // 当前控制器的根视图还没添加到滑动视图上
            // 03 设置将要显示视图控制器根视图的大小和位置
            displayViewController.view.frame = CGRectMake(_scrollView.frame.size.width * _selectedIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            // 04 将要显示视图控制器的根视图添加到滑动视图上
            [_scrollView addSubview:displayViewController.view];
        } else {
            // 05 调用将要显示视图控制器将要显示根视图
            [displayViewController viewWillAppear:NO];
            // 06 调用将要显示视图控制器已经显示根视图
            [displayViewController viewDidAppear:NO];
        }
    }
}

- (void)setWillSelectedIndex:(NSInteger)willSelectedIndex
{
    if (_willSelectedIndex != willSelectedIndex) {
        _willSelectedIndex = willSelectedIndex;
        
        // 02 判断将要显示的视图控制器的根视图是否已经添加到滑动视图上
        // 获取当前显示视图控制器
        UIViewController *displayViewController = _viewControllers[_willSelectedIndex];
        if (displayViewController.view.superview == nil) {
            // 当前控制器的根视图还没添加到滑动视图上
            // 03 设置将要显示视图控制器根视图的大小和位置
            displayViewController.view.frame = CGRectMake(_scrollView.frame.size.width * _willSelectedIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            // 04 将要显示视图控制器的根视图添加到滑动视图上
            [_scrollView addSubview:displayViewController.view];
        } else {
            // 05 调用将要显示视图控制器将要显示根视图
            [displayViewController viewWillAppear:YES];
            // 06 调用将要显示视图控制器已经显示根视图
            [displayViewController viewDidAppear:YES];
        }
    }
}

#pragma mark - 修改子视图控制器数组的内容
/*
 *  添加菜单栏控制器的子视图控制器
 */
- (void)addSubViewControlerWithViewController:(UIViewController *)viewController
{
    // 01 容错判断
    if (viewController == nil || ![viewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    // 02 把当前视图控制器，添加到视图控制器数组中
    if (_viewControllers != nil) {
        self.viewControllers = [_viewControllers arrayByAddingObject:viewController];
    } else {
        // 设置当前选中控制器的索引位置
        _selectedIndex = 0;
        self.viewControllers = @[viewController];
    }
}

/*
 *  添加菜单栏控制器的子视图控制器(多个控制器)
 */
- (void)addSubViewControlerWithViewControllers:(NSArray *)viewControllers
{
    // 01 容错判断
    if (viewControllers.count == 0) {
        // 数组中没有元素
        return;
    }
    for (UIViewController *viewController in viewControllers) {
        if (![viewController isKindOfClass:[UIViewController class]]) {
            // 当前数组不是控制器类型对象
            return;
        }
    }
    
    // 02 把当前视图控制器，添加到视图控制器数组中
    if (_viewControllers != nil) {
        self.viewControllers = [_viewControllers arrayByAddingObjectsFromArray:viewControllers];
    } else {
        // 设置当前选中控制器的索引位置
        _selectedIndex = 0;
        self.viewControllers = viewControllers;
    }
}

/*
 *  插入指定视图控制器到（菜单栏控制器的子视图控制器数组的指定索引位置）
 */
- (void)intsertSubViewControlerWithViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    // 01 容错判断
    if (viewController == nil || ![viewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    // 02 把当前视图控制器，添加到视图控制器数组中
    if (_viewControllers != nil) {
        if (_viewControllers.count < index) {
            // 索引值超过最大索引范围，元素追加在数组的最后面
            self.viewControllers = [_viewControllers arrayByAddingObject:viewController];
        } else {
            NSMutableArray *temp = [_viewControllers mutableCopy];
            [temp insertObject:viewController atIndex:index];
            // 设置当前选中控制器的索引位置
            if (index <=_selectedIndex) {
                // 如果插入控制器位置在当前选中索引位置之前，当前选中所以位置后移一位
                _selectedIndex++;
            }
            self.viewControllers = temp;
        }
    } else {
        // 设置当前选中控制器的索引位置
        _selectedIndex = 0;
        self.viewControllers = @[viewController];
    }
}

/*
 *  移除菜单栏控制器中的子视图控制器
 */
- (void)removeSubViewControlerWithViewController:(UIViewController *)viewController
{
    // 01 容错判断
    if (viewController == nil || ![viewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    // 02 把当前视图控制器，添加到视图控制器数组中
    if (_viewControllers != nil) {
        // 移除指定的子视图控制器
        NSMutableArray *temp = [_viewControllers mutableCopy];
        [temp removeObject:viewController];
        self.viewControllers = temp;
    }
}

/*
 *  移除菜单栏控制器中指定位置的子视图控制器
 */
- (void)removeSubViewControlerWithIndex:(NSInteger)index
{
    // 01 容错判断
    if (_viewControllers.count <= index) {
        return;
    }
    
    // 02 把当前视图控制器，添加到视图控制器数组中
    if (_viewControllers != nil) {
        // 移除指定位置的子视图控制器
        NSMutableArray *temp = [_viewControllers mutableCopy];
        [temp removeObjectAtIndex:index];
        if (index == _selectedIndex) {
            // 移除的是当前显示的视图控制器（选中索引控制器回到第一个选中的控制器）
            _selectedIndex = 0;
        } else if (index < _selectedIndex) {
            // 移除的视图控制器是当前选中视图控制器之前的
            _selectedIndex--;
        }
        self.viewControllers = temp;
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging == NO) {
        return;
    }
    // 做连续快速滑动容错判断
    if (ABS(scrollView.contentOffset.x - _selectedIndex * scrollView.frame.size.width) > scrollView.frame.size.width) {
        // 获取当前页数 -- 当前页数处于增加状态
        NSInteger pageIndex = (int)(scrollView.contentOffset.x) / (int)scrollView.frame.size.width;
        // 当前页数处于减少状态
        if (_selectedIndex * scrollView.frame.size.width > scrollView.contentOffset.x) {
            pageIndex += 1;
        }
        if (_selectedIndex != pageIndex) {
            // 设置之前视图控制器视图视图消失状态
            UIViewController *disappearViewController = _viewControllers[_selectedIndex];
            // 把当前控制器的根视图从滑动视图上移除
            [disappearViewController.view removeFromSuperview];
            // 保存当前状态
            _selectedIndex = pageIndex;
            self.selectedIndex = pageIndex;
            _willSelectedIndex = pageIndex;
            // 获取当前显示视图控制器
            UIViewController *displayViewController = _viewControllers[_selectedIndex];
            if (displayViewController.view.superview == nil) {
                // 当前控制器的根视图还没添加到滑动视图上
                // 03 设置将要显示视图控制器根视图的大小和位置
                displayViewController.view.frame = CGRectMake(_scrollView.frame.size.width * _selectedIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
                // 04 将要显示视图控制器的根视图添加到滑动视图上
                [_scrollView addSubview:displayViewController.view];
            } else {
                // 05 调用将要显示视图控制器将要显示根视图
                [displayViewController viewWillAppear:NO];
                // 06 调用将要显示视图控制器已经显示根视图
                [displayViewController viewDidAppear:NO];
            }
        }
    }
    // 01 获取滑动前时页面的便宜位置
    CGFloat startContentOfSet_x = _selectedIndex * scrollView.frame.size.width;
    // 02 获取当前滑动视图的偏移量
    CGFloat newContentOfSet_x = scrollView.contentOffset.x;
    // 03 判断当前用户将要查看的页数
    if (startContentOfSet_x == newContentOfSet_x) {
        if (_willSelectedIndex != _selectedIndex) {
            // 设置之前视图控制器视图视图消失状态
            UIViewController *disappearViewController = _viewControllers[_willSelectedIndex];
            // 把当前控制器的根视图从滑动视图上移除
            [disappearViewController.view removeFromSuperview];
        }
        _willSelectedIndex = _selectedIndex;
    } else if (startContentOfSet_x < newContentOfSet_x) {
        // 用户是将要查看下一页视图内容
        NSInteger willSelectedIndex = _selectedIndex + 1;
        if (_willSelectedIndex != willSelectedIndex && _willSelectedIndex != _selectedIndex) {
            // 设置之前视图控制器视图视图消失状态
            UIViewController *disappearViewController = _viewControllers[_willSelectedIndex];
            // 把当前控制器的根视图从滑动视图上移除
            [disappearViewController.view removeFromSuperview];
        }
        // 保存当前将要查看的索引位置
        self.willSelectedIndex = willSelectedIndex;
    } else {
        // 用户是将要查看上一页视图内容
        NSInteger willSelectedIndex = _selectedIndex - 1;
        if (_willSelectedIndex != willSelectedIndex && _willSelectedIndex != _selectedIndex) {
            // 设置之前视图控制器视图视图消失状态
            UIViewController *disappearViewController = _viewControllers[_willSelectedIndex];
            // 把当前控制器的根视图从滑动视图上移除
            [disappearViewController.view removeFromSuperview];
        }
        // 保存当前将要查看的索引位置
        self.willSelectedIndex = willSelectedIndex;
    }
}

// 滑动视图停止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        // 获取当前页数
        NSInteger pageIndex = (int)(scrollView.contentOffset.x) / (int)scrollView.frame.size.width;
        if (_selectedIndex != pageIndex) {
            // 设置之前视图控制器视图视图消失状态
            UIViewController *disappearViewController = _viewControllers[_selectedIndex];
            // 把当前控制器的根视图从滑动视图上移除
            [disappearViewController.view removeFromSuperview];
            // 保存当亲状态
            _selectedIndex = pageIndex;
            self.selectedIndex = pageIndex;
            _willSelectedIndex = pageIndex;
        } else if (_selectedIndex != _willSelectedIndex) {
            // 设置之前视图控制器视图视图消失状态
            UIViewController *disappearViewController = _viewControllers[_willSelectedIndex];
            // 把当前控制器的根视图从滑动视图上移除
            [disappearViewController.view removeFromSuperview];
            _willSelectedIndex = pageIndex;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 获取当前页数
    NSInteger pageIndex = (int)(scrollView.contentOffset.x) / (int)scrollView.frame.size.width;
    if (_selectedIndex != pageIndex) {
        // 设置之前视图控制器视图视图消失状态
        UIViewController *disappearViewController = _viewControllers[_selectedIndex];
        // 把当前控制器的根视图从滑动视图上移除
        [disappearViewController.view removeFromSuperview];
        // 保存当亲状态
        _selectedIndex = pageIndex;
        self.selectedIndex = pageIndex;
        _willSelectedIndex = pageIndex;
    } else if (_selectedIndex != _willSelectedIndex) {
        // 设置之前视图控制器视图视图消失状态
        UIViewController *disappearViewController = _viewControllers[_willSelectedIndex];
        // 把当前控制器的根视图从滑动视图上移除
        [disappearViewController.view removeFromSuperview];
        _willSelectedIndex = pageIndex;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        // 设置滑动视图的内填充
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _viewControllers.count, _scrollView.frame.size.height);
        // 设置子视图控制器视图的大小 
        for (int i = 0; i < _viewControllers.count; i++) {
            // 获取子视图控制器的根视图
            UIView *rootView = _viewControllers[i].view;
            // 设置视图的位置和大小 
            rootView.frame = CGRectMake(i * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        }
    }
}

@end



/*
 *  -----------------------------------------------
 *  为UIViewController创建类目，获取控制器所在的菜单控制器
 */

@implementation UIViewController (SMMenuBarController)

- (SMMenuBarController *)menuBarControler
{
    //获取当前对象的下一响应者
    id next = [self nextResponder];
    while (next != nil) {
        //判断next对象是否为控制器
        if ([next isKindOfClass:[SMMenuBarController class]]) {
            return next;
        }
        
        //获取next对象的下一响应这
        next = [next nextResponder];
    }
    
    return nil;
}
@end




