//
//  ViewController.m
//  RefreshDemo
//
//  Created by guoshencheng on 3/8/16.
//  Copyright © 2016 zixin. All rights reserved.
//

#import "ViewController.h"
#import "ActivityView.h"
#import "UICollectionView+CGRefresh.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *data;

@end

@implementation ViewController

+ (instancetype)create {
    return [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    ActivityView *view = [[ActivityView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    view.backgroundColor = [UIColor blueColor];
    ActivityView *view2 = [[ActivityView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    view2.backgroundColor = [UIColor blueColor];
    [self.collectionView addRightRefreshWithTarget:self action:@selector(rightRefreshing)];
    self.collectionView.rightRefresh.activityView = view;
    [self.collectionView addLeftRefreshWithTarget:self action:@selector(leftRefreshing)];
    self.collectionView.leftRefresh.activityView = view2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor blackColor] : [UIColor yellowColor];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (void)leftRefreshing {
    [self.collectionView.leftRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:1];
}

- (void)rightRefreshing {
    [self performSelector:@selector(delayReload) withObject:nil afterDelay:1];
}

- (void)delayReload {
    [self.data addObjectsFromArray:@[@(1), @(1)]];
    [self.collectionView reloadData];
    [self.collectionView.rightRefresh endRefreshing];
}

- (NSMutableArray *)data {
    if (_data) {
        return _data;
    }
    _data = [NSMutableArray arrayWithArray:@[@(1), @(1), @(1), @(1), @(1)]];
    return _data;
}

@end
