//
//  XLSegmentControl.m
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2018/12/29.
//

#import "XLSegmentControl.h"
#import "XLSegmentControlDef.h"
#import "XLSegmentScrollView.h"
#import "XLSegmentControlItem.h"
#import "UIView+XLSegment.h"
#import "XLSegmentHelper.h"

typedef XLSegmentControlItem Item;
@interface XLSegmentControl ()<UIScrollViewDelegate>{
    dispatch_source_t _timer;
}
@property(nonatomic, strong)XLSegmentScrollView *container;
@property (nonatomic, strong, readwrite) UIView *indicator;
@property(nonatomic, strong)NSArray *curTitles;
@property(nonatomic, assign)CGFloat minFontSize;
@property(nonatomic, assign)CGFloat maxFontSize;
/** 存放所有Label及其父视图的数组 */
@property(nonatomic, strong)NSMutableArray<Item *> *items;
/** 用来标志是否是点击切换 */
@property(nonatomic, assign)BOOL isChangeByClick;
/** Normal */
@property (nonatomic, copy) NSDictionary *attributesNormal;
/** Select */
@property (nonatomic, copy) NSDictionary *attributesSelected;
/** 初始选中的rect */
@property(nonatomic, assign)CGRect selectOriginRect;
/** 动态改变背景色所需要的临时变量 */
@property(nonatomic, strong)UIColor *targetColor;
/** 数据源方法 */
@property(nonatomic, weak)id<XLSegmentControlDataSource> dataSource;
/** 标题到底部的距离 */
@property(nonatomic, assign)CGFloat titleBottomMargin;
/** 当前Segment是否正在执行动画 */
@property(nonatomic, assign)BOOL isAnimation;
/** 动画剩余时间 */
@property(nonatomic, assign)NSTimeInterval animationTimeout;

@end

@implementation XLSegmentControl
@synthesize horizontalPadding = _horizontalPadding;
@synthesize indicatorAnimation = _indicatorAnimation;
@synthesize indicatorBackgroundColor = _indicatorBackgroundColor;
@synthesize indicatorContentOffset = _indicatorContentOffset;
@synthesize indicatorHeight = _indicatorHeight;
@synthesize indicatorMarginTop = _indicatorMarginTop;
@synthesize indicatorMaxWidth = _indicatorMaxWidth;
@synthesize indicatorMinWidth = _indicatorMinWidth;
@synthesize indicatorWidthStyle = _indicatorWidthStyle;
@synthesize segmentEdgeInset = _segmentEdgeInset;
@synthesize segmentTotalWidth = _segmentTotalWidth;
@synthesize selectedSegmentIndex = _selectedSegmentIndex;
@synthesize showBottomShadow = _showBottomShadow;
@synthesize showsIndicator = _showsIndicator;
@synthesize textAnimate = _textAnimate;
@synthesize textPosition = _textPosition;
@synthesize widthStyle = _widthStyle;
@synthesize titles = _titles;

#pragma mark - LifeCycle
- (instancetype)initWithTitles:(NSArray <NSString *> *)titles{
    if (self = [super init]) {
        _curTitles = titles;
        _attributesNormal = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                              NSForegroundColorAttributeName: [UIColor lightGrayColor]};
        _attributesSelected = [_attributesNormal copy];
        [self _commonInit];
        [self _setUpViews];
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray <NSString *> *)titles dataSource:(id<XLSegmentControlDataSource>)dataSource{
    _dataSource = dataSource;
    return [self initWithTitles:titles];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.container.frame = self.bounds;
    [self _updateFrame];
    [self _updateBageFrame];
    [self _updateIndicatorFrame];
    [self _updateShadow];
    [self _updateAttribute];
}

#pragma mark - Private
- (void)_commonInit{
    self.backgroundColor = [UIColor whiteColor];
    _minFontSize = 16;
    _maxFontSize = 24;
    _selectedSegmentIndex = 0;
    _segmentEdgeInset = UIEdgeInsetsMake(0, 10, 5, 10);
    _indicatorContentOffset = UIEdgeInsetsMake(5, 12, 5, 12);
    _horizontalPadding = 24;
    _textAnimate = NO;
    _indicatorWidthStyle = XLSegmentControlIndicatorWidthStyleText;
    _widthStyle = XLSegmentedControlWidthStyleDynamic;
    _showsIndicator = NO;
    _indicatorHeight = 6.0;
    _indicatorMinWidth = 24;
    _indicatorMaxWidth = 50;
    _indicatorMarginTop = 5;
    _showBottomShadow = NO;
    _textPosition = XLSegmentedControlTextPositionMiddle;
    _indicatorAnimation = YES;
}

