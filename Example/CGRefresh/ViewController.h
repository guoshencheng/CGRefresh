//
//  ViewController.h
//  RefreshDemo
//
//  Created by guoshencheng on 3/8/16.
//  Copyright © 2016 zixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

+ (instancetype)create;

@end

