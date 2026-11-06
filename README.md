# LiquidGlassCC — iOS 越狱 tweak 工程

本工程复刻越狱 deb「液态玻璃」（Liquid (Gl)ass iOS 27 维护版）在控制中心上的效果：在 SpringBoard 的控制中心模块背后注入带背景采样模糊、边缘折射透镜与菲涅尔边缘高光的玻璃视图，并提供 PreferenceLoader 设置面板调节模糊/折射/高光/玻璃厚度。

## 目录结构

```
LiquidGlassCC-iOS/
  Makefile                 # Theos tweak makefile（Rootless 默认，可选 rootful）
  control                  # deb 控制文件（包名 com.zegeyoudaoli.liquidglasscc）
  prefs.mk                 # PreferenceBundle 构建片段
  control                  # （同上）
  Headers/LGConstants.h    # 配置键与枚举（ZLG 前缀，自有命名空间）
  Sources/LGConfig.m       # 只读配置快照，不扫目录、不每帧读文件
  Sources/LGConfig.h
  Sources/LGGlassView.m    # 玻璃材质视图（UIVisualEffectView + CALayer 边缘/高光）
  Sources/LGGlassView.h
  Sources/LGPrefsListController.m   # PreferenceLoader 设置面板（唯一配置写入方）
  Tweak.xm                 # SpringBoard hook 注入点
  Library/PreferenceLoader/Preferences/LiquidAssPrefs.plist
  Library/PreferenceBundles/LiquidAssPrefs.bundle/{Info.plist,Root.plist,en.lproj,zh-Hans.lproj}
  .github/workflows/build.yml  # macOS GitHub Actions 构建（Rootless deb）
  README.md
```

## 包名与命名空间

- deb 包名：`com.zegeyoudaoli.liquidglasscc`
- PreferenceBundle ID：`com.zegeyoudaoli.liquidglasscc.prefs`
- 自定义类/函数/selector 前缀：`ZLG`、`LG`
- 配置域：`com.zegeyoudaoli.liquidglasscc`

与原始 deb 的 `dylv.liquidass` / `com.zegeyoudaoli.liquidass27` 是两个独立标识，不会冲突。

## 可调参数（对照原始 deb 字符串表键）

| 参数 | 对应原始键 | 默认 | 说明 |
|---|---|---|---|
| enabled | — | YES | 总开关，关闭时完全走 %orig |
| blur | `ControlCenter.FullscreenBackdropBlurRadius` | 20 px | 背景高斯模糊半径 |
| dimAlpha | `ControlCenter.FullscreenBackdropDimColor` | 0.35 | 全屏背板压暗不透明度 |
| refractionScale | `RefractionScale` | 20 | 边缘折射透镜强度 |
| refractiveIndex | `RefractiveIndex` | 1.33 | 折射率 |
| specularMode | `SpecularMode` | glass | none / border / glass |
| specularOpacity | `SpecularOpacity` | 0.55 | 边缘高光不透明度 |
| fresnelGlare | `Renderer.FresnelGlareStrength` | 0.6 | 菲涅尔高光强度 |
| glassThickness | `GlassThickness` | 0.35 | 玻璃厚度色阶 |

## hook 目标（SpringBoard，仅观察自原始 deb 字符串表）

- `CCUIModularControlCenterOverlayViewController` — 控制中心展示/收起时安装/移除玻璃视图
- `CCUIContentModuleContentContainerView` — 模块容器，套玻璃边框与圆角
- `CCUIContinuousSliderView` — 滑块选中时透镜高亮
- `CCUIButtonModuleView` — 按钮高亮时透镜高光

注：以上为 iOS 私有类，来源仅为原始 deb 字符串表，未来 iOS 版本可能变更，编译前请在目标设备上用 `class-dump` / `imon` 核实。

## 编译打包（Mac 上，需 Theos + Xcode）

本机为 Windows，不带 Theos / Xcode，以下命令未经过编译或真机验证：

```bash
# Rootless deb（默认）
make package THEOS_PACKAGE_SCHEME=rootless SDKVERSION=16.5

# Rootful deb
make package THEOS_PACKAGE_SCHEME=rootful SDKVERSION=16.5
```

生成的 `packages/*.deb` 可用 `dpkg-deb` 检查，或用 Sileo/Zebra 安装到越狱设备。安装后重启 SpringBoard 生效。

## 未验证事项

- 本机无 Theos / Xcode / 真机，代码**未经过编译**，未在 iOS 设备上运行。
- `UIVisualEffectView` 不直接暴露 blur radius，blurRadius 参数目前通过颜色层叠加近似；如需精确半径，建议把 `LGGlassView.m` 里的模糊层换成 `CIImage`/`CIFilter`（CIGaussianBlur）实时渲染墙纸截图。
- `CCUI* 私有类` 是观察自原始 deb 字符串表，未在目标 iOS 版本上 class-dump 核实。
- `prefs.mk` 里的 `LiquidGlassCCPrefs` target 与主 Makefile 未整合为一个 `make package` 输出（PreferenceBundle 需单独或合并打包），请根据实际 Theos 版本调整。