- (void)_setUpViews{
    [self addSubview:self.container];
    for (int i = 0; i < self.curTitles.count; i++) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
        
        XLSegmentControlItem *item = [[XLSegmentControlItem alloc] initWithView:label];
        //判断是否存在角标视图
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentControl:bageViewAtIndex:)]) {
            UIView *bageView = [self.dataSource segmentControl:self bageViewAtIndex:i];
            if (bageView) {
                bageView.tag = XLSegmentBageViewBaseTag + i;
                [item addSubview:bageView];
            }
        }
        [self.items addObject:item];
        [self.container addSubview:item];
    }
}

- (void)_updateFrame{
    //获取普通状态下文字高度
    UIFont *font = self.attributesNormal[NSFontAttributeName];
    _titleBottomMargin = _textPosition == XLSegmentedControlTextPositionMiddle ? (self.height - font.pointSize) / 2 : _segmentEdgeInset.bottom;
    __block CGFloat xoffset = _segmentEdgeInset.left;
    __block CGFloat totalW = 0;
    __block CGRect targetRect = CGRectZero;
    [self.curTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGSize textSize = [self measureTitleAtIndex:idx];
        CGFloat width = textSize.width;
        CGFloat height = textSize.height;
        
        //获取宽度
        Item *item = [self.items objectAtIndex:idx];
        item.label.layer.anchorPoint = CGPointMake(0, 1);
        CGFloat labelY = self.height - height - self->_titleBottomMargin;
        if (idx == 0) {
            if (self.widthStyle == XLSegmentedControlWidthStyleDynamic) {
                item.frame = CGRectMake(xoffset, 0, width, self.height);
                item.label.frame = CGRectMake(0, labelY, width, height);
            }else{
                CGFloat itemW = MAX(CGRectGetWidth(self.bounds) / self.curTitles.count, XLSegmentWidthMinmum);
                item.frame = CGRectMake(0, 0, itemW, self.height);
                item.label.textAlignment = NSTextAlignmentCenter;
                item.label.frame = CGRectMake((item.width - width) / 2,labelY , width, height);
            }
            self.selectOriginRect = item.label.frame;
            targetRect = item.frame;
        }else{
            if (self.widthStyle == XLSegmentedControlWidthStyleDynamic) {
                item.frame = CGRectMake(CGRectGetMaxX(targetRect) + self.horizontalPadding, 0, width, self.height);
                item.label.frame = CGRectMake(0, labelY, width, height);
            }else{
                CGFloat itemW = MAX(CGRectGetWidth(self.bounds) / self.curTitles.count, XLSegmentWidthMinmum);
                item.frame = CGRectMake(CGRectGetMaxX(targetRect), 0, itemW, self.height);
                item.label.textAlignment = NSTextAlignmentCenter;
                item.label.frame = CGRectMake((item.width - width) / 2,labelY, width, height);
            }
            targetRect = item.frame;
        }
        totalW = CGRectGetMaxX(targetRect);
    }];
    CGFloat contentSizeW = _widthStyle == XLSegmentedControlWidthStyleDynamic ? totalW + _segmentEdgeInset.right : self.width;
    self.container.contentSize = CGSizeMake(contentSizeW, self.height);
}

- (void)_updateShadow{
    //是否展示底部shadow
    if (_showBottomShadow) {
        self.backgroundColor = [UIColor whiteColor];
        [self XL_SetShadowPathWith:_targetColor ? [UIColor clearColor] : [UIColor blackColor] shadowOpacity:XLSegmentShadowOpacity shadowRadius:XLSegmentShadowRadius shadowSide:XLShadowPathBottom shadowPathWidth:XLSegmentShadowPathWidth];
    }else{
        self.backgroundColor = [UIColor clearColor];
        [self XL_SetShadowPathWith:[UIColor blackColor] shadowOpacity:0 shadowRadius:0 shadowSide:XLShadowPathBottom shadowPathWidth:0];
    }
    //添加阴影
    if (_indicatorWidthStyle != XLSegmentControlIndicatorWidthStyleBackground) {
        [_indicator XL_SetShadowPathWith:_indicatorBackgroundColor shadowOpacity:XLIndicatorShadowOpacity shadowRadius:XLIndicatorShadowRadius shadowSide:XLShadowPathBottom shadowPathWidth:XLIndicatorShadowPathWidth];
    }
}

