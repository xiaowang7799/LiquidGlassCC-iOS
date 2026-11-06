/*
 * Root.plist 里的 SpecularMode 枚举索引与 ZLGSpecularMode 枚举值一一对应：
 *   0 = ZLGSpecularModeNone（无）
 *   1 = ZLGSpecularModeBorder（边框）
 *   2 = ZLGSpecularModeGlass（玻璃）
 * PreferenceLoader 的 PSLinkCell detailValues 按顺序对应，无需额外转换。
 */
#import "LGConstants.h"
