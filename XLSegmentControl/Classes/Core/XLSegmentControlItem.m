//
//  XLSegmentControlItem.m
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2019/1/9.
//

#import "XLSegmentControlItem.h"

@implementation XLSegmentControlItem

- (instancetype)initWithView:(UIView *)view{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        [self addSubview:view];
        if ([view isKindOfClass:[UILabel class]]) {
            _label = (UILabel *)view;
        }
    }
    return self;
}

@end