- (void)_updateAttribute{
    if (_selectedSegmentIndex > 0) {
        [self _segmentDidSelectAtIndex:_selectedSegmentIndex didDeselectAtIndex:0 ignoreAction:NO animation:NO];
    }
    for (int i = 0; i < _items.count; i++) {
        Item *item = _items[i];
        if (i == _selectedSegmentIndex) {
            NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[i]  attributes:self.attributesSelected];
            item.label.attributedText = mutableAttributed;
        }else{
            NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[i]  attributes:self.attributesNormal];
            item.label.attributedText = mutableAttributed;
        }
    }
}

- (void)_updateRectsWithScrollView:(UIScrollView *)scrollView{
    //获取当前的view和目标View
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollWidth = scrollView.frame.size.width;
    if (offsetX < 0) return;
    //获取当前index，和目标index
    int tempIndex = (offsetX / scrollWidth);
    if (fmod((double)offsetX,scrollWidth) == 0) return;
    if (tempIndex > _curTitles.count - 2) return;
    
    UILabel *leftView = _items[tempIndex].label;
    UILabel *rightView = _items[tempIndex + 1].label;
    
    //获取左右Font的变化值
    float leftScaleValue = _maxFontSize - fmod((double)offsetX,scrollWidth) / scrollWidth * (_maxFontSize - _minFontSize);
    float rightScaleValue = _minFontSize + fmod((double)offsetX,scrollWidth) / scrollWidth * (_maxFontSize - _minFontSize);
    //获取scale和color渐变的具体值0~1
    float leftColorValue = fmod((double)offsetX,scrollWidth) / scrollWidth;
    //执行动画
    [self _updateFontAndColorWithLeftLabel:leftView leftFontScale:leftScaleValue rightLabel:rightView rightFontScale:rightScaleValue colorScale:leftColorValue toIndex:tempIndex scrollToLeft:_selectedSegmentIndex <= tempIndex];
}

- (void)_delayReloadData{
    [_container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_container removeFromSuperview];
    _container = nil;
    [_items removeAllObjects];
    [self _setUpViews];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.userInteractionEnabled = YES;
}

#pragma mark ------------- IndexChange --------------
- (void)_segmentDidSelectAtIndex:(NSUInteger)newIndex
              didDeselectAtIndex:(NSUInteger)oldIndex
                    ignoreAction:(BOOL)ignoreAction
                       animation:(BOOL)animation{
    if(!self) return;
    if (newIndex >= _items.count) return;
    _selectedSegmentIndex = newIndex;
    ignoreAction ?:[self sendActionsForControlEvents:UIControlEventValueChanged];
    if (newIndex == oldIndex) return;
    // update UI
    if (!_textAnimate || (_textAnimate && !animation)) {
        //更新frame
        [self _updateFrame];
    }
    if (self.textAnimate && animation) {
        if (_widthStyle == XLSegmentedControlWidthStyleDynamic) {
            [self _textAnimationFromIndex:oldIndex toIndex:newIndex];
        }else{
            if (!_targetColor) {
                [self _updateLabelTextAtIndex:newIndex];
                [self _updateLabelTextAtIndex:oldIndex];
            }
            [self _moveIndicatorFromIndex:oldIndex toIndex:newIndex];
        }
    }else{
        if (!_targetColor) {
            [self _updateLabelTextAtIndex:newIndex];
            [self _updateLabelTextAtIndex:oldIndex];
        }
        [self _moveIndicatorFromIndex:oldIndex toIndex:newIndex];
        [self _scrollToSelectedSegmentIndex];
    }
    
}

- (void)_updateLabelTextAtIndex:(NSUInteger)index{
    UILabel *label = _items[index].label;
    NSDictionary *attr = _selectedSegmentIndex == index ? _attributesSelected : _attributesNormal;
    NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[index]  attributes:attr];
    label.attributedText = mutableAttributed;
}

#pragma mark ------------- BageView --------------
- (void)_updateBageFrame{
    for (int i = 0; i < self.curTitles.count; i++) {
        [self _updateBageFrameAtIndex:i];
    }
}

- (void)_updateBageFrameAtIndex:(NSInteger)index{
    Item *item = [self.items objectAtIndex:index];
    UIView *bageView = [item viewWithTag:XLSegmentBageViewBaseTag + index];
    if (bageView) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, XLSegmentBageViewLeftOffset, XLSegmentBageViewBottomOffset, 0);
        CGPoint position = CGPointMake(1, 0);
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentControl:bagePointAtIndex:)]) {
            position = [self.dataSource segmentControl:self bagePointAtIndex:index];
            if (position.x < 0) position.x = 0;
            if (position.x > 1) position.x = 1;
            if (position.y < 0) position.y = 0;
            if (position.y > 1) position.y = 1;
        }
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentControl:edgeInsetsAtIndex:)]) {
            insets = [self.dataSource segmentControl:self edgeInsetsAtIndex:index];
        }
        bageView.x = item.label.x + item.label.width * position.x - insets.left;
        bageView.y = item.label.y + item.label.height * position.y - bageView.height + insets.bottom;
    }
}

