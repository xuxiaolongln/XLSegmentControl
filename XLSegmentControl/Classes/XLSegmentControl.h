//
//  XLSegmentControl.h
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2018/12/29.
//

#import <UIKit/UIKit.h>
#import "XLSegmentControlProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XLSegmentControl : UIControl<XLSegmentControlProtocol>

- (instancetype)initWithTitles:(NSArray <NSString *> *)titles;
- (instancetype)initWithTitles:(NSArray <NSString *> *)titles dataSource:(id<XLSegmentControlDataSource>)dataSource;

#pragma mark - 废弃所有初始化方法

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
