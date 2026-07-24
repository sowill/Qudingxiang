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
| 登录页 | ✅ | `Swift/LoginViewController.swift`（卡片式表单、渐变头部、第三方入口、注册/找回跳转） |
| 注册 / 忘记密码 / 修改密码 | ✅ | `Swift/RegisterViewController.swift`、`ForgetPasswordViewController.swift`、`ChangePasswordViewController.swift` |
| 表单组件 | ✅ | `Swift/FormFields.swift`（FormField、PrimaryButton）、`Validator.swift`（替代 CheckDataTool） |
| 首页 | ✅ | `Swift/HomeController.swift`（城市选择、Banner、CompositionalLayout、活动卡片） |
| 订单列表 / 详情 | ✅ | `Swift/OrderListController.swift`（分段 + 卡片）、`OrderDetailViewController.swift` |
| 订单 / 支付 API | ✅ | `Swift/OrderAPI.swift`（订单增删查 + 微信/支付宝参数）、`Models.swift` 已含 OrderInfo/WeixinPayParam/AlipayParam |
| 支付页 / 支付管理 | ✅ | `Swift/PayViewController.swift`（金额卡片 + 单选支付方式）、`PayManager.swift`（微信/支付宝统一拉起） |
| 活动 / 场地 API | ✅ | `Swift/ContentAPI.swift`（城市/场地/活动/合作/报名）、`Models.swift` 扩展 City/Area + `PagedList<T>` |
| 活动列表（分段） | ✅ | `Swift/ActivityListController.swift`（UISegmentedControl + 横向分页 + 子列表） |
| 活动卡片 Cell | ✅ | `Swift/ActivityCell.swift`（封面大图 + 状态徽标 + 价格） |
| 场地产品列表 | ✅ | `Swift/AreaGoodsListController.swift`（场地下的活动列表） |
| 场地列表 | ✅ | `Swift/PlaceController.swift`（网格 + 城市切换 + PlaceCell） |
| 城市选择 | ✅ | `Swift/CityChoiceController.swift`（定位 + 开放城市标签，左对齐 FlowLayout） |
| 线路详情 | ✅ | `Swift/LineDetailViewController.swift`（WKWebView + 进度条 + 报名抽屉：步进器/总价/去支付） |
| 游戏 API / 模型 | ✅ | `Swift/GameAPI.swift`（任务刷新/定位/历史/退赛）、`Models.swift` 追加 TaskRefresh/History/Pointmap/TaskLocation |
| 地图 | ✅ | `Swift/MapViewController.swift`（高德 MAMapKit + 自定义底图 + 点标 + 悬浮按钮） |
| 弹层容器 | ✅ | `Swift/PopContainerView.swift`（底部上浮圆角容器，替代 QDXPopView） |
| 二维码生成 | ✅ | `Swift/QRCodeGenerator.swift`（CoreImage 替代 libqrencode） |
| 游戏核心 | ✅ | `Swift/BaseGameViewController.swift`（4 状态机 + 蓝牙感应 MAC + 倒计时 + WKWebView 任务书 + JS 回调 + 完成弹层） |
| 定向足迹 | ✅ | `Swift/HistoryViewController.swift`（足迹列表 + 详情 WebView） |
| 我的 API / 模型 | ✅ | `Swift/MineAPI.swift`（authLogin/modify/myLines/teamLines/cards）+ `Myline`/`Card` 模型 |
| 个人中心 | ✅ | `Swift/MineController.swift`（渐变头部 + 圆角头像 + 头像上传 + 卡片表格） |
| 编辑资料 | ✅ | `Swift/EditMineInfoController.swift`（昵称/手机/签名） |
| 我的/团队线路 | ✅ | `Swift/MyLineListController.swift`（按 Mode 区分个人/团队） |
| 我的卡包 | ✅ | `Swift/MineCardController.swift`（卡包列表 + 二维码弹层） |
| 设置 | ✅ | `Swift/SettingController.swift`（缓存清理/修改密码/退出登录） |
| 关于我们 | ✅ | `Swift/AboutUsController.swift`（Logo+版本+简介+须知+点标管理，含 `WebViewController`） |
| 发现 | ✅ | `Swift/DiscoverController.swift`（承载 PlaceController） |
| 离线缓存服务 | ✅ | `Swift/OfflineDBService.swift`（Codable + JSON 文件，替代 LocalDBService 的 NSKeyedArchiver；提供 loadDb/checkTask/passChange/checkHistory/writeHistory/readMylineInfo/readMyline/writeMyline/readQuestion/resetQuestion/uploadHistory） |
| 离线下载库 | ✅ | `Swift/OfflineDownloadStore.swift`（SQLite.swift，替代 QDXOfflineDB 的 sqlite3 C API；6 表 CRUD + 去重 + OfflineDownloadAPI 拉取并落地 myline/point/question/地图图片） |
| 离线游戏控制器 | ✅ | `Swift/OfflineGameViewController.swift`（替代 QDXOffLineController：下载按钮 + 开始按钮 + 地图 + 计时 + 目标点标 + CoreBluetooth 扫描 + UIAlertController 四选一 + 历史/详情/扫码/退赛菜单） |
| UIKit 工具扩展 | ✅ | `Swift/UIKitExtensions.swift`（集中迁移 ToolView / UIImage+watermark / UIImage+RTTint / UIButton+ImageText / NSMutableAttributedString+ChangeColorFont；新增 `QDXStateView` 通用占位视图） |
| 二维码扫描 | ✅ | `Swift/QRScannerViewController.swift`（替代 ImagePickerController，AVFoundation 现代化 + 扫描框 + 扫描线动画 + ScanResult 回调） |
| 绑定/协议/门票/帮助/通知 | ✅ | `Swift/MiscControllers.swift`（BindPhoneViewController / ProtocolViewController / TicketSuccessViewController / HelpViewController / NoticeViewController；含 `Notification.Name.stateRefresh` 扩展） |
| 点标管理 | ✅ | `Swift/PointManageControllers.swift`（PointListController inset grouped 列表 + PointSettingController 高德地图定位 + pointModify 提交；含 `PointItem` 模型与 `PointAPI`） |
| 组队 | ✅ | `Swift/TeamsViewController.swift`（3 段表格：扫一扫组队 / 队名 / 队长+4 队员；QRCode 弹层 SDWebImage 加载；含 `TeamMember` 模型与 `TeamsAPI` getTeam/teamQRCode/setTeam；`TeamInputCell` 替代 TextFieldTableViewCell + UITextField+IndexPath） |
| 任务卡弹层 | ✅ | `Swift/TaskCardViewController.swift`（替代 QDXTaskViewController，子控制器模式弹出：闯关成功图 + 查看提示按钮 → 标题栏 + WKWebView 加载 mylineweb + 好的/关闭按钮） |
| 个性签名 / 合作单位 / 线路选择 | ✅ | `Swift/MoreControllers.swift`（SignController 卡片式签名编辑 + 字数统计；MoreCooperationController CompositionalLayout 合作单位网格；LineChooseController 地图+介绍+selectMyline + 双击全屏图 FullScreenImageViewController 替代 JTSImage） |
| 玩法 / 区域路线 / 注册验证码 | ✅ | `Swift/RemainingControllers.swift`（MoreController 3 种玩法分页；AreaLineListController 调 linesByArea 区域路线列表；CreateCodeViewController setVcode+validateCode 进入注册） |

