//
//  XLSegmentControlItem.h
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2019/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLSegmentControlItem : UIView

@property(nonatomic, weak)UILabel *label;

- (instancetype)initWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