#pragma mark -------------- Indicator --------------
- (void)_updateIndicatorFrame{
    // indicator
    if (!_indicator) {
        return;
    }
    self.indicator.frame = [self _indicatorFrame];
    self.indicator.layer.cornerRadius = self.indicator.height / 2;
    
    if (self.indicator.superview == nil && self.showsIndicator) {
        [self.container addSubview:self.indicator];
    }
}

/** 计算当前indicator的Frame */
- (CGRect)_indicatorFrame{
    return [self _indicatorFrameFromIndex:_selectedSegmentIndex toIndex:_selectedSegmentIndex];
}

- (CGRect)_indicatorFrameFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (toIndex >= self.items.count || !self.items) return CGRectZero;
    BOOL isToRight = fromIndex < toIndex;
    CGFloat x = 0, y = 0, width = 0;
    CGFloat height = self.indicatorHeight;
    Item *item = self.items[toIndex];
    CGSize itemMinSize = item.size;
    CGSize itemSize = [self measureTitleAtIndex:toIndex];
    //获取indicator偏移量
    CGFloat offset = _widthStyle == XLSegmentedControlWidthStyleDynamic ? (itemSize.width - itemMinSize.width) * 0.5 : 0;
    if (self.indicatorWidthStyle == XLSegmentControlIndicatorWidthStyleShort) {
        width = _indicatorMinWidth;
        x = item.center.x - width * 0.5 - (isToRight ? offset : -offset);
        y = item.label.bottom + self.indicatorMarginTop;
    }else if(self.indicatorWidthStyle == XLSegmentControlIndicatorWidthStyleText){
        width = itemSize.width;
        x = item.center.x - width * 0.5;
        y = item.label.bottom + self.indicatorMarginTop;
    }else{
        width = itemSize.width + _indicatorContentOffset.left + _indicatorContentOffset.right;
        height = itemSize.height + _indicatorContentOffset.top +    _indicatorContentOffset.bottom;
        CGRect targetRect = [item convertRect:item.label.frame toView:item.superview];
        x = targetRect.origin.x - _indicatorContentOffset.left;
        y = targetRect.origin.y - _indicatorContentOffset.top;
    }
    return (CGRect){x, y, width, height};
}

- (void)_moveIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    CGRect frame = [self _indicatorFrameFromIndex:fromIndex toIndex:toIndex];
    if (_indicatorAnimation) {
        // indicator animate
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.66
              initialSpringVelocity:3.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.indicator.frame = frame;
                             if (self->_indicatorWidthStyle != XLSegmentControlIndicatorWidthStyleBackground) {
                                 [self.indicator XL_SetShadowPathWith:self.indicator.backgroundColor shadowOpacity:XLIndicatorShadowOpacity shadowRadius:XLIndicatorShadowRadius shadowSide:XLShadowPathBottom shadowPathWidth:XLIndicatorShadowPathWidth];
                             }
                         } completion:^(BOOL finished) {
                         }];
    }else{
        self.indicator.frame = frame;
    }
}

#pragma mark -------------- Animation --------------
- (void)_textAnimationFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (!self) return;
    __block UILabel *leftLabel = toIndex > fromIndex ? self.items[fromIndex].label : self.items[toIndex].label;
    __block UILabel *rightLabel = toIndex > fromIndex ? self.items[toIndex].label : self.items[fromIndex].label;
    int index = toIndex > fromIndex ? (int)fromIndex : (int)toIndex;
    NSTimeInterval duration = 0.25;
    __weak typeof(self) weakSelf = self;
    self.isAnimation = YES;
    self.userInteractionEnabled = NO;
    _timer = [XLSegmentHelper animateWithDuration:duration animations:^(NSTimeInterval timeout) {
        __strong typeof(weakSelf) self = weakSelf;
        self.animationTimeout = timeout;
        NSTimeInterval tempTime = toIndex > fromIndex ? (duration - timeout) : timeout;
        float leftScaleValue = self.maxFontSize - (self.maxFontSize - self.minFontSize) / duration * tempTime;
        float rightScaleValue = self.minFontSize + (self.maxFontSize - self.minFontSize) / duration * tempTime;
        float leftColorValue = toIndex > fromIndex ? (1 - timeout / duration) : timeout / duration;
        //根据偏移量来设置动画
        [self _updateFontAndColorWithLeftLabel:leftLabel leftFontScale:leftScaleValue rightLabel:rightLabel rightFontScale:rightScaleValue colorScale:leftColorValue toIndex:index scrollToLeft:toIndex > fromIndex];
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        self.isChangeByClick = NO;
        self.isAnimation = NO;
        self.userInteractionEnabled = YES;
        [self _scrollToSelectedSegmentIndex];
    }];
}

