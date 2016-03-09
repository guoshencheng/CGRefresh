//
//  UICollectionView+CGRefresh.m
//  RefreshDemo
//
//  Created by guoshencheng on 3/9/16.
//  Copyright © 2016 zixin. All rights reserved.
//

static char CGLeftRefreshViewKey;
static char CGRightRefreshViewKey;

#import "UICollectionView+CGRefresh.h"
#import <objc/runtime.h>

@implementation UICollectionView (CGRefresh)

- (void)setLeftRefresh:(CGRefreshView *)leftRefresh {
    [self willChangeValueForKey:@"CGLeftRefreshViewKey"];
    objc_setAssociatedObject(self, &CGLeftRefreshViewKey, leftRefresh, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CGLeftRefreshViewKey"];
}

- (CGRefreshView *)leftRefresh {
    return objc_getAssociatedObject(self, &CGLeftRefreshViewKey);
}

- (void)setRightRefresh:(CGRefreshView *)rightRefresh {
    [self willChangeValueForKey:@"CGRightRefreshViewKey"];
    objc_setAssociatedObject(self, &CGRightRefreshViewKey, rightRefresh, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CGRightRefreshViewKey"];
}

- (CGRefreshView *)rightRefresh {
    return objc_getAssociatedObject(self, &CGRightRefreshViewKey);
}

- (void)addRefreshAtPostion:(CGRefreshPosition)position withActivityView:(UIView *)activityView andProgressView:(UIView *)progressView target:(id)target action:(SEL)action {
    CGRefreshView *refreshView = [[CGRefreshView alloc] initWithFrame:self.bounds atPosition:position withActivityView:activityView andProgressView:progressView];
    refreshView.refreshingTaget = target;
    refreshView.refreshingAction = action;
    [self insertSubview:refreshView atIndex:0];
    switch (position) {
        case CGRefreshPositionLeft:
            self.leftRefresh = refreshView;
            break;
        case CGRefreshPositionRight:
            self.rightRefresh = refreshView;
            break;
        default:
            break;
    }
}

- (void)addLeftRefreshWithTarget:(id)target action:(SEL)action {
    CGRefreshView *refreshView = [CGRefreshView refreshControlWithFrame:self.bounds atPosition:CGRefreshPositionLeft];
    refreshView.refreshingTaget = target;
    refreshView.refreshingAction = action;
    [self insertSubview:refreshView atIndex:0];
    self.leftRefresh = refreshView;
}

- (void)removeLeftRefresh {
    [self.leftRefresh removeFromSuperview];
}

- (void)addRightRefreshWithTarget:(id)target action:(SEL)action {
    CGRefreshView *refreshView = [CGRefreshView refreshControlWithFrame:self.bounds atPosition:CGRefreshPositionRight];
    refreshView.refreshingTaget = target;
    refreshView.refreshingAction = action;
    [self insertSubview:refreshView atIndex:0];
    self.rightRefresh = refreshView;
}

- (void)removeRightRefresh {
    [self.rightRefresh removeFromSuperview];
}

@end
