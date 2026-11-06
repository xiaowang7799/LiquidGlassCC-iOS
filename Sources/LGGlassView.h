#import <UIKit/UIKit.h>
#import "LGGlassView.h"

@interface ZLGGlassView : UIView
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) CALayer *refractionEdgeLayer;
@property (nonatomic, strong) CALayer *specularRimLayer;
@property (nonatomic, assign) ZLGConfig *config;
- (void)applyConfig;
@end