- (void)_updateFontAndColorWithLeftLabel:(UILabel *)leftLabel
                          leftFontScale:(float)leftFontScale
                             rightLabel:(UILabel *)rightLabel
                         rightFontScale:(float)rightFontScale
                             colorScale:(float)colorScale
                                toIndex:(int)toIndex
                           scrollToLeft:(BOOL)scrollToLeft{
    //判断是否存在TargetColor
    UIColor *leftColor,*rightColor;
    if (!_targetColor) {
        //获取颜色的变化值
        UIColor *normalColor = [self.attributesNormal objectForKey:NSForegroundColorAttributeName];
        UIColor *selectColor = [self.attributesSelected objectForKey:NSForegroundColorAttributeName];
        CGFloat normalColorComponents[3];
        CGFloat selectColorComponents[3];
        [XLSegmentHelper getRGBComponents:normalColorComponents forColor:normalColor];
        [XLSegmentHelper getRGBComponents:selectColorComponents forColor:selectColor];
        
        //取出变化范围
        CGFloat rDis = selectColorComponents[0] - normalColorComponents[0];
        CGFloat gDis = selectColorComponents[1] - normalColorComponents[1];
        CGFloat bDis = selectColorComponents[2] - normalColorComponents[2];
        
        leftColor = [UIColor colorWithRed:selectColorComponents[0] - rDis * colorScale  green:selectColorComponents[1] - gDis * colorScale blue:selectColorComponents[2] - bDis * colorScale alpha:1];
        rightColor = [UIColor colorWithRed:normalColorComponents[0] + rDis * colorScale  green:normalColorComponents[1] + gDis * colorScale blue:normalColorComponents[2] + bDis * colorScale alpha:1];
    }else{
        leftColor = _targetColor;
        rightColor = _targetColor;
    }
    
    //判断当前label是否存在，并且是否有值
    if (leftLabel.text.length > 0 && rightLabel.text.length > 0) {
        //动态设置font和Color
        if (!scrollToLeft) {
            //从左向右滑动
            if (colorScale <= 0.6) {
                leftLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesSelected fontSize:leftFontScale color:leftColor text:leftLabel.text];
                rightLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesNormal fontSize:rightFontScale color:rightColor text:rightLabel.text];
            }else{
                leftLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesNormal fontSize:leftFontScale color:leftColor text:leftLabel.text];
                rightLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesSelected fontSize:rightFontScale color:rightColor text:rightLabel.text];
            }
        }else{
            //从右向左滑动
            if (colorScale > 0.4) {
                rightLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesSelected fontSize:rightFontScale color:rightColor text:rightLabel.text];
                leftLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesNormal fontSize:leftFontScale color:leftColor text:leftLabel.text];
            }else{
                rightLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesNormal fontSize:rightFontScale color:rightColor text:rightLabel.text];
                leftLabel.attributedText = [XLSegmentHelper changeFontSizeWithAttributes:self.attributesSelected fontSize:leftFontScale color:leftColor text:leftLabel.text];
            }
        }
        [leftLabel sizeToFit];
        [rightLabel sizeToFit];
        
        //调整坐标
        leftLabel.height = leftFontScale;
        leftLabel.superview.width = CGRectGetWidth(leftLabel.frame);
        leftLabel.bottom = leftLabel.superview.bottom - _titleBottomMargin;
        [self _updateBageFrameAtIndex:toIndex];
        
        rightLabel.height = rightFontScale;
        rightLabel.superview.width = CGRectGetWidth(rightLabel.frame);
        rightLabel.bottom = rightLabel.superview.bottom - _titleBottomMargin;
        //调整所有View的x轴坐标
        UIView *tempView = leftLabel.superview;
        CGFloat totalW = 0;
        for (int i = toIndex + 1; i < _items.count; i++) {
            Item *item = _items[i];
            item.x = CGRectGetMaxX(tempView.frame) + _horizontalPadding;
            item.label.x = 0;
            item.label.bottom = item.bottom - _titleBottomMargin;
            tempView = item;
            if (i == _items.count - 1) {
                totalW = item.right + _segmentEdgeInset.right;
            }
            [self _updateBageFrameAtIndex:i];
        }
        self.container.contentSize = CGSizeMake(totalW, CGRectGetHeight(self.bounds));
        //更新Indicator位置
        [self _updateIndicatorWithLeftLabel:leftLabel
                                rightLabel:rightLabel
                                   percent:colorScale
                              scrollToLeft:scrollToLeft];
    }
}

