# 趣定向 Swift 迁移版 Podfile
# 最低支持 iOS 15.0，目标兼容至 iOS 17+

platform :ios, '15.0'
inhibit_all_warnings!

# Swift 项目使用 frameworks
use_frameworks!

target 'Qudingxiang' do
  # ---------- 网络 ----------
  pod 'Alamofire', '~> 5.9'                 # 替代 AFNetworking

  # ---------- JSON / 模型 ----------
  # MJExtension 已被 Swift 原生 Codable 取代，无需引入

  # ---------- 图片 ----------
  pod 'SDWebImage', '~> 5.19'               # 图片加载与缓存
  pod 'SDWebImageSVGKitPlugin'              # SVG 支持（如有 SVG 资源）

  # ---------- 下拉刷新 ----------
  pod 'MJRefresh', '~> 3.7'                 # 兼容 Swift / OC

  # ---------- HUD ----------
  pod 'MBProgressHUD', '~> 1.2'             # 兼容 Swift
  pod 'SVProgressHUD'                       # 备选现代 HUD

  # ---------- 布局 ----------
  pod 'SnapKit', '~> 5.7'                   # AutoLayout 链式 DSL

  # ---------- 缓存 ----------
  pod 'YYCache'                             # 本地缓存，仍可用

  # ---------- 地图 ----------
  pod 'AMap3DMap'                           # 高德 3D 地图（最新版）
  pod 'AMapSearch'                          # 高德搜索
  pod 'AMapLocation'                        # 高德定位
  pod 'AMapNavi'                            # 高德导航

  # ---------- 二维码 ----------
  # 用原生 CoreImage / Vision 生成与扫描，替代 libqrencode / ZBar

  # ---------- 第三方登录 / 分享 / 支付 ----------
  pod 'WechatOpenSDK-XCFramework', '~> 2.0' # 微信（含支付/登录/分享）
  pod 'TencentOpenApiSDK'                   # QQ 互联（社区维护 Swift 友好版）
  pod 'AlipaySDK-iOS'                       # 支付宝最新版

  # ---------- 工具 ----------
  pod 'ReachabilitySwift'                   # 替代 SGNetObserver
  pod 'KeychainAccess'                      # 安全存储 token
  pod 'Kingfisher', '~> 7.0'                # 备选图片库（更现代）
  pod 'IQKeyboardManagerSwift'              # 键盘适配
  pod 'SkeletonView'                        # 列表骨架屏
  pod 'EmptyDataSet-Swift'                  # 空数据占位

  target 'QudingxiangTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['SWIFT_VERSION'] = '5.9'
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
    end
  end
end
