//
//  UIView+XLSegment.h
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2019/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum :NSInteger{
    XLShadowPathLeft,
    XLShadowPathRight,
    XLShadowPathTop,
    XLShadowPathBottom,
    XLShadowPathNoTop,
    XLShadowPathAllSide
} XLShadowPathSide;

@interface UIView (XLSegment)
- (id)initWithSize:(CGSize)size;

- (CGPoint)origin;
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)right;
- (CGFloat)bottom;

- (CGSize)size;
- (CGFloat)height;
- (CGFloat)width;

- (void)setBottom:(CGFloat)bottom;
- (void)setSize:(CGSize)size;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

- (void)setOrigin:(CGPoint)origin;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

- (void)setAnchorPoint:(CGPoint)anchorPoint;
- (void)setPosition:(CGPoint)point atAnchorPoint:(CGPoint)anchorPoint;

/*
 * shadowColor 阴影颜色
 * shadowOpacity 阴影透明度，默认0
 * shadowRadius  阴影半径，默认3
 * shadowPathSide 设置哪一侧的阴影，
 * shadowPathWidth 阴影的宽度，
 */
- (void)XL_SetShadowPathWith:(UIColor *)shadowColor
                shadowOpacity:(CGFloat)shadowOpacity
                 shadowRadius:(CGFloat)shadowRadius
                   shadowSide:(XLShadowPathSide)shadowPathSide
              shadowPathWidth:(CGFloat)shadowPathWidth;


@end

NS_ASSUME_NONNULL_END