### OC 控制器迁移覆盖情况

经逐文件比对，`Controller/` 下所有 OC 控制器均已由 Swift 覆盖（部分合并迁移）：

| OC 控制器 | Swift 替代 | 说明 |
|-----------|-----------|------|
| SignViewController | SignController | 签名编辑，合并字数统计 |
| MoreCooperationViewController | MoreCooperationController | CompositionalLayout 网格 |
| QDXLineChooseViewController / LineController | LineChooseController | 线路选择 + 自带全屏图查看 |
| MoreViewController | MoreController | 玩法介绍分页 |
| CellLineController | AreaLineListController | 区域路线列表（ContentAPI.linesByArea） |
| QDXCreateCodeViewController | CreateCodeViewController | 注册前验证码 |
| codeWebViewController | WebViewController（AboutUsController.swift） | 通用 WebView 容器，已覆盖 |
| QDXChangeNameViewController | EditMineInfoController | 已合并入编辑资料 |
| QDXNavigationController | MainTabBarController.swift 内同名类 | 自定义导航 |
| LBTabBarController | MainTabBarController | 4 tab（中间发布按钮入口待评估） |
| RecentActivityViewController / ActivityController | ActivityListController | 合并分段列表 |
| TeamLineController / MineLineController | MyLineListController | 按 Mode 区分 |
| QDXActivityPriceViewController | AreaGoodsListController | 场地产品列表 |
| LocationChoiceViewController | CityChoiceController | 城市选择 |
| ImagePickerController | QRScannerViewController | AVFoundation 扫码 |
| 其余 QDX* / Mine* / Home / Place / Help / Notice / Setting / AboutUs 等 | 见上表对应行 | 均已迁移 |

