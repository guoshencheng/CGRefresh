//
//  CGRefresh.m
//  CGRefreshDemo
//
//  Created by Valo Lee on 14-11-7.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import "CGRefreshView.h"
#import "CGIndicator.h"
#import "CGProgressView.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

const CGFloat CGRefreshViewLength      = 50.0;
const CGFloat CGRefreshDuration        = 0.3;

NSString *const CGRefreshContentOffset = @"contentOffset";
NSString *const CGRefreshContentSize   = @"contentSize";

#define SELF_IS_ERECT ((self.position == CGRefreshPositionLeft) || (self.position == CGRefreshPositionRight))

@interface CGRefreshView ()

@property (nonatomic, assign) CGRefreshPosition position;
@property (nonatomic, assign) CGRefreshState state;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (assign, nonatomic) UIEdgeInsets originInset;

@end

@implementation CGRefreshView

- (BOOL)isRefreshing{
    return CGRefreshStateRefreshing == self.state;
}

- (void)beginRefreshing {
    if (self.window) {
        self.state = CGRefreshStateRefreshing;
    } else {
        _state = CGRefreshStateRefreshing;
        [super setNeedsDisplay];
    }
}

- (void)endRefreshing {
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = CGRefreshStateNormal;
    });
}

- (instancetype)initWithFrame:(CGRect)frame atPosition:(CGRefreshPosition)position {
	return [self initWithFrame:frame atPosition:position withActivityView:nil andProgressView:nil];
}

- (instancetype)initWithFrame:(CGRect)frame atPosition:(CGRefreshPosition)position withActivityView:(UIView *)activityView andProgressView:(UIView *)progressView {
    if (self = [super init]) {
        [self setupWithFrame:frame];
        self.position = position;
        self.activityView = activityView;
        self.progressView = progressView;
    }
	return self;
}

+ (instancetype)refreshControlWithFrame: (CGRect)frame atPosition: (CGRefreshPosition)position {
    CGIndicator *indicator = [[CGIndicator alloc] init];
    CGProgressView *progressView = [[CGProgressView alloc] init];
	return [[CGRefreshView alloc] initWithFrame:frame atPosition:position withActivityView:indicator andProgressView:progressView];
}

#pragma mark - LifeCycle 

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    if (self.activityView) self.activityView.center = center;
    if (self.progressView) self.progressView.center = center;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self removeObservers];
    if (newSuperview) {
        _collectionView = (UICollectionView *)newSuperview;
        [self addObserversToView:_collectionView];
        [self configureFrame];
    }
}

#pragma mark - PrivateMethod

- (void)configureFrame {
	CGRect frame = self.frame;
    frame.size.width = CGRefreshViewLength;
    frame.origin.y = 0;
    frame.origin.x = [self caculateOffset];
    frame.size.height = self.collectionView.bounds.size.height;
    self.frame = frame;
}

- (CGFloat)caculateOffset {
    if (self.position == CGRefreshPositionLeft) {
        return - CGRefreshViewLength;
    } else {
        NSInteger count = [self.collectionView numberOfItemsInSection:0];
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        CGSize itemSize = layout.itemSize;
        CGFloat spacing = layout.minimumLineSpacing;
        return itemSize.width * count + spacing * (count - 1);
    }
}

- (void)adjustState {
	if (self.collectionView.dragging) {
        if (![self checkVaildPull]) return;
        CGFloat distance = [self caculatePullDistance];
        CGFloat progress = distance / CGRefreshViewLength;
        if (progress < 0) {
            self.state = CGRefreshStateNormal;
        } else if (progress > 1) {
            self.state = CGRefreshStateWillRefreshing;
        } else {
            self.state = CGRefreshStatePulling;
        }
    } else if(self.state == CGRefreshStateWillRefreshing){
		self.state = CGRefreshStateRefreshing;
    }
}

- (CGFloat)caculatePullDistance {
    if (self.collectionView.contentOffset.x > 0) {
        return [UIScreen mainScreen].bounds.size.width + self.collectionView.contentOffset.x - self.collectionView.contentSize.width;
    } else {
        return - self.collectionView.contentOffset.x;
    }
}

- (BOOL)checkVaildPull {
    return (self.collectionView.contentOffset.x <= 0 && self.position == CGRefreshPositionLeft) || ([UIScreen mainScreen].bounds.size.width + self.collectionView.contentOffset.x >= self.collectionView.contentSize.width && self.position == CGRefreshPositionRight);
}

#pragma mark - observeValue
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    if ([CGRefreshContentSize isEqualToString:keyPath]) {
        [self configureFrame];
    }
    if ([CGRefreshContentOffset isEqualToString:keyPath]) {
		if (self.state == CGRefreshStateRefreshing) return;
		[self adjustState];
	}
}

#pragma mark - set State
- (void)setState:(CGRefreshState)state {
	if (_state == state) return;
    CGRefreshState oldState = _state;
	_state = state;
	switch (state) {
		case CGRefreshStateNormal:
            [self handleRefreshNomalWithOldState:oldState];
			break;
		case CGRefreshStatePulling:
            [self handleRefreshPullingWithOldState:oldState];
			break;
		case CGRefreshStateWillRefreshing:
			break;
		case CGRefreshStateRefreshing:
            [self handleRefreshing];
            break;
		default:
			break;
	}
}

- (void)handleRefreshPullingWithOldState:(CGRefreshState)oldState {
    if (CGRefreshStateNormal == oldState) {
        self.activityView.hidden = NO;
    }
}

- (void)handleRefreshing {
    CGFloat offset = [self caculatePullDistance];
    self.originInset = self.collectionView.contentInset;
    UIEdgeInsets inset = self.collectionView.contentInset;
    if (self.position == CGRefreshPositionLeft) {
        inset.left = offset;
    } else {
        inset.right = offset;
    }
    self.collectionView.contentInset = inset;
    if (self.refreshingTaget &&  [self.refreshingTaget respondsToSelector:self.refreshingAction]) {
        SuppressPerformSelectorLeakWarning([self.refreshingTaget performSelector:self.refreshingAction]);
    }
}

- (void)handleRefreshNomalWithOldState:(CGRefreshState)oldState {
    if (CGRefreshStateRefreshing == oldState) {
        self.activityView.hidden = YES;
        [UIView animateWithDuration:CGRefreshDuration animations:^{
            self.collectionView.contentInset = self.originInset;
        }];
    }
}

- (void)addObserversToView:(UICollectionView *)collectionView {
    [collectionView addObserver:self forKeyPath:CGRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
    [collectionView addObserver:self forKeyPath:CGRefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    [self.superview removeObserver:self forKeyPath:CGRefreshContentOffset context:nil];
    [self.superview removeObserver:self forKeyPath:CGRefreshContentSize context:nil];
}

- (void)setupWithFrame:(CGRect)frame {
    self.state = CGRefreshStateNormal;
    frame.size.width = CGRefreshViewLength;
    frame.size.height = frame.size.height - 20;
    frame.origin.y = 10;
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setActivityView:(UIView *)activityView {
    [_activityView removeFromSuperview];
    if (activityView) {
        [self insertSubview:activityView atIndex:0];
    }
    _activityView = activityView;
}

- (void)setProgressView:(UIView *)progressView {
    [_progressView removeFromSuperview];
    if (progressView) {
        [self insertSubview:progressView atIndex:0];
    }
    _progressView = progressView;
}

@end


