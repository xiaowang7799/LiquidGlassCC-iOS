#import "LGConfig.h"

@implementation ZLGConfig {
    BOOL _enabled;
    CGFloat _blurRadius;
    CGFloat _dimAlpha;
    CGFloat _refractionScale;
    CGFloat _refractiveIndex;
    ZLGSpecularMode _specularMode;
    CGFloat _specularOpacity;
    CGFloat _fresnelGlare;
    CGFloat _glassThickness;
}

+ (instancetype)sharedConfig {
    static ZLGConfig *shared = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
        [shared reload];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _blurRadius = 20.0f;
        _dimAlpha = 0.35f;
        _refractionScale = 20.0f;
        _refractiveIndex = 1.33f;
        _specularMode = ZLGSpecularModeGlass;
        _specularOpacity = 0.55f;
        _fresnelGlare = 0.6f;
        _glassThickness = 0.35f;
    }
    return self;
}

// 优先读取 PreferenceLoader 的偏好 plist；Rootless/Rootful/Roothide 三种环境下的
// 配置目录不同，这里按环境探测三个候选路径，不扫描目录。
static NSString *ZLGPreferencePlistPath(void) {
    NSArray *candidates = @[
        @"/var/mobile/Library/Preferences/com.zegeyoudaoli.liquidglasscc.plist",   // Rootless / Roothide 通用
        @"/private/var/mobile/Library/Preferences/com.zegeyoudaoli.liquidglasscc.plist", // Rootful
        @"/var/mobile/Containers/Data/Application/com.zegeyoudaoli.liquidglasscc/Library/Preferences/com.zegeyoudaoli.liquidglasscc.plist"
    ];
    for (NSString *path in candidates) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return path;
    }
    return candidates.firstObject; // 默认首选，面板会在此写入
}

- (void)reload {
    NSString *path = ZLGPreferencePlistPath();
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!dict) dict = @{};

    _enabled = [dict[ZLGPrefEnabled] boolValue];
    if (!_enabled) _enabled = YES; // 未配置时默认开启，由总开关关闭

    _blurRadius = [dict[ZLGPrefBlurRadius] floatValue];
    if (_blurRadius <= 0) _blurRadius = 20.0f;

    _dimAlpha = [dict[ZLGPrefDimColor] floatValue];
    if (_dimAlpha < 0 || _dimAlpha > 1) _dimAlpha = 0.35f;

    _refractionScale = [dict[ZLGPrefRefractionScale] floatValue];
    if (_refractionScale < 0) _refractionScale = 20.0f;

    _refractiveIndex = [dict[ZLGPrefRefractiveIndex] floatValue];
    if (_refractiveIndex <= 0) _refractiveIndex = 1.33f;

    NSString *mode = dict[ZLGPrefSpecularMode];
    if ([mode isEqualToString:@"none"]) _specularMode = ZLGSpecularModeNone;
    else if ([mode isEqualToString:@"border"]) _specularMode = ZLGSpecularModeBorder;
    else _specularMode = ZLGSpecularModeGlass;

    _specularOpacity = [dict[ZLGPrefSpecularOpacity] floatValue];
    if (_specularOpacity < 0 || _specularOpacity > 1) _specularOpacity = 0.55f;

    _fresnelGlare = [dict[ZLGPrefFresnelGlare] floatValue];
    if (_fresnelGlare < 0 || _fresnelGlare > 1) _fresnelGlare = 0.6f;

    _glassThickness = [dict[ZLGPrefGlassThickness] floatValue];
    if (_glassThickness < 0 || _glassThickness > 1) _glassThickness = 0.35f;
}

@end
