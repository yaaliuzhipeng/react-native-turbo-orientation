#import <RTNTurboOrientationSpec/RTNTurboOrientationSpec.h>
#import <React/RCTEventEmitter.h>
NS_ASSUME_NONNULL_BEGIN

@interface RTNTurboOrientation : RCTEventEmitter <NativeTurboOrientationSpec>

+(void) setCurrentOrientation: (UIInterfaceOrientationMask) orientation;
+(UIInterfaceOrientationMask) getCurrentOrientation;

@end

NS_ASSUME_NONNULL_END
