ARCHS = arm64
TARGET := iphone:clang:15.0:15.0

include $(THEOS)/makefiles/common.mk

# 主 tweak：注入 SpringBoard，实现控制中心液态玻璃
TWEAK_NAME = LiquidGlassCC
LiquidGlassCC_FILES = Tweak.xm \
                      Sources/LGGlassView.m \
                      Sources/LGConfig.m
LiquidGlassCC_CFLAGS = -fobjc-arc -Wall -Wextra -IHeaders
LiquidGlassCC_FRAMEWORKS = UIKit CoreGraphics QuartzCore CoreImage
LiquidGlassCC_PRIVATE_FRAMEWORKS = ControlCenterUI
LiquidGlassCC_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

# Rootless 打包：THEOS_PACKAGE_SCHEME=rootless；Rootful/Roothide 由 make THEOS_PACKAGE_SCHEME=rootful 覆写。
# 打包：make package                -> Rootless deb
#      make package PACKAGE_SCHEME=rootful  -> Rootful deb
# PreferenceBundle（设置面板）按 prefs.mk 单独或合并打包，Theos 版本差异较大，
# 此处不自动并入主 make，见 README“未验证事项”。

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
