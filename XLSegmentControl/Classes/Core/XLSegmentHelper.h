//
//  XLSegmentHelper.h
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2019/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLSegmentHelper : NSObject
/** 获取偏移量 */
+ (CGFloat)interpolationFrom:(CGFloat)from
                          to:(CGFloat)to
                     percent:(CGFloat)percent;

/** 计算title的size */
+ (CGSize)measureSizeWithTitle:(NSString *)title
                    attributes:(NSDictionary *)attributes;

/** 动态修改字体大小 */
+ (NSMutableAttributedString *)changeFontSizeWithAttributes:(NSDictionary *)attributes
                                                   fontSize:(CGFloat)fontSize
                                                      color:(UIColor *)color
                                                       text:(NSString *)text;
/** 将UIColor转换成RGBColor */
+ (void)getRGBComponents:(CGFloat [3])components
                forColor:(UIColor *)color;

/**使用定时器，自定义动画效果 */
+ (dispatch_source_t)animateWithDuration:(NSTimeInterval)duration
                              animations:(void(^)(NSTimeInterval timeout))animations
                              completion:(void(^)(BOOL finished))completion;
@end

NS_ASSUME_NONNULL_END
