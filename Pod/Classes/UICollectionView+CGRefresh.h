//
//  UICollectionView+CGRefresh.h
//  RefreshDemo
//
//  Created by guoshencheng on 3/9/16.
//  Copyright © 2016 zixin. All rights reserved.
//

#import "CGRefreshView.h"

@interface UICollectionView (CGRefresh)

@property (nonatomic, weak) CGRefreshView *leftRefresh;
@property (nonatomic, weak) CGRefreshView *rightRefresh;

- (void)addRefreshAtPostion:(CGRefreshPosition)position withActivityView:(UIView *)activityView andProgressView:(UIView *)progressView target:(id)target action:(SEL)action;

- (void)addLeftRefreshWithTarget:(id)target action:(SEL)action;
- (void)removeLeftRefresh;

- (void)addRightRefreshWithTarget:(id)target action:(SEL)action;
- (void)removeRightRefresh;


@end