- (void)_updateIndicatorWithLeftLabel:(UILabel *)leftLabel
                          rightLabel:(UILabel *)rightLabel
                             percent:(float)percent
                        scrollToLeft:(BOOL)scrollToLeft{
    //调整indicator的位置,前50%移动X，增加宽度。后50%，移动X，减小宽度
    CGFloat targetX = 0;
    CGFloat targetW = self.indicatorMinWidth;
    
    CGFloat leftX;
    CGFloat rightX;
    if (_indicatorWidthStyle == XLSegmentControlIndicatorWidthStyleText) {
        CGFloat leftMaxW = [XLSegmentHelper measureSizeWithTitle:leftLabel.text attributes:self.attributesSelected].width;
        leftX = leftLabel.superview.x;
        CGFloat rightMaxW = [XLSegmentHelper measureSizeWithTitle:rightLabel.text attributes:self.attributesSelected].width;
        rightX = rightLabel.superview.right - rightMaxW;
        targetX = [XLSegmentHelper interpolationFrom:leftX to:rightX percent:percent];
        targetW = [XLSegmentHelper interpolationFrom:leftMaxW to:rightMaxW percent:percent];
    }else if(_indicatorWidthStyle == XLSegmentControlIndicatorWidthStyleBackground){
        CGFloat leftMaxW = [XLSegmentHelper measureSizeWithTitle:leftLabel.text attributes:self.attributesSelected].width;
        CGRect leftTargetRect = [leftLabel.superview convertRect:leftLabel.frame toView:leftLabel.superview.superview];
        leftX = leftTargetRect.origin.x - _indicatorContentOffset.left;
        CGFloat rightMaxW = [XLSegmentHelper measureSizeWithTitle:rightLabel.text attributes:self.attributesSelected].width;
        CGRect rightTargetRect = [rightLabel.superview convertRect:rightLabel.frame toView:rightLabel.superview.superview];
        rightX = rightTargetRect.origin.x - _indicatorContentOffset.left;
        targetX = [XLSegmentHelper interpolationFrom:leftX to:rightX percent:percent];
        targetW = [XLSegmentHelper interpolationFrom:leftMaxW + _indicatorContentOffset.left + _indicatorContentOffset.right to:rightMaxW + _indicatorContentOffset.left + _indicatorContentOffset.right percent:percent];
    }else{
        CGFloat leftMaxW = [XLSegmentHelper measureSizeWithTitle:leftLabel.text attributes:self.attributesSelected].width;
        leftX = leftLabel.superview.x + (leftMaxW - self.indicatorMinWidth) / 2;
        CGFloat rightMaxW = [XLSegmentHelper measureSizeWithTitle:rightLabel.text attributes:self.attributesSelected].width;
        rightX = (rightLabel.superview.right - rightMaxW) + (rightMaxW - self.indicatorMinWidth) / 2;
        if (percent != 0) {
            CGFloat centerX = leftX + (rightX - leftX - self.indicatorMaxWidth) / 2;
            if (percent <= 0.5) {
                targetX = [XLSegmentHelper interpolationFrom:leftX to:centerX percent:percent * 2];
                targetW = [XLSegmentHelper interpolationFrom:self.indicatorMinWidth to:self.indicatorMaxWidth percent:percent * 2];
            }else{
                targetX = [XLSegmentHelper interpolationFrom:centerX to:rightX percent:(percent - 0.5) * 2];
                targetW = [XLSegmentHelper interpolationFrom:self.indicatorMaxWidth to:self.indicatorMinWidth percent:(percent - 0.5) * 2];
            }
        }
    }
    if (self.container.scrollEnabled || (!self.container.scrollEnabled && percent == 0)) {
        CGRect frame = self.indicator.frame;
        frame.origin.x = targetX;
        frame.size.width = targetW;
        self.indicator.frame = frame;
        if (_indicatorWidthStyle != XLSegmentControlIndicatorWidthStyleBackground) {
            [_indicator XL_SetShadowPathWith:_indicator.backgroundColor shadowOpacity:XLIndicatorShadowOpacity shadowRadius:XLIndicatorShadowRadius shadowSide:XLShadowPathBottom shadowPathWidth:XLIndicatorShadowPathWidth];
        }
    }
}

