#import "LGConstants.h"

NSString *const ZLGPrefDomain = @"com.zegeyoudaoli.liquidglasscc";

// ZLGConfig —— 只读配置快照。面板是配置的唯一写入方，Tweak 端不持久化默认值，
// 每次 hook 只读一次快照并复用，不扫目录、不每帧读文件。
@interface ZLGConfig : NSObject
@property (nonatomic, assign, readonly) BOOL enabled;
@property (nonatomic, assign, readonly) CGFloat blurRadius;
@property (nonatomic, assign, readonly) CGFloat dimAlpha;
@property (nonatomic, assign, readonly) CGFloat refractionScale;
@property (nonatomic, assign, readonly) CGFloat refractiveIndex;
@property (nonatomic, assign, readonly) ZLGSpecularMode specularMode;
@property (nonatomic, assign, readonly) CGFloat specularOpacity;
@property (nonatomic, assign, readonly) CGFloat fresnelGlare;
@property (nonatomic, assign, readonly) CGFloat glassThickness;

+ (instancetype)sharedConfig;
- (void)reload;
@end
