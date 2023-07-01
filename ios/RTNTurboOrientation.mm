#import "RTNTurboOrientationSpec.h"
#import "RTNTurboOrientation.h"
#import <Foundation/Foundation.h>

@interface RTNTurboOrientation()
@property UIDeviceOrientation deviceOrientation;
@end

@implementation RTNTurboOrientation
{
  bool hasListeners;
  bool starting;
}

static UIInterfaceOrientationMask currentOrientation = UIInterfaceOrientationMaskPortrait;

NSString *JSEVENT = @"TURBO_ORIENTATION";

NSString *ALL = @"All";
NSString *PORTRAIT = @"Portrait";
NSString *PORTRAIT_UPSIDE_DOWN =  @"PortraitUpsideDown";
NSString *LANDSCAPE_RIGHT = @"LandscapeRight";
NSString *LANDSCAPE_LEFT = @"LandscapeLeft";
NSString *LANDSCAPE = @"Landscape";
NSString *UNKNOWN = @"Unknown";
NSString *CONTROLLER_EVENT = @"RTNTurboOrientationViewController";

+(void) setCurrentOrientation: (UIInterfaceOrientationMask) orientation
{
  currentOrientation = orientation;
}
+(UIInterfaceOrientationMask) getCurrentOrientation
{
  return currentOrientation;
}

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
  return @[JSEVENT];
}
-(void)startObserving {
  hasListeners = YES;
}
-(void)stopObserving {
  hasListeners = NO;
}
-(void) sendEvent: (NSDictionary *)data
{
  if(hasListeners == NO) return;
  [self sendEventWithName:JSEVENT body: data];
}
- (void)addListener:(NSString *)event
{
    //ignore
}
- (void)removeListeners:(double)count
{
    //ignore
}
- (void) handleSettingOrientation: (UIInterfaceOrientationMask) mask
{
  [RTNTurboOrientation setCurrentOrientation:mask];
//  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {}];
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *rootvc = (UIViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    if (@available(iOS 16.0, *)) {
      [rootvc setNeedsUpdateOfSupportedInterfaceOrientations];
      UIWindowScene *scene = (UIWindowScene*)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
      if(scene != nil) return;
      [scene requestGeometryUpdateWithPreferences:[[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask] errorHandler:^(NSError * _Nonnull error) {}];
    } else {
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: mask] forKey:@"orientation"];
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
  });
}


- (void) onDeviceOrientationChange:(NSNotification *)notification
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      if(orientation != self.deviceOrientation){
        [self sendEvent:@{@"orientation": @"Portrait"}];
      }
      break;
    case UIDeviceOrientationFaceUp:
      break;
    case UIDeviceOrientationFaceDown:
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      if(orientation != self.deviceOrientation){
        [self sendEvent:@{@"orientation": @"PortraitUpsideDown"}];
      }
      break;
    case UIDeviceOrientationLandscapeLeft:
      if(orientation != self.deviceOrientation){
        [self sendEvent:@{@"orientation": @"LandscapeLeft"}];
      }
      break;
    case UIDeviceOrientationLandscapeRight:
      if(orientation != self.deviceOrientation){
        [self sendEvent:@{@"orientation": @"LandscapeRight"}];
      }
      break;
    default:
      break;
  }
  self.deviceOrientation = orientation;
}


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeTurboOrientationSpecJSI>(params);
}

- (void)lock:(NSString *)orientation {
    if(orientation != nil) {
        if([orientation isEqualToString:PORTRAIT]){
          [self handleSettingOrientation: UIInterfaceOrientationMaskPortrait];
        }else if([orientation isEqualToString:PORTRAIT_UPSIDE_DOWN]){
          [self handleSettingOrientation: UIInterfaceOrientationMaskPortraitUpsideDown];
        }else if([orientation isEqualToString:LANDSCAPE_RIGHT]){
          [self handleSettingOrientation: UIInterfaceOrientationMaskLandscapeRight];
        }else if([orientation isEqualToString:LANDSCAPE_LEFT]){
          [self handleSettingOrientation: UIInterfaceOrientationMaskLandscapeLeft];
        }else if([orientation isEqualToString:LANDSCAPE]){
          [self handleSettingOrientation: UIInterfaceOrientationMaskLandscape];
        }else if([orientation isEqualToString:ALL]){
          [self handleSettingOrientation: UIInterfaceOrientationMaskAll];
        }else{
          //unknown
        }
      }
}

- (void)toggleHomeIndicatorOrSinkStatusBar:(BOOL)on {
    NSNumber *full = [[NSNumber alloc] initWithBool:on];
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTROLLER_EVENT object:nil userInfo:@{@"full": full}];
}

- (void)toggleNativeObserver:(BOOL)on {
    if (on) {
        if(starting != YES){
            starting = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        }
    }else{
        if(starting == YES){
            starting = NO;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        }
    }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