- (void)_scrollToSelectedSegmentIndex {
    CGRect rectForSelectedIndex = CGRectZero;
    CGFloat selectedSegmentOffset = 0;
    
    Item *selectItem = _items[_selectedSegmentIndex];
    rectForSelectedIndex = selectItem.frame;
    selectedSegmentOffset = CGRectGetWidth(self.frame) / 2 - selectItem.width / 2;
    
    CGRect rectToScrollTo = rectForSelectedIndex;
    rectToScrollTo.origin.x -= selectedSegmentOffset;
    rectToScrollTo.size.width += selectedSegmentOffset * 2;
    [self.container scrollRectToVisible:rectToScrollTo animated:YES];
}

#pragma mark - Public
- (void)reloadData {
    //延迟调用，为了解决segment错乱问题
    self.userInteractionEnabled = NO;
    !self.isAnimation?:dispatch_source_cancel(_timer);
    !self.isAnimation? [self _delayReloadData] : [self performSelector:@selector(_delayReloadData) withObject:nil afterDelay:self.animationTimeout];
}

- (void)insertTitle:(nonnull NSString *)title atIndex:(NSUInteger)index {
    if (index > _curTitles.count) return;
    if (!title) return;
    NSMutableArray *curTitles = self.curTitles.mutableCopy;
    [curTitles insertObject:title atIndex:index];
    self.curTitles = curTitles.copy;
    //判断添加的位置和当前选中的位置
    if (index <= self.selectedSegmentIndex) {
        self.selectedSegmentIndex++;
    }
    [self reloadData];
}

- (void)replaceTitle:(nonnull NSString *)title atIndex:(NSUInteger)index {
    if (index > _curTitles.count) return;
    if (!title) return;
    NSMutableArray *curTitles = self.curTitles.mutableCopy;
    [curTitles replaceObjectAtIndex:index withObject:title];
    self.curTitles = curTitles.copy;
    [self reloadData];
}

- (void)removeTitleAtIndex:(NSUInteger)index {
    if (index >= _curTitles.count) return;
    NSMutableArray *curTitles = self.curTitles.mutableCopy;
    [curTitles removeObjectAtIndex:index];
    self.curTitles = curTitles.copy;
    [self reloadData];
}

