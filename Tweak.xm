#import <SpringBoard/SpringBoard.h>
#import <ControlCenterUI/ControlCenterUI.h>
#import "LGConfig.h"
#import "LGConstants.h"
#import "LGGlassView.h"

// ZLGCCInject —— 控制中心注入逻辑：
//   hook CCUIModularControlCenterOverlayViewController 的展示/收起，
//   在 CCUIContentModuleContentContainerView 背后插入 ZLGGlassView，
//   并对全屏背板做压暗与模糊。enabled 关闭时完全走 %orig。

%hook CCUIModularControlCenterOverlayViewController

- (void)viewDidAppear:(BOOL)arg1 {
    %orig;
    if (![ZLGConfig sharedConfig].enabled) return;
    [self zlg_installGlassIfNeeded];
}

- (void)viewDidDisappear:(BOOL)arg1 {
    [self zlg_removeGlass];
    %orig;
}

- (void)zlg_installGlassIfNeeded {
    // 在控制中心窗口中查找模块容器，避免重复插入
    UIWindow *ccWindow = nil;
    for (UIWindow *w in [[UIApplication sharedApplication] windows]) {
        if ([[w class] isSubclassOfClass:NSClassFromString(@"CCUIControlCenterWindow")] ||
            [w isKindOfClass:NSClassFromString(@"CCUIControlCenterWindow")]) {
            ccWindow = w;
            break;
        }
    }
    if (!ccWindow) return;

    UIView *content = nil;
    for (UIView *v in ccWindow.subviews) {
        if ([v.class isSubclassOfClass:NSClassFromString(@"CCUIContentModuleContainerView")] ||
            [v isKindOfClass:NSClassFromString(@"CCUIContentModuleContainerView")]) {
            content = v;
            break;
        }
    }
    if (!content) return;

    if ([content.subviews containsObject:self.zlgGlassView]) return;

    ZLGGlassView *glass = [[ZLGGlassView alloc] initWithFrame:content.bounds];
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [glass applyConfig];
    [content insertSubview:glass atIndex:0];
    self.zlgGlassView = glass;
}

- (void)zlg_removeGlass {
    [self.zlgGlassView removeFromSuperview];
    self.zlgGlassView = nil;
}

%end

// 给模块容器本身也套一层玻璃边框，并让滑块 / 按钮被选中时呈现透镜高亮（pill/lens）
%hook CCUIContentModuleContentContainerView

- (void)layoutSubviews {
    %orig;
    if (![ZLGConfig sharedConfig].enabled) return;
    CALayer *l = self.layer;
    l.borderWidth = 1;
    l.borderColor = CGColorCreateGenericRGB(1, 1, 1, 0.3f);
    l.cornerRadius = 20;
    l.masksToBounds = YES;
}

%end

%hook CCUIContinuousSliderView

- (void)setTracking:(BOOL)tracking {
    %orig(tracking);
    if ([ZLGConfig sharedConfig].enabled && tracking) {
        self.layer.shadowColor = [UIColor colorWithRed:0 green:0.45 blue:1 alpha:0.55].CGColor;
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowOffset = CGSizeZero;
    } else {
        self.layer.shadowOpacity = 0;
    }
}

%end

%hook CCUIButtonModuleView

- (void)setHighlighted:(BOOL)highlighted {
    %orig(highlighted);
    if ([ZLGConfig sharedConfig].enabled && highlighted) {
        self.layer.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
        self.layer.shadowRadius = 8;
        self.layer.shadowOpacity = 0.6;
    } else {
        self.layer.shadowOpacity = 0;
    }
}

%end

// Objective-C 关联：在控制器上挂 glass view 引用
static const void *ZLGGlassViewKey = &ZLGGlassViewKey;

@implementation CCUIModularControlCenterOverlayViewController (ZLGGlassAssoc)

- (ZLGGlassView *)zlgGlassView {
    return objc_getAssociatedObject(self, ZLGGlassViewKey);
}

- (void)setZlgGlassView:(ZLGGlassView *)glass {
    objc_setAssociatedObject(self, ZLGGlassViewKey, glass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
