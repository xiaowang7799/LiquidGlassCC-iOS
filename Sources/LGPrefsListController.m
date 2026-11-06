#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import "LGConstants.h"

// LGPrefsListController —— PreferenceLoader 设置面板。面板是配置的唯一写入方，
// Tweak 端不持久化默认值。所有自定义 cell / controller 带 LG 前缀。
@interface LGPrefsListController : PSListController
@end

@implementation LGPrefsListController

- (id)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistNamed:@"Root" target:self];
    }
    return _specifiers;
}

// Root.plist 由本机写入下方，字段与 Tweak.xm 的 ZLGPref* 键一一对应：
// enabled / ControlCenter.FullscreenBackdropBlurRadius / RefractionScale /
// RefractiveIndex / SpecularMode / SpecularOpacity / Renderer.FresnelGlareStrength /
// GlassThickness
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"液态玻璃设置", @"设置页面标题");
}

// 保存：用户每改一项，立即写入 PreferenceLoader 偏好 plist（Rootless 与 Rootful
// 候选路径，与 Tweak 端读取路径一致，不扫目录）。
- (void)specifierValueChanged:(PSSpecifier *)specifier {
    [super specifierValueChanged:specifier];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zegeyoudaoli.liquidglasscc.plist"];
    if (!dict) dict = [NSMutableDictionary dictionary];
    [dict setObject:specifier.value forKey:specifier.key];
    NSArray *paths = @[@"/var/mobile/Library/Preferences/com.zegeyoudaoli.liquidglasscc.plist",
                       @"/private/var/mobile/Library/Preferences/com.zegeyoudaoli.liquidglasscc.plist"];
    for (NSString *p in paths) {
        if ([dict writeToFile:p atomically:YES]) break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.zegeyoudaoli.liquidglasscc/ParametersReloaded" object:nil];
}

@end
