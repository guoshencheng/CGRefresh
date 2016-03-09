//
//  CGRefresh.h
//  CGRefreshDemo
//
//  Created by Valo Lee on 14-11-7.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CGRefreshState){
	CGRefreshStateNormal = 1,
	CGRefreshStatePulling,
	CGRefreshStateWillRefreshing,
	CGRefreshStateRefreshing,
};

typedef NS_ENUM(NSUInteger, CGRefreshPosition) {
	CGRefreshPositionLeft,
	CGRefreshPositionRight,
};

@interface CGRefreshView : UIView

@property (nonatomic, strong) UIView  *activityView;
@property (nonatomic, strong) UIView  *progressView;
@property (nonatomic, weak) id  refreshingTaget;
@property (nonatomic, assign) SEL refreshingAction;

- (instancetype)initWithFrame:(CGRect)frame atPosition:(CGRefreshPosition)position;
- (instancetype)initWithFrame:(CGRect)frame atPosition:(CGRefreshPosition)position withActivityView:(UIView *)activityView andProgressView:(UIView *)progressView;

+ (instancetype)refreshControlWithFrame:(CGRect)frame atPosition:(CGRefreshPosition)position;

- (BOOL)isRefreshing;
- (void)beginRefreshing;
- (void)endRefreshing;

@end

