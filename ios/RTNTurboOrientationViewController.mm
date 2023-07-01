//
//  RTNTurboOrientationViewController.m
//  react-native-turbo-orientation
//
//  Created by _sseon on 2023/7/1.
//

#import "RTNTurboOrientationViewController.h"

@interface RTNTurboOrientationViewController ()

@end

@implementation RTNTurboOrientationViewController


- (instancetype)init {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEvent:) name:@"RTNTurboOrientationViewController" object:nil];
  return [super init];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RTNTurboOrientationViewController" object:nil];
}
- (void)onEvent: (NSNotification *)notification
{
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
  }];
  NSNumber *full = [notification.userInfo valueForKey:@"full"];
  dispatch_async(dispatch_get_main_queue(), ^{
    self.hidden = full;
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
  });
}

-(BOOL) prefersHomeIndicatorAutoHidden
{
    if(_hidden == nil) {
        _hidden = @0;
    }
    return [_hidden integerValue] > 0;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
  return [RTNTurboOrientation getCurrentOrientation];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationPortrait;
}

@end
