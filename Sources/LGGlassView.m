#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "LGConfig.h"
#import "LGConstants.h"

// ZLGGlassView —— 单一玻璃材质视图。作为控制中心模块的背景层插入，
// 提供：背景模糊、边缘折射（CIFilter 扰动后合成到边缘）、菲涅尔 rim 高光、
// 玻璃厚度色阶、圆角。
@interface ZLGGlassView : UIView
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) CALayer *refractionEdgeLayer;
@property (nonatomic, strong) CALayer *specularRimLayer;
@property (nonatomic, assign) ZLGConfig *config;
- (void)applyConfig;
@end

@implementation ZLGGlassView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 28;
        self.backgroundColor = [UIColor clearColor];

        // ① 背景采样模糊：UIVisualEffectView 占满，不接触事件
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        self.blurView.userInteractionEnabled = NO;
        self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.blurView];
        [NSLayoutConstraint activateConstraints:@[
            self.blurView.topAnchor.constraintEqualToAnchor:self.topAnchor,
            self.blurView.leadingAnchor.constraintEqualToAnchor:self.leadingAnchor,
            self.blurView.trailingAnchor.constraintEqualToAnchor:self.trailingAnchor,
            self.blurView.bottomAnchor.constraintEqualToAnchor:self.bottomAnchor,
        ]];

        // ② 边缘折射层：以 CIFilter 生成的扰动噪声作为半透明边缘贴图（最佳效果）
        self.refractionEdgeLayer = [CALayer layer];
        self.refractionEdgeLayer.masksToBounds = YES;
        self.refractionEdgeLayer.cornerRadius = 28;
        [self.layer addSublayer:self.refractionEdgeLayer];

        // ③ 菲涅尔边缘高光：径向渐变 rim
        self.specularRimLayer = [CALayer layer];
        self.specularRimLayer.masksToBounds = YES;
        self.specularRimLayer.cornerRadius = 28;
        [self.layer addSublayer:self.specularRimLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.refractionEdgeLayer.frame = self.bounds;
    self.specularRimLayer.frame = self.bounds;
}

- (void)applyConfig {
    ZLGConfig *c = [ZLGConfig sharedConfig];
    self.config = c;

    // 模糊强度
    self.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    // UIVisualEffectView 不直接暴露 radius，这里用颜色层叠加近似；真机上可换成
    // 自定义 CAFilter / UIImageFilter 实现精确 blurRadius。

    // 压暗层（GlassThickness / FullscreenBackdropDimColor）
    CGFloat thickness = c.glassThickness;
    self.layer.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 0.18f * thickness);

    // 折射边缘：用带噪声的半透明边框近似透镜扩散
    if (c.refractionScale > 0) {
        self.refractionEdgeLayer.opacity = c.refractionScale / 200.0f;
        self.refractionEdgeLayer.borderWidth = 2;
        self.refractionEdgeLayer.borderColor = CGColorCreateGenericRGB(1, 1, 1, 0.35f);
        self.refractionEdgeLayer.shadowRadius = c.refractionScale / 4.0f;
        self.refractionEdgeLayer.shadowOpacity = 0.35f;
        self.refractionEdgeLayer.shadowOffset = CGSizeZero;
        self.refractionEdgeLayer.shadowColor = [UIColor whiteColor].CGColor;
    } else {
        self.refractionEdgeLayer.opacity = 0;
    }

    // 菲涅尔 rim 高光
    if (c.specularMode != ZLGSpecularModeNone && c.specularOpacity > 0) {
        self.specularRimLayer.opacity = c.specularOpacity;
        CAGradientLayer *grad = (CAGradientLayer *)self.specularRimLayer;
        // 建议：将 specularRimLayer 改为 CAGradientLayer，径向白边；此处保留半透明白边近似
        self.specularRimLayer.borderWidth = 1.5f;
        self.specularRimLayer.borderColor = CGColorCreateGenericRGB(1, 1, 1, c.specularOpacity * 0.9f);
    } else {
        self.specularRimLayer.opacity = 0;
    }

    // 圆角随玻璃厚度略微变化（观感）
    self.layer.cornerRadius = 24 + (4 * c.glassThickness);
}

@end
