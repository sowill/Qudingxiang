# Qudingxiang
趣定向 线上与线下结合的定向类APP 完整项目</br>
通过系统推送点标任务，计时完成定向比赛。</br>
线上丰富的活动介绍 在线购买</br>
主要功能介绍：
------- 
>
####首页产品展示
####活动介绍
####订单支付功能
####个人信息管理
####活动游戏页面

####用到的第三方框架，库有：</br>
AFNetworking</br>
MJExtension</br>
MjRefresh</br>
MBProgressHUD</br>
RESideMenu</br>

####用到的第三方api有：</br>
微信，QQ，支付宝，高德地图</br>

####用到的系统服务有：</br>
蓝牙4.0 二维码扫描生成</br>

####离线主要通过：</br>
sqlite，本地文件</br>

---

## Swift 迁移说明（`swift-migration` 分支）

本分支对项目进行现代化升级，目标：

1. 适配最新 iOS（最低 iOS 15，目标 iOS 17+）
2. 项目语法从 Objective-C 迁移到 Swift
3. 更新依赖库为现代版本
4. 优化各界面视觉效果

### 已完成

| 模块 | 状态 | 文件 |
|------|------|------|
| 工程配置 | ✅ | `Info.plist`（新权限文案、后台模式、LaunchScreen、arm64、ProMotion） |
| 依赖管理 | ✅ | `Podfile`（Alamofire、SnapKit、SDWebImage、MJRefresh、MBProgressHUD、高德 SDK、微信/QQ/支付宝最新版、ReachabilitySwift、KeychainAccess 等） |
| 全局常量/主题 | ✅ | `Swift/Constants.swift`（SDK Key、API 路径、屏幕尺寸、配色、字体、UIColor 扩展） |
| App 入口 | ✅ | `Swift/AppDelegate.swift`（SDK 注册、自动登录、版本引导、全局外观） |
| 基类控制器 | ✅ | `Swift/BaseViewController.swift`（返回按钮、网络监听、HUD、空数据占位） |
| 账号管理 | ✅ | `Swift/AccountManager.swift`（Keychain 存储 token，替代 NSKeyedArchiver） |
| 网络层 | ✅ | `Swift/NetworkService.swift`（Alamofire 封装、Codable 解析、统一错误、上传） |
| 核心模型 | ✅ | `Swift/Models.swift`（Customer/Goods/Orders/Line/City/Area/Partner/Banner，Codable） |
| 主 TabBar | ✅ | `Swift/MainTabBarController.swift`（原生 TabBar + 未登录拦截 + 自定义导航） |
| 引导页 | ✅ | `Swift/GuideViewController.swift`（渐变背景 + 分页 + 进入按钮） |
| 登录页 | ✅ | `Swift/LoginViewController.swift`（卡片式表单、渐变头部、第三方入口） |
| 首页 | ✅ | `Swift/HomeController.swift`（城市选择、Banner、CompositionalLayout、活动卡片） |
| 游戏核心 | ✅ | `Swift/GameViewController.swift`（CoreBluetooth 感应 Beacon、进度条、点标列表） |
| 发现/订单/我的 | 占位 | `Swift/PlaceholderControllers.swift`（后续逐模块迁移） |

### 集成步骤（在新分支基础上）

1. **安装依赖**：`pod install`（需 CocoaPods 1.12+，建议使用 Ruby 3.x）。
2. **添加 Swift 源码到工程**：在 Xcode 中将 `Qudingxiang/Swift/` 整个目录拖入 `Qudingxiang` target，勾选 *Copy items if needed* 取消（保留引用即可），*Add to targets* 勾选 `Qudingxiang`。
3. **配置 Bridging Header**：Xcode 会提示创建 Bridging Header，命名为 `Qudingxiang/Qudingxiang-Bridging-Header.h`，内容暂时留空（如需 OC 调 Swift，引入 `<Qudingxiang/Qudingxiang-Swift.h>`）。
4. **移除 OC 入口冲突**：删除 `main.m` 和 `AppDelegate.h/.m`（已被 `Swift/AppDelegate.swift` 的 `@main` 取代，否则会出现 *duplicate symbol _main*）。
5. **设置 Swift 版本**：Build Settings → `SWIFT_VERSION = 5.9`，`IPHONEOS_DEPLOYMENT_TARGET = 15.0`。
6. **构建运行**：此时主流程（引导 → TabBar → 首页 → 登录 → 游戏）由 Swift 接管；其余 OC 控制器仍可在 OC→Swift 混编下继续使用，按下方路线图逐个迁移。

### 迁移路线图（剩余模块）

按依赖与价值排序，建议分批迁移：

**第一批 — 用户与订单**
- `QDXRegisterViewController` / `QDXForgetPasswordViewController` / `QDXBindViewController`
- `OrderController` / `QDXOrderDetailTableViewController` / `QDXPayTableViewController`
- 支付回调：微信 / 支付宝 / QQ（接入 `WechatOpenSDK`、`AlipaySDK`）

**第二批 — 活动与场地**
- `QDXActivityViewController` / `QDXActivityPriceViewController` / `RecentActivityViewController`
- `PlaceViewController` / `LocationChoiceViewController` / `MoreCooperationViewController`
- `QDXLineChooseViewController` / `QDXLineDetailViewController` / `LineController` / `TeamLineController` / `MineLineController`

**第三批 — 游戏与地图**
- `MapViewController`（高德 MAMapKit 迁移）
- `BaseGameViewController` / `QDXHistoryViewController` / `QDXTicketSuccessViewController`
- `QDXPointListViewController` / `QDXPointSettingViewController`
- `QDXTeamsViewController` / `QDXTaskViewController`

**第四批 — 我的与设置**
- `MineViewController` / `editMineInfoViewController` / `MineCardViewController`
- `QDXChangeNameViewController` / `QDXChangePwdViewController`
- `SettingViewController` / `AboutUsViewController` / `HelpViewController` / `NoticeViewController` / `QDXProtocolViewController`
- `QDXCreateCodeViewController` / `ImagePickerController`（用原生 Vision/CoreImage 替代 ZBar/libqrencode）

**第五批 — 离线**
- `LocalDBService` / `LocalSqlliteService` / `QDXOfflineDB`（迁移至 SQLite.swift 或 GRDB）
- `QDXOffLineController`

**第六批 — 视图与工具**
- `View/` 下所有 Cell / 自定义视图（用 SwiftUI 或纯 Swift UIKit 重写）
- `Tool/` 工具类（`CheckDataTool`、`UIImage+watermark` 等）
- 清理 `Lib/` 下已替代的 OC 第三方库（AFNetworking、MJExtension、ZBar、libqrencode、SGNetObserver 等）

### 视觉优化要点

- 全局配色统一走 `QDXColor`，字体走 `QDXFont`（按 750 设计稿等比适配）。
- 导航栏使用 `UINavigationBarAppearance` 不透明样式，主色 `#0099FD`。
- 列表统一 `UICollectionViewCompositionalLayout` + 圆角卡片 + 阴影。
- 引导页 / 登录页采用 `CAGradientLayer` 渐变。
- 按钮 24pt 圆角 + 阴影；输入框卡片化；空数据 / 无网络占位统一封装在 `BaseViewController`。
- 适配 Safe Area 与 ProMotion（`CADisableMinimumFrameDurationOnPhone`）。

### 备注

- 原有 OC 代码完整保留，方便对照迁移与回退。
- API 路径与字段全部沿用旧后端，未做协议变更。
- 蓝牙 Beacon、二维码、支付的具体回调逻辑需在各模块迁移时接入对应 SDK。
