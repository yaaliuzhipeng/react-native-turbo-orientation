//
//  RTNTurboOrientationViewController.h
//  react-native-turbo-orientation
//
//  Created by _sseon on 2023/7/1.
//

#import <UIKit/UIKit.h>
#import "RTNTurboOrientation.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTNTurboOrientationViewController : UIViewController

@property (nonatomic,strong) NSNumber *hidden;
-(BOOL) prefersHomeIndicatorAutoHidden;

@end

NS_ASSUME_NONNULL_END
