//
//  ActivityView.m
//  CGRefresh
//
//  Created by guoshencheng on 4/5/16.
//  Copyright © 2016 guoshencheng. All rights reserved.
//

#import "ActivityView.h"

@implementation ActivityView

- (void)startAnimating {
    [UIView animateWithDuration:1 animations:^{
        self.backgroundColor = [UIColor greenColor];
    }];
}

- (void)stopAnimating {
    self.backgroundColor = [UIColor yellowColor];
}

@end
