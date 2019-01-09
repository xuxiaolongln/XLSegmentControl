//
//  UIView+XLSegment.m
//  Pods-XLSegmentControl_Example
//
//  Created by 徐晓龙 on 2019/1/9.
//

#import "UIView+XLSegment.h"

@implementation UIView (XLSegment)
#pragma mark - Init
- (id)initWithSize:(CGSize)size
{
    CGRect rect = (CGRect){CGPointZero, size};
    return [self initWithFrame:rect];
}


#pragma mark - Get Property
- (CGPoint)origin
{
    return self.frame.origin;
}

- (CGFloat)x
{
    return self.origin.x;
}

- (CGFloat)y
{
    return self.origin.y;
}

- (CGFloat)right
{
    return self.x + self.width;
}

- (CGFloat)bottom
{
    return self.y + self.height;
}


- (CGSize)size
{
    return self.frame.size;
}

- (CGFloat)height
{
    return self.size.height;
}

- (CGFloat)width
{
    return self.size.width;
}


#pragma mark - Set Origin
- (void)setOrigin:(CGPoint)origin
{
    self.frame = (CGRect){origin, self.size};
}

- (void)setX:(CGFloat)x
{
    [self setOrigin:CGPointMake(x, self.y)];
}

- (void)setY:(CGFloat)y
{
    [self setOrigin:CGPointMake(self.x, y)];
}


- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


#pragma mark - Set Size
- (void)setSize:(CGSize)size
{
    self.frame = (CGRect){self.origin, size};
}

- (void)setWidth:(CGFloat)width
{
    [self setSize:CGSizeMake(width, self.height)];
}

- (void)setHeight:(CGFloat)height
{
    [self setSize:CGSizeMake(self.width, height)];
}


#pragma mark - Set Anchor Point
- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    [self setPosition:self.origin atAnchorPoint:anchorPoint];
}

- (void)setPosition:(CGPoint)point atAnchorPoint:(CGPoint)anchorPoint
{
    CGFloat x = point.x - anchorPoint.x * self.width;
    CGFloat y = point.y - anchorPoint.y * self.height;
    [self setOrigin:CGPointMake(x, y)];
}

- (void)XL_SetShadowPathWith:(UIColor *)shadowColor
                shadowOpacity:(CGFloat)shadowOpacity
                 shadowRadius:(CGFloat)shadowRadius
                   shadowSide:(XLShadowPathSide)shadowPathSide
              shadowPathWidth:(CGFloat)shadowPathWidth{
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowRadius =  shadowRadius;
    self.layer.shadowOffset = CGSizeZero;
    CGRect shadowRect;
    CGFloat originH = self.bounds.size.height;
    CGFloat originW = self.bounds.size.width;
    CGFloat originX = 0;
    CGFloat originY = 0;
    switch (shadowPathSide) {
        case XLShadowPathTop:
            shadowRect  = CGRectMake(originX, originY - shadowPathWidth/2, originW,  shadowPathWidth);
            break;
        case XLShadowPathBottom:
            shadowRect  = CGRectMake(originX, originH - shadowPathWidth/2, originW, shadowPathWidth);
            break;
            
        case XLShadowPathLeft:
            shadowRect  = CGRectMake(originX - shadowPathWidth/2, originY, shadowPathWidth, originH);
            break;
            
        case XLShadowPathRight:
            shadowRect  = CGRectMake(originW - shadowPathWidth/2, originY, shadowPathWidth, originH);
            break;
        case XLShadowPathNoTop:
            shadowRect  = CGRectMake(originX - shadowPathWidth/2, originY +1, originW +shadowPathWidth,originH + shadowPathWidth/2 );
            break;
        case XLShadowPathAllSide:
            shadowRect  = CGRectMake(originX - shadowPathWidth/2, originY - shadowPathWidth/2, originW +  shadowPathWidth, originH + shadowPathWidth);
            break;
    }
    
    UIBezierPath *path =[UIBezierPath bezierPathWithRect:shadowRect];
    self.layer.shadowPath = path.CGPath;
}

@end