### 集成步骤（在新分支基础上）

1. **安装依赖**：`pod install`（需 CocoaPods 1.12+，建议使用 Ruby 3.x）。
2. **添加 Swift 源码到工程**：在 Xcode 中将 `Qudingxiang/Swift/` 整个目录拖入 `Qudingxiang` target，勾选 *Copy items if needed* 取消（保留引用即可），*Add to targets* 勾选 `Qudingxiang`。
3. **配置 Bridging Header**：Xcode 会提示创建 Bridging Header，命名为 `Qudingxiang/Qudingxiang-Bridging-Header.h`，内容暂时留空（如需 OC 调 Swift，引入 `<Qudingxiang/Qudingxiang-Swift.h>`）。
4. **移除 OC 入口冲突**：删除 `main.m` 和 `AppDelegate.h/.m`（已被 `Swift/AppDelegate.swift` 的 `@main` 取代，否则会出现 *duplicate symbol _main*）。
5. **设置 Swift 版本**：Build Settings → `SWIFT_VERSION = 5.9`，`IPHONEOS_DEPLOYMENT_TARGET = 15.0`。
6. **构建运行**：此时主流程（引导 → TabBar → 首页 → 登录 → 游戏）由 Swift 接管；其余 OC 控制器仍可在 OC→Swift 混编下继续使用，按下方路线图逐个迁移。

### Lib/ 清理说明（文档化，未执行删除）

> 经评估，`Lib/` 下 OC 第三方库均已被 `Podfile` 中的现代 Pod 或 Swift 原生方案替代。但仓库内 OC 控制器/模型/服务仍 `#import` 这些库，直接删除会导致 OC 源码引用悬空；且本仓库不含 `.xcodeproj`，无法在此环境管理构建阶段。因此清理以**文档化**方式记录，实际删除请在 Xcode 集成后按下方步骤执行。

**前提**：执行任何删除前，必须先在 Xcode 中将对应 OC 文件从 `Qudingxiang` target 的 *Compile Sources* / *Copy Bundle Resources* 中移除（或删除 OC 文件本身），否则会产生悬空引用与编译错误。

#### 可删除（已被 Pod / Swift 原生替代）

| Lib/ 子目录 | 替代方案 |
|-------------|----------|
| `AFNetworking/` | `pod 'Alamofire'`（NetworkService.swift） |
| `MJExtension/` | Swift 原生 `Codable`（Models.swift） |
| `MJRefresh/` | `pod 'MJRefresh'`（Pod 版，Swift 可用） |
| `SDWebImage/` | `pod 'SDWebImage'`（Pod 版） |
| `MBProgressHUD/`（含 MBProgressHUD+MJ） | `pod 'MBProgressHUD'`（Pod 版） |
| `SGNetObserver/` | `pod 'ReachabilitySwift'`（BaseViewController） |
| `LocalCache/`（含 Reachability/Util） | ReachabilitySwift + 系统缓存 |
| `CYAlertController/` | 系统 `UIAlertController` |
| `JTSImage/` | `FullScreenImageViewController`（MoreControllers.swift） |
| `LXActivity/` | 系统 `UIActivityViewController` |
| `EAFeatureGuideView/` | `GuideViewController.swift` |
| `ImgPageScrollView/` | `GuideViewController.swift` / `MoreController` |
| `Need/`（转场动画） | 系统导航转场 / 自定义 UIViewControllerAnimatedTransitioning |
| `PopMenuView/`（LrdOutputView） | `PopContainerView.swift` / `UIAlertController` |
| `TTSExample/` | 系统 `AVSpeechSynthesizer`（按需） |
| `XBScrollPageController/` | `ActivityListController` 横向分页 |
| `YLPopView/` | `PopContainerView.swift` |
| `libqrencode/` | `QRCodeGenerator.swift`（CoreImage） |
| `Category/`（UIImage+Image / UIView+LBExtension） | `UIKitExtensions.swift` + SnapKit |
| `SDK1.6.2/`（旧微信 SDK） | `pod 'WechatOpenSDK-XCFramework'` |
| `TencentOpenAPI.framework/` | `pod 'TencentOpenApiSDK'` |
| `TencentOpenApi_IOS_Bundle.bundle/` | 同上 Pod 自带 |
| `AlipaySDK/` | `pod 'AlipaySDK-iOS'` |
| `MAMapKit.framework/` | `pod 'AMap3DMap'` |
| `AMapFoundationKit.framework/` | `pod 'AMap3DMap'` 依赖自带 |
| `AMap.bundle/` | AMap3DMap Pod 自带 |
| `YYCache/` | `pod 'YYCache'`（Pod 版，离线可选用） |

