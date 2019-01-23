# XLSegmentControl

[![CI Status](https://img.shields.io/travis/xxl379786230/XLSegmentControl.svg?style=flat)](https://travis-ci.org/xxl379786230/XLSegmentControl)
[![Version](https://img.shields.io/cocoapods/v/XLSegmentControl.svg?style=flat)](https://cocoapods.org/pods/XLSegmentControl)
[![License](https://img.shields.io/cocoapods/l/XLSegmentControl.svg?style=flat)](https://cocoapods.org/pods/XLSegmentControl)
[![Platform](https://img.shields.io/cocoapods/p/XLSegmentControl.svg?style=flat)](https://cocoapods.org/pods/XLSegmentControl)

## 说明
仿微博、陌陌、今日头条等多种样式的自定义Segment，集成简单。

## 效果预览
![avatar](XLSegmentControl/images/1.gif)
![avatar](XLSegmentControl/images/2.gif)
![avatar](XLSegmentControl/images/3.gif)
![avatar](XLSegmentControl/images/4.gif)

## 示例代码
### 定义XLSegmentControl
```
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
[_segment setTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:20],
NSForegroundColorAttributeName:[UIColor redColor]
}
forState:UIControlStateSelected];
//给当前的segment添加点击事件
[_segment addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
}
return _segment;
}
```
- Segment支持两种文字展示风格，对应的属性为<font color="#dd0000">widthStyle</font><br /> 
```
///文字展示风格
typedef NS_ENUM(NSUInteger, XLSegmentedControlWidthStyle) {
XLSegmentedControlWidthStyleFixed,    // 平均分割
XLSegmentedControlWidthStyleDynamic,  // 同字体宽度
};
```
- 目前同时支持三种indicator样式，对应的属性为<font color="#dd0000">indicatorWidthStyle</font><br /> 
```
/// 底部指示器风格
typedef  NS_ENUM(NSUInteger,XLSegmentControlIndicatorWidthStyle){
XLSegmentControlIndicatorWidthStyleText,        //和文字宽度相同
XLSegmentControlIndicatorWidthStyleShort,       //自定义宽度
XLSegmentControlIndicatorWidthStyleBackground   //背景
};
```
- Segment支持字体和color动画，只要设置<font color="#dd0000">UIControlStateNormal</font> 和<font color="#dd0000">UIControlStateSelected</font>两种不同状态下的字体大小和颜色，同时设置textAnimate=YES，就能看到完整的动画效果，如下:
```
_segment.showBottomShadow = YES;
[_segment setTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:16],
NSForegroundColorAttributeName: [UIColor blackColor]
}
forState:UIControlStateNormal];
[_segment setTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:20],
NSForegroundColorAttributeName:[UIColor redColor]
}
forState:UIControlStateSelected];
```
- segment的indicator也支持类似陌陌、QQ那种黏性红点的动画，只要设置最大宽度和最小宽度，就可实现。如下：
```
_segment.indicatorMinWidth = 24;
_segment.indicatorMaxWidth = 50;
_segment.indicatorHeight = 6;
```
- segment支持动态添加或者删除item：
```
/** 插入标题 */
- (void)insertTitle:(NSString *)title atIndex:(NSUInteger)index;
/** 移除某个标题 */
- (void)removeTitleAtIndex:(NSUInteger)index;
/** 替换某个标题 */
- (void)replaceTitle:(NSString *)title atIndex:(NSUInteger)index;
```

### 注意
- 如果需要在Segment上添加角标，可以通过DataSource来设置：
```
/** 为指定的item添加角标 */
- (UIView *)segmentControl:(id<XLSegmentControlProtocol>)segmentControl bageViewAtIndex:(NSInteger)index;
/** 每个角标的偏移量，默认(0,10,5,0) */
- (UIEdgeInsets)segmentControl:(id<XLSegmentControlProtocol>)segmentControl edgeInsetsAtIndex:(NSInteger)index;
/** 每个角标相对于文字的位置,默认为(1,0) 即bageView的左下角对应文字右上角，范围0~1*/
- (CGPoint)segmentControl:(id<XLSegmentControlProtocol>)segmentControl bagePointAtIndex:(NSInteger)index;
```
- 由于Segment需要与scrollView联动，所以必须实现下面三种方法：
```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
[_segment segmentControlDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
[_segment segmentControlDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
[_segment segmentControlDidEndScrollingAnimation:scrollView];
}
```
- 最最重要的一点，由于当前Segment默认是从最左侧开始排列的，如果想要Segment居中显示，可以获取Segment的实际宽度，重新设置即可,在调用segmentTotalWidth获取实际宽度之前，要保证所有的属性都设置完毕，以免宽度计算不准确：
```
CGFloat segmentH = self.segment.segmentTotalWidth;
CGFloat x = (self.view.frame.size.width - segmentH) / 2;
self.segment.frame = CGRectMake(x, 44, segmentH, 60);
```

## 要求
- ios 8.0+
- Xcode 9+

## 安装

clone到本地，直接使用，或者在podfile中添加以下代码后，执行pod install

```ruby
pod 'XLSegmentControl'
```

## 补充
本人才疏学浅，如果当前仓库在使用过程中遇到什么问题，或者想要支持什么样的效果，欢迎联系我。我会在第一时间进行更新。感谢支持。</br>
GMail: xuxiaolongln@gmail.com </br>
QQ: 379786230@qq.com </br>

## License

XLSegmentControl is available under the MIT license. See the LICENSE file for more info.
