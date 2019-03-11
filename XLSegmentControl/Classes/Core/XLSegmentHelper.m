//
//  XLSegmentHelper.m
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2019/1/9.
//

#import "XLSegmentHelper.h"

@implementation XLSegmentHelper

+ (CGFloat)interpolationFrom:(CGFloat)from
                          to:(CGFloat)to
                     percent:(CGFloat)percent{
    percent = MAX(0, MIN(1, percent));
    return from + (to - from) * percent;
}

/** 计算title的size */
+ (CGSize)measureSizeWithTitle:(NSString *)title
                    attributes:(NSDictionary *)attributes{
    CGSize size = [title sizeWithAttributes:attributes];
    UIFont *font = attributes[NSFontAttributeName];
    return CGRectIntegral((CGRect){CGPointZero, CGSizeMake(size.width, font.pointSize)}).size;
}

#pragma mark 动态修改字体大小
+ (NSMutableAttributedString *)changeFontSizeWithAttributes:(NSDictionary *)attributes
                                                   fontSize:(CGFloat)fontSize
                                                      color:(UIColor *)color
                                                       text:(NSString *)text{
    NSMutableDictionary *mAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    UIFont *originFont = mAttributes[NSFontAttributeName];
    mAttributes[NSFontAttributeName] = [originFont fontWithSize:fontSize];
    mAttributes[NSForegroundColorAttributeName] = color;
    NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:text attributes:mAttributes];
    return mutableAttributed;
}

/** 将UIColor转换成RGBColor */
+ (void)getRGBComponents:(CGFloat [3])components
                forColor:(UIColor *)color{
    CGColorSpaceRef rgbColorSpac = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpac, kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpac);
    for (int compont = 0; compont < 3; compont++) {
        components[compont] = resultingPixel[compont] / 255.0f;
    }
}


+ (dispatch_source_t)animateWithDuration:(NSTimeInterval)duration
                              animations:(void(^)(NSTimeInterval timeout))animations
                              completion:(void(^)(BOOL finished))completion{
    __block NSTimeInterval timeout = duration;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),duration / 60.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if ( timeout <= 0 ){
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(YES);
                }
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (animations) {
                    animations(timeout);
                }
            });
            timeout -= duration / 60.0;
        }
    });
    dispatch_resume(timer);
    return timer;
}

+ (NSDictionary *)changeAttributedColorWithAtt:(NSDictionary *)attr color:(UIColor *)color{
    NSMutableDictionary *mAttributes = [NSMutableDictionary dictionaryWithDictionary:attr];
    mAttributes[NSForegroundColorAttributeName] = color;
    return mAttributes.copy;
}

@end
