//
//  XLSegmentControlDef.h
//  Pods
//
//  Created by 徐晓龙 on 2019/1/3.
//

#ifndef XLSegmentControlDef_h
#define XLSegmentControlDef_h

/// 底部指示器风格
typedef  NS_ENUM(NSUInteger,XLSegmentControlIndicatorWidthStyle){
    XLSegmentControlIndicatorWidthStyleText,        //和文字宽度相同
    XLSegmentControlIndicatorWidthStyleShort,       //自定义宽度
    XLSegmentControlIndicatorWidthStyleBackground   //背景
};

///文字展示风格
typedef NS_ENUM(NSUInteger, XLSegmentedControlWidthStyle) {
    XLSegmentedControlWidthStyleFixed,    // 平均分割
    XLSegmentedControlWidthStyleDynamic,  // 同字体宽度
};

///文字位置
typedef NS_ENUM(NSUInteger, XLSegmentedControlTextPosition) {
    XLSegmentedControlTextPositionMiddle,    // 垂直居中
    XLSegmentedControlTextPositionBottom,    // 底部对齐
};



#define XL_MAINWIDTH  ([[UIScreen mainScreen] bounds].size.width)

static const CGFloat XLSegmentWidthMinmum = 48.0;

static const CGFloat XLSegmentBageViewBaseTag = 100;
static const CGFloat XLSegmentBageViewBottomOffset = 5;
static const CGFloat XLSegmentBageViewLeftOffset = 10;

/** Indicator */
static const CGFloat XLIndicatorShadowOpacity = 0.3;
static const CGFloat XLIndicatorShadowRadius = 2;
static const CGFloat XLIndicatorShadowPathWidth = 4;

/** XLSegment */
static const CGFloat XLSegmentShadowOpacity = 0.04;
static const CGFloat XLSegmentShadowRadius = 4;
static const CGFloat XLSegmentShadowPathWidth = 8;

#endif /* XLSegmentControlDef_h */