#### 仍需保留（无 Pod 替代或属自有资产）

- `Qudingxiang/WewayBeaconKit/`：iBeacon Kit 头文件。Swift 离线模块已改用 `CoreBluetooth` 直接扫描，但若仍需通过 Bridging Header 调用原厂 SDK 可保留；确认无引用后亦可删除。

> 注：`Tool/`、`View/`、`Model/`、`qdxModel/`、`Service/`、`Controller/` 下的 OC 文件均为自有业务代码，其功能已由 `Swift/` 覆盖。全量切换到纯 Swift 时可一并删除，但需同步更新 `.xcodeproj` 构建阶段，建议在 Xcode 中操作。

### 迁移路线图（剩余模块）

按依赖与价值排序，建议分批迁移：

**第一批 — 用户与订单** ✅ 已完成
- `QDXRegisterViewController` / `QDXForgetPasswordViewController` / `QDXChangePwdViewController` → `RegisterViewController` / `ForgetPasswordViewController` / `ChangePasswordViewController`
- `OrderController` / `QDXOrderDetailTableViewController` → `OrderListController` / `OrderDetailViewController`
- `QDXPayTableViewController` → `PayViewController` + `PayManager`（微信/支付宝统一拉起）
- `CheckDataTool` → `Validator`
- 待补：`QDXBindViewController`（QQ/微信绑定）、微信/支付宝 SDK 真实回调接入

**第二批 — 活动与场地** ✅ 已完成
- `QDXActivityViewController` + `RecentActivityViewController` → `ActivityListController`（分段 + 横向分页 ScrollView + 子列表）
- `QDXActivityPriceViewController` → `AreaGoodsListController`（场地产品列表）
- `PlaceViewController` → `PlaceController`（场地网格 + 城市切换入口）
- `LocationChoiceViewController` → `CityChoiceController`（定位 + 开放城市标签，左对齐 FlowLayout）
- `QDXLineDetailViewController` → `LineDetailViewController`（WKWebView + 进度条 + 报名抽屉：步进器/总价/去支付）
- `QDXActTableViewCell` → `ActivityCell`（封面大图卡片）
- API：`ContentAPI`（城市/场地/活动/合作/报名）
- 模型扩展：`City`/`Area` 增加省/区字段，新增 `PagedList<T>`
- 待补：`MoreCooperationViewController`（合作单位）、`QDXLineChooseViewController` / `LineController` / `TeamLineController` / `MineLineController`（线路选择与我的线路）

**第三批 — 游戏与地图** ✅ 已完成
- `MapViewController.m` → `MapViewController.swift`（高德 MAMapKit + 自定义底图覆盖 + 点标 + 圆角悬浮按钮 + 卫星/平面切换）
- `BaseGameViewController.m` → `BaseGameViewController.swift`（4 状态机：待开始/进行中/已完成/已失败 + CoreBluetooth 感应 MAC + 倒计时 + WKWebView 任务书 + JS Success 回调 + 完成弹层弹簧动画 + 更多菜单）
- `QDXHistoryViewController.m` → `HistoryViewController.swift`（足迹列表 + 详情 WebView）
- `QDXPopView` → `PopContainerView.swift`（底部上浮圆角容器 + 遮罩动画）
- `libqrencode` → `QRCodeGenerator.swift`（CoreImage 生成二维码）
- 模型：`TaskRefresh` / `History` / `Pointmap` / `TaskLocation`（Models.swift 追加）
- API：`GameAPI`（任务刷新/定位/历史/退赛）
- 待补：`QDXTicketSuccessViewController`（门票核销）、`QDXPointListViewController` / `QDXPointSettingViewController`（点标管理）、`QDXTeamsViewController` / `QDXTaskViewController`（组队/任务）、扫码扫描器（Vision 替代 ZBar）

**第四批 — 我的与设置** ✅ 已完成
- `MineViewController.m` → `MineController.swift`（渐变头部 + 圆角头像 + 手机号脱敏 + 头像上传 UIImagePickerController + 卡片表格）
- `editMineInfoViewController.m` → `EditMineInfoController.swift`（昵称/手机/签名编辑）
- `MineLineController.m` + `TeamLineController.m` → `MyLineListController.swift`（按 Mode 区分个人/团队）
- `MineCardViewController.m` → `MineCardController.swift`（卡包列表 + 二维码弹层）
- `SettingViewController.m` → `SettingController.swift`（缓存清理/修改密码/退出登录）
- `AboutUsViewController.m` → `AboutUsController.swift`（Logo+版本+简介+活动须知+点标管理，含通用 `WebViewController`）
- `QDXChangePwdViewController.m` → 已在第一批迁移为 `ChangePasswordViewController`
- API：`MineAPI`（authLogin/modify/myLines/teamLines/cards）+ `Myline`/`Card` 模型
- 待补：`QDXChangeNameViewController`（修改昵称独立页，已并入编辑资料）、`HelpViewController` / `NoticeViewController` / `QDXProtocolViewController`（协议页）、`QDXCreateCodeViewController`（生成二维码，已有 QRCodeGenerator 可复用）、`ImagePickerController`（扫码，待用 Vision 替代 ZBar）

