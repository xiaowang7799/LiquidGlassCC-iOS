TWEAK_NAME = LiquidGlassCCPrefs
LiquidGlassCCPrefs_FILES = Sources/LGPrefsListController.m
LiquidGlassCCPrefs_INSTALL_PATH = /Library/PreferenceBundles/LiquidAssPrefs.bundle
LiquidGlassCCPrefs_FRAMEWORKS = UIKit
LiquidGlassCCPrefs_PRIVATE_FRAMEWORKS = Preferences
LiquidGlassCCPrefs_CFLAGS = -fobjc-arc -IHeaders -I../Tweak
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp Library/PreferenceLoader/Preferences/LiquidAssPrefs.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(ECHO_END)
