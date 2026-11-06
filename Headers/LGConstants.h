// LiquidGlassCC — iOS 越狱 tweak 工程（源码，未在本机编译）
//
// 复刻越狱 deb「液态玻璃」在控制中心上的效果：
//   背景实时采样 + 高斯模糊（ControlCenter.FullscreenBackdropBlurRadius）
//   边缘折射透镜（RefractionScale / RefractiveIndex）
//   菲涅尔边缘高光泽（SpecularMode none/border/glass，SpecularOpacity，FresnelGlareStrength）
//   玻璃厚度色阶（GlassThickness）
//
// 本工程只写源码，不编译、不签名、不安装。本机为 Windows，无 Theos / Xcode / 真机，
// 以下代码未经过编译或真机验证，请在 Mac 上用 Theos 再按 README 编译打包测试。
//
// 命名空间约定：所有自定义类/函数/selector 带 ZLG 前缀；私有 API 仅在 %hook 声明中使用，
// 并标注来源仅为 hook 用，不保证私有类在未来 iOS 版本可用。

#import <SpringBoard/SpringBoard.h>

// --- 观察自原始 deb 字符串表的控制中心私有类（仅作为 %hook 目标，来源：原始 dylib 字符串）---
// CCUIContentModuleContainerView / CCUIContentModuleContentContainerView
// CCUIModularControlCenterOverlayViewController / CCUIControlCenterWindow
// CCUIContinuousSliderView / CCUIButtonModuleView

// ZLG 配置键（与原始 deb 参数名对照，但使用自有包名前缀避免冲突）
#define ZLGPrefDomain @"com.zegeyoudaoli.liquidglasscc"
#define ZLGPrefEnabled @"enabled"
#define ZLGPrefBlurRadius @"ControlCenter.FullscreenBackdropBlurRadius"
#define ZLGPrefDimColor @"ControlCenter.FullscreenBackdropDimColor"
#define ZLGPrefRefractionScale @"RefractionScale"
#define ZLGPrefRefractiveIndex @"RefractiveIndex"
#define ZLGPrefSpecularMode @"SpecularMode"
#define ZLGPrefSpecularOpacity @"SpecularOpacity"
#define ZLGPrefFresnelGlare @"Renderer.FresnelGlareStrength"
#define ZLGPrefGlassThickness @"GlassThickness"

// ZLGSpecularMode 枚举（对应原始 deb：none / border / glass）
typedef NS_ENUM(NSUInteger, ZLGSpecularMode) {
    ZLGSpecularModeNone = 0,
    ZLGSpecularModeBorder,
    ZLGSpecularModeGlass,
};

extern NSString *const ZLGPrefDomain;
