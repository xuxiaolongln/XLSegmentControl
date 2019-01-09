//
//  XLSegmentControlProtocol.h
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2019/1/3.
//

#import <Foundation/Foundation.h>
#import "XLSegmentControlDef.h"

NS_ASSUME_NONNULL_BEGIN
@protocol XLSegmentControlProtocol,XLSegmentControlIndicatorProtocol,XLSegmentControlScrollViewProtocol;
#pragma mark - 角标数据源方法
@protocol XLSegmentControlDataSource <NSObject>
/** 为指定的item添加角标 */
- (UIView *)segmentControl:(id<XLSegmentControlProtocol>)segmentControl bageViewAtIndex:(NSInteger)index;
/** 每个角标的偏移量，默认(0,10,5,0) */
- (UIEdgeInsets)segmentControl:(id<XLSegmentControlProtocol>)segmentControl edgeInsetsAtIndex:(NSInteger)index;
/** 每个角标相对于文字的位置,默认为(1,0) 即bageView的左下角对应文字右上角，范围0~1*/
- (CGPoint)segmentControl:(id<XLSegmentControlProtocol>)segmentControl bagePointAtIndex:(NSInteger)index;

@end

@protocol XLSegmentControlProtocol <NSObject,XLSegmentControlIndicatorProtocol,XLSegmentControlScrollViewProtocol>

/** 标题数组 */
@property(nonatomic, strong)NSArray *titles;
/** 当前选中index */
@property (nonatomic, assign) NSUInteger selectedSegmentIndex;
/** 宽度类型 */
@property (nonatomic, assign) XLSegmentedControlWidthStyle widthStyle;
/** 文字位置，默认：BPRSegmentedControlTextPositionMiddle */
@property(nonatomic, assign)XLSegmentedControlTextPosition textPosition;
/** 当前segment的整体宽度 */
@property(nonatomic, assign,readonly)CGFloat segmentTotalWidth;
/** 是否展示底部阴影 默认为NO */
@property(nonatomic, assign,getter=isShowBottomShadow)BOOL showBottomShadow;
/** 是否显示动画 默认为NO*/
@property (nonatomic) BOOL textAnimate;
/** 水平间距 默认24 */
@property (nonatomic, assign) CGFloat horizontalPadding;
/** 上下左右内边距 Default is UIEdgeInsetsMake(0, 10, 5, 10)*/
@property (nonatomic, readwrite) UIEdgeInsets segmentEdgeInset;
/** 刷新数据 */
- (void)reloadData;


/** 设置字体颜色*/
- (void)setTextAttributes:(nullable NSDictionary *)attributes forState:(UIControlState)state;
/** 设置整体的背景色(如果有Indicator，则也会修改Indicator的颜色) */
- (void)segmentControlChangeBackgroundWithTargetColor:(UIColor *)targetColor;
/** 设置当前index */
- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex ignoreAction:(BOOL)ignoreAction;
/** 设置当前index */
- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animation:(BOOL)animation;

/** 插入标题 */
- (void)insertTitle:(NSString *)title atIndex:(NSUInteger)index;
/** 移除某个标题 */
- (void)removeTitleAtIndex:(NSUInteger)index;
/** 替换某个标题 */
- (void)replaceTitle:(NSString *)title atIndex:(NSUInteger)index;

@end

#pragma mark - Indicator
@protocol XLSegmentControlIndicatorProtocol <NSObject>

/** 是否显示底部Indicator */
@property (nonatomic, assign, getter=isShowsIndicator) BOOL showsIndicator;
/** Indicator样式 */
@property (nonatomic, assign) XLSegmentControlIndicatorWidthStyle indicatorWidthStyle;
/** Indicator高度 默认6，
 indicatorWidthStyle=BPRSegmentedControlWidthStyleBackground时无效
 */
@property (nonatomic, assign) CGFloat indicatorHeight;
/**
 Indicator默认为文字宽高，设置此属性，表示上下左右向外扩展的大小
 indicatorWidthStyle=BPRSegmentedControlWidthStyleBackground时生效
 默认为 UIEdgeInsetsMake(5, 12, 5, 12)
 */
@property (nonatomic, readwrite) UIEdgeInsets indicatorContentOffset;
/** Indicator执行动画的最大宽度 默认 50 */
@property (nonatomic, assign) CGFloat indicatorMaxWidth;
/** Indicator默认展示宽度 默认 24 */
@property (nonatomic, assign) CGFloat indicatorMinWidth;
/** Indicator背景色 默认 Black */
@property (nonatomic, strong) UIColor *indicatorBackgroundColor;
/** Indicator距离segment的距离 默认距离顶部是5 */
@property(nonatomic, assign)CGFloat indicatorMarginTop;
/** 是否显示indicator动画 */
@property(nonatomic, assign)BOOL indicatorAnimation;

@end

#pragma mark - UIScrollViewDelegate_Add
@protocol XLSegmentControlScrollViewProtocol <NSObject>

- (void)segmentControlDidScroll:(UIScrollView *)scrollView;

- (void)segmentControlDidEndDecelerating:(UIScrollView *)scrollView;

- (void)segmentControlDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