- (void)segmentControlChangeBackgroundWithTargetColor:(nonnull UIColor *)targetColor {
    _targetColor = targetColor;
    for (Item *item in _items) {
        item.label.textColor = targetColor;
    }
    _indicator.backgroundColor = targetColor;
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animation:(BOOL)animation {
    _isChangeByClick = YES;
    if (selectedSegmentIndex >= self.curTitles.count) return;
    [self _segmentDidSelectAtIndex:selectedSegmentIndex didDeselectAtIndex:_selectedSegmentIndex ignoreAction:YES animation:animation];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex ignoreAction:(BOOL)ignoreAction {
    if (selectedSegmentIndex >= self.curTitles.count) return;
    [self _segmentDidSelectAtIndex:selectedSegmentIndex didDeselectAtIndex:_selectedSegmentIndex ignoreAction:ignoreAction animation:YES];
}

- (void)setTextAttributes:(nullable NSDictionary *)attributes forState:(UIControlState)state {
    UIFont *font = attributes[NSFontAttributeName];
    if (state == UIControlStateNormal) {
        self.attributesNormal = attributes;
        _minFontSize = font.pointSize;
    } else {
        self.attributesSelected = attributes;
        _maxFontSize = font.pointSize;
    }
    [self setNeedsLayout];
}


- (void)segmentControlDidScroll:(UIScrollView *)scrollView{
    if(!self) return;
    if (_isChangeByClick) return;
    if (!_textAnimate) return;
    if (_widthStyle != XLSegmentedControlWidthStyleDynamic) return;
    [self _updateRectsWithScrollView:scrollView];
}

- (void)segmentControlDidEndDecelerating:(UIScrollView *)scrollView{
    if(!self) return;
    _isChangeByClick = NO;
    int page = (int)scrollView.contentOffset.x/scrollView.frame.size.width;
    [self _segmentDidSelectAtIndex:page didDeselectAtIndex:_selectedSegmentIndex ignoreAction:YES animation:NO];
}

- (void)segmentControlDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if(!self) return;
    _isChangeByClick = NO;
    int page = (int)scrollView.contentOffset.x/scrollView.frame.size.width;
    [self _segmentDidSelectAtIndex:page
               didDeselectAtIndex:_selectedSegmentIndex
                     ignoreAction:YES
                        animation:NO];
}

#pragma mark - EventResponse
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touches.anyObject locationInView:self];
    _isChangeByClick = YES;
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        NSInteger toIndex = 0;
        CGFloat widthLeft = touchLocation.x + self.container.contentOffset.x;
        for (Item *item in _items) {
            if (item.x <= widthLeft && CGRectGetMaxX(item.frame) >= widthLeft) {
                break;
            }
            toIndex++;
        }
        if (toIndex != NSNotFound && toIndex < self.items.count) {
            if (_selectedSegmentIndex != toIndex) {
                [self _segmentDidSelectAtIndex:toIndex didDeselectAtIndex:_selectedSegmentIndex ignoreAction:NO animation:YES];
            } else {
                ///图库所用segment点击后value没有变化也需要触发事件才能实现功能
                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

#pragma mark - Lazy
- (XLSegmentScrollView *)container{
    if (!_container) {
        _container = [[XLSegmentScrollView alloc] initWithFrame:CGRectMake(0, 0, XL_MAINWIDTH, 30)];
        _container.clipsToBounds = NO;
        _container.scrollsToTop = NO;
        _container.showsVerticalScrollIndicator = NO;
        _container.showsHorizontalScrollIndicator = NO;
        _container.translatesAutoresizingMaskIntoConstraints = NO;
        _container.delegate = self;
    }
    return _container;
}

- (CGFloat)segmentTotalWidth{
    if (self.titles.count <= 0) return 0;
    //获取当前最长的title宽度
    CGFloat minW = 0;
    CGFloat maxW = 0;
    CGFloat totalW = 0;
    for (int i = 0; i < self.titles.count; i++) {
        NSString *title = self.titles[i];
        CGSize maxSize = [XLSegmentHelper measureSizeWithTitle:title attributes:self.attributesSelected];
        CGSize minSize = [XLSegmentHelper measureSizeWithTitle:title attributes:self.attributesNormal];
        if (maxW < maxSize.width) {
            minW = minSize.width;
            maxW = maxSize.width;
        }
        totalW += minSize.width;
    }
    totalW = totalW - minW + maxW + (_segmentEdgeInset.left + _segmentEdgeInset.right) * 2 + _horizontalPadding * (self.titles.count - 1);
    return totalW;
}

- (void)setShowBottomShadow:(BOOL)showBottomShadow{
    if (_showBottomShadow == showBottomShadow) return;
    _showBottomShadow = showBottomShadow;
    if (_showBottomShadow) {
        self.backgroundColor = _targetColor ? [UIColor clearColor] : [UIColor whiteColor];
        [self XL_SetShadowPathWith:[UIColor blackColor] shadowOpacity:XLSegmentShadowOpacity shadowRadius:XLSegmentShadowRadius shadowSide:XLShadowPathBottom shadowPathWidth:XLSegmentShadowPathWidth];
    }else{
        self.backgroundColor = [UIColor clearColor];
        [self XL_SetShadowPathWith:[UIColor whiteColor] shadowOpacity:0 shadowRadius:0 shadowSide:XLShadowPathBottom shadowPathWidth:0];
    }
}

- (void)setShowsIndicator:(BOOL)showsIndicator {
    
    if (_showsIndicator != showsIndicator) {
        _showsIndicator = showsIndicator;
        // setup indicator
        if (showsIndicator) {
            _indicator = ({
                UIView *indicator = [UIView new];
                indicator.backgroundColor = _indicatorBackgroundColor ? _indicatorBackgroundColor : [UIColor blackColor];
                [self.container addSubview:indicator];
                indicator;
            });
            [self.container sendSubviewToBack:_indicator];
            [self _updateIndicatorFrame];
        } else {
            if (_indicator) {
                [_indicator removeFromSuperview];
                _indicator = nil;
            }
        }
    }
}

- (void)setIndicatorBackgroundColor:(UIColor *)indicatorBackgroundColor {
    _indicatorBackgroundColor = indicatorBackgroundColor;
    self.indicator.backgroundColor = indicatorBackgroundColor;
}

- (void)setIndicatorWidthStyle:(XLSegmentControlIndicatorWidthStyle)indicatorWidthStyle {
    _indicatorWidthStyle = indicatorWidthStyle;
    [self _updateIndicatorFrame];
}

- (NSArray *)titles{
    return self.curTitles;
}

- (void)setTitles:(NSArray *)titles{
    self.curTitles = titles.copy;
}

- (NSMutableArray *)items{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

#pragma mark - Tool
- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    if (index >= self.curTitles.count) {
        return CGSizeZero;
    }
    NSString *title = self.curTitles[index];
    BOOL selected = index == self.selectedSegmentIndex;
    NSDictionary *titleAttributes = selected ? self.attributesSelected : self.attributesNormal;
    return [XLSegmentHelper measureSizeWithTitle:title attributes:titleAttributes];
}

@end