**第五批 — 离线** ✅ 已完成
- `LocalDBService.m` → `OfflineDBService.swift`（Codable + JSON 文件，键名前缀沿用 `/MylineInfo` `/Myline` `/MylineHistory` `/MylineQuestion`；提供 loadDb/checkTask/passChange/checkHistory/writeHistory/readMylineInfo/readMyline/writeMyline/readQuestion/resetQuestion/uploadHistory）
- `QDXOfflineDB.m` → `OfflineDownloadStore.swift`（SQLite.swift 类型安全封装，6 表 CRUD + deleteDuplicates 去重，数据库 `~/Documents/QDXOffine.sqlite`）
- `LocalSqlliteService.m` → `OfflineDownloadAPI`（在 `OfflineDownloadStore.swift` 内，封装 setupMylineInfo/loadPoints/loadQuestions + 地图图片下载）
- `QDXOffLineController.m` → `OfflineGameViewController.swift`（下载按钮 + 开始按钮 + 地图 + 计时 + 目标点标 + CoreBluetooth 扫描 + UIAlertController 四选一 + 历史/详情/扫码/退赛菜单 + 5 状态机）
- 依赖：`Podfile` 新增 `SQLite.swift ~> 0.14`
- 待补：扫码扫描器（Vision 替代 ZBar）、`UploadHistory` 与在线 `BaseGameViewController` 的状态同步

**第六批 — 视图与工具** ✅ 已完成（核心）
- `Tool/ToolView` → `UIKitExtensions.swift` 中 `ToolView` 枚举（创建 ImageView/Label/Button、image(from:)、scale、applyAlpha、scoreTransfer、md5）
- `Tool/UIImage+watermark` → `UIImage.qdx_watermark(text:)`
- `Tool/UIImage+RTTint` → `UIImage.qdx_tinted(_:)`
- `Tool/UIButton+ImageText` → `UIButton.qdx_setImage(position:spacing:)` / `qdx_setImage(position:margin:)`
- `Tool/NSMutableAttributedString+ChangeColorFont` → `NSMutableAttributedString.qdx_append`
- `Tool/CheckDataTool` → 已在第一批迁移为 `Validator`
- `Tool/QDXOfflineDB` → 已在第五批迁移为 `OfflineDownloadStore`
- `View/QDXStateView` → `UIKitExtensions.swift` 中 `QDXStateView` 类（图标 + 描述 + 按钮）
- `View/QDXPopView` → 已在第三批迁移为 `PopContainerView`
- `Controller/ImagePickerController` → `QRScannerViewController.swift`（AVFoundation 现代化 + 扫描框动画）
- `Controller/QDXBindViewController` → `MiscControllers.swift` 中 `BindPhoneViewController`（SnapKit 卡片表单 + QQ/微信绑定 + qvLogin 自动登录）
- `Controller/QDXProtocolViewController` → `MiscControllers.swift` 中 `ProtocolViewController`（WKWebView 协议 + 同意进入 BaseGameViewController）
- `Controller/QDXTicketSuccessViewController` → `MiscControllers.swift` 中 `TicketSuccessViewController`（QDXStateView + getMyline 进入游戏）
- `Controller/HelpViewController` → `MiscControllers.swift` 中 `HelpViewController`（WKWebView + JS Success 回调）
- `Controller/NoticeViewController` → `MiscControllers.swift` 中 `NoticeViewController`（WKWebView + 拉取 HTML 渲染）
- 新增 `Notification.Name.stateRefresh` 扩展统一全局通知名
- 待补：`View/` 下其余 Cell（ActCell/HomeCell/LineCell/MineCell/QDXHistoryTableViewCell/QDXOrderTableViewCell/QDXTicketTableViewCell 等）已在各控制器内联实现，可按需独立抽出；清理 `Lib/` 下已替代的 OC 第三方库（AFNetworking、MJExtension、ZBar、libqrencode、SGNetObserver 等）

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
