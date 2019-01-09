//
//  XLViewController.m
//  XLSegmentControl
//
//  Created by xxl379786230 on 12/29/2018.
//  Copyright (c) 2018 xxl379786230. All rights reserved.
//

#import "XLViewController.h"
#import <XLSegmentControl.h>

@interface XLViewController ()<UIScrollViewDelegate>
@property(nonatomic, strong)XLSegmentControl *segment;
@property(nonatomic, weak)UIImageView *imageView;
@property(nonatomic, weak)UIImageView *imageView1;
@property(nonatomic, weak)UIImageView *imageView2;
@property(nonatomic, weak)UIImageView *imageView3;

@property(nonatomic, strong)UIScrollView *bgView;
@end

@implementation XLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.segment];
    [self.view addSubview:self.bgView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    _imageView = imageView;
    imageView.backgroundColor = [UIColor redColor];
    [_bgView addSubview:imageView];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, 200)];
    _imageView1 = imageView1;
    imageView1.backgroundColor = [UIColor orangeColor];
    [_bgView addSubview:imageView1];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, 200)];
    _imageView2 = imageView2;
    imageView2.backgroundColor = [UIColor blueColor];
    [_bgView addSubview:imageView2];
    
    _bgView.contentSize = CGSizeMake(self.view.frame.size.width * 3, 200);
}

- (XLSegmentControl *)segment{
    if (!_segment) {
        _segment = [[XLSegmentControl alloc] initWithTitles:@[@"附近动态",@"附近的人",@"直播"]];
        _segment.frame = CGRectMake(0, 44, self.view.frame.size.width, 60);
        _segment.showsIndicator = YES;
        _segment.textAnimate = YES;
        _segment.horizontalPadding = 30;
        _segment.showBottomShadow = YES;
        _segment.indicatorMinWidth = 24;
        _segment.indicatorMaxWidth = 50;
        _segment.indicatorHeight = 6;
        _segment.indicatorAnimation = NO;
        _segment.indicatorBackgroundColor = [UIColor redColor];
        _segment.widthStyle = XLSegmentedControlWidthStyleDynamic;
        _segment.indicatorWidthStyle = XLSegmentControlIndicatorWidthStyleShort;
        _segment.segmentEdgeInset = UIEdgeInsetsMake(0, 20, 15, 20);
        [_segment setTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:16],
                                      NSForegroundColorAttributeName: [UIColor blackColor]
                                      }
                           forState:UIControlStateNormal];
        [_segment setTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:24],
                                      NSForegroundColorAttributeName:[UIColor redColor]
                                      }
                           forState:UIControlStateSelected];
        _segment.indicatorHeight = 6;
        _segment.indicatorMinWidth = 24;
        
        [_segment addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

- (UIScrollView *)bgView{
    if (!_bgView) {
        _bgView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 200)];
        _bgView.delegate = self;
        _bgView.pagingEnabled = YES;
    }
    return _bgView;
}

- (void)segmentChange:(XLSegmentControl *)segment {
    NSUInteger selectIndex = segment.selectedSegmentIndex;
    [_bgView setContentOffset:CGPointMake(_bgView.frame.size.width*selectIndex, 0) animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_segment segmentControlDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_segment segmentControlDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [_segment segmentControlDidEndScrollingAnimation:scrollView];
}

@end
