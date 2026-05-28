# iOS UI 代码规范 (Dreame阅读项目)

> **版本**：1.3  
> **适用范围**：本项目所有使用 UIKit 进行界面开发的模块。  
> **核心原则**：一致性、可读性、可维护性、可复用性。  
> 任何设计稿到代码的转化都必须严格遵循本规范。

---

## 目录

- [1. 命名规范](#1-命名规范)
- [2. 文件组织与目录结构](#2-文件组织与目录结构)
- [3. 视图控制器代码结构](#3-视图控制器代码结构)
- [4. 视图代码结构](#4-视图代码结构)
- [5. 通用代码编写规则](#5-通用代码编写规则)
- [6. 布局管理](#6-布局管理)
- [7. 颜色管理](#7-颜色管理)
- [8. 字体管理](#8-字体管理)
- [9. 图片资源管理](#9-图片资源管理)
- [10. 组件复用与基类](#10-组件复用与基类)
- [11. 加载动画规范](#11-加载动画规范)
- [12. 错误页与空页面规范](#12-错误页与空页面规范)
- [13. 多语言与国际化](#13-多语言与国际化)
- [14. 动画与交互](#14-动画与交互)
- [15. 机型与系统版本适配](#15-机型与系统版本适配)
- [16. 性能与调试](#16-性能与调试)
- [17. 第三方库约定](#17-第三方库约定)

---

## 1. 命名规范

### 1.1 类名
- 大驼峰式（PascalCase），以功能或角色结尾。
- **视图控制器**：以 `ViewController` 结尾。  
  `HomeViewController`、`ProfileViewController`
- **自定义视图**：以 `View` 结尾。  
  `UserHeaderView`、`PriceTagView`
- **表格 / 集合 Cell**：以 `Cell` 结尾。  
  `NewsTableViewCell`、`ProductCollectionViewCell`

### 1.2 方法名与变量名
- 小驼峰式（camelCase），清晰表意，避免缩写。
- UI 变量名需体现控件类型：

| 控件类型    | 后缀      | 示例                  |
|-------------|-----------|-----------------------|
| UILabel     | `Label`   | `titleLabel`          |
| UIButton    | `Button`  | `submitButton`        |
| UIImageView | `ImageView`| `avatarImageView`    |
| UIStackView | `StackView`| `contentStackView`   |
| UITableView | `TableView`| `listTableView`      |
| UICollectionView | `CollectionView` | `photoCollectionView` |

- 禁止使用 `a`、`b`、`temp`、`view1` 等无意义命名。

### 1.3 资源名称
- 全小写 + 下划线分隔，带类型前缀：
  - 图标：`ic_nav_back`
  - 图片：`img_placeholder_user`
  - 颜色：`color_primary_blue`

---

## 2. 文件组织与目录结构

### 2.1 顶层结构

```
StaryReader/
├── Classes/                          # 主源码目录
│   ├── Main/                         # 应用入口、启动初始化
│   ├── Route/                        # 路由 & Mediator 模块间通信
│   ├── BaseModules/                  # 基础设施层（不涉及具体业务）
│   ├── CommonModules/                # 跨模块通用功能（登录、广告、充值等）
│   ├── BusinessModules/              # 业务模块（阅读器、书城、书架等）
│   ├── SwiftModules/                 # Swift 模块（协议化接口、MVVM+RxSwift）
│   └── Vendor/                       # 第三方源码（SVGAPlayer 等）
├── ReaderPackage/                    # 产品变体资源（Dreame / Ringdom / Starynovel）
├── HYReaderEngine/                   # 阅读引擎 Framework
├── Pods/                             # CocoaPods 依赖
└── doc/                              # 文档
```

### 2.2 四层架构

| 层级 | 目录 | 定位 | 示例 |
|------|------|------|------|
| **基础设施层** | `BaseModules/` | 平台能力，不涉及业务 | 网络、数据库、埋点、UIKit 扩展、广告 SDK、配置 |
| **通用模块层** | `CommonModules/` | 跨模块共享的业务功能 | Login、User、Recharge、Share、Push、Advert、Web |
| **业务模块层** | `BusinessModules/` | 具体产品功能（OC 为主） | Reader、BookCity、Bookshelf、Search、Community |
| **Swift 模块层** | `SwiftModules/` | 协议化 Swift 模块（MVVM+RxSwift） | 支付营收功能优先在此落地，通过 Proto 协议对外暴露 |

### 2.3 业务 / 通用模块内部结构

每个功能模块内部按职责分目录：

```
{ModuleName}/
├── Controller/          # 视图控制器
├── View/                # 自定义视图
├── Model/               # 数据模型
├── ViewModel/           # 视图模型（Swift 模块必须）
├── Manager/             # 业务管理器
├── Service/             # 网络服务
├── Network/             # 网络请求定义
└── Target/              # 路由 Target
```

### 2.4 Swift 模块结构

```
Classes/SwiftModules/
├── Base/BaseKit/Sources/BaseUIKit/    # 基础 UIKit 组件（HYViewController、扩展）
├── Base/Interface/Sources/Proto/      # 模块间协议接口（~40 个 ModuleProtocol）
├── Base/Resource/Sources/             # 主题资源（ResourceDR / ResourceSN）
└── {FeatureModule}/Sources/           # 各功能模块
```

新模块必须通过 `Base/Interface/Sources/Proto/` 下的协议暴露接口，禁止直接引用实现类。

### 2.5 公共基类位置

| 基类 | 路径 | 语言 |
|------|------|------|
| `HYBaseViewController` | `Classes/BaseModules/Kits/BaseClasses/` | OC |
| `HYBaseModel` | `Classes/BaseModules/Kits/BaseClasses/` | OC |
| `HYBaseTableViewCell` | `Classes/BaseModules/Kits/BaseClasses/` | OC |
| `HYBaseCollectionViewCell` | `Classes/BaseModules/Kits/BaseClasses/` | OC |
| `HYViewController` | `Classes/SwiftModules/Base/BaseKit/Sources/BaseUIKit/Controller/` | Swift |
| `HYNavigationController` | 同上 | Swift |

### 2.6 公共扩展位置

| 类别 | 路径 |
|------|------|
| **UIKit 扩展** | `Classes/BaseModules/Kits/Categories/UIKit/` |
| ─ 颜色 | `UIColor+String.h/.m`、`UIColor+HYColorSet.h/.m`、`UIColor+ColorSet.swift` |
| ─ 字体 | `UIFont+Dreame.h/.m` |
| ─ 视图 | `UIView+Frame`、`UIView+Animations`、`UIView+CircleCorner`、`UIView+HYRTL` 等 |
| ─ 图片 | `UIImage+Color`、`UIImage+Resize`、`UIImage+MainColor.swift` |
| **Foundation 扩展** | `Classes/BaseModules/Kits/Categories/Foundation/` |
| **Swift UIKit 扩展** | `Classes/SwiftModules/Base/BaseKit/Sources/BaseUIKit/UIKitExtension/` |
| **主题颜色** | `Classes/BaseModules/Utils/Theme/HYColor.h/.m` |

### 2.7 资源文件位置

| 资源 | 路径 |
|------|------|
| **Dreame 主资源** | `ReaderPackage/Dreame/Resources/Assets.xcassets/` |
| **Ringdom 主资源** | `ReaderPackage/Ringdom/Resources/Assets.xcassets/` |
| **Starynovel 主资源** | `ReaderPackage/Starynovel/Resources/Assets.xcassets/` |
| **Swift 模块资源** | `Classes/SwiftModules/Base/Resource/Sources/ResourceDR/`（Dreame 主题） |
| **字体文件** | `Classes/BaseModules/CommonResources/Font/` |

### 2.8 文件对应
- 一个文件只定义**一个主要类**（私有扩展可放同文件）。
- 每个自定义 `UIView` 子类独立文件，复杂页面可将主视图拆为独立 `UIView` 文件。
- 类名前缀约定：本项目的公共类**必须**使用 **`HY`** 前缀（如 `HYBaseViewController`）。

---

## 3. 视图控制器代码结构

- 使用 `// MARK: -` 进行分区，顺序固定
- 复杂页面**必须**使用自定义视图承载页面内容，并在自定义视图中根据子页面的复杂度决定是否进一步拆分出自定义子视图
- 页面**仅展示单个**列表或者集合内容样式的，可以直接在视图控制器中声明列表或集合视图
- 导航栏、状态栏和标签栏的 UI 初始化和更新，放在视图控制器中，使用 `// MARK: -` 进行单独分区，位于 `ViewInit` 分区后面
- 布局代码放在 `// MARK: - ViewInit` 区域内的 `makeConstraints` 方法中
- 视图控制器遵循的协议方法必须放在视图控制器的 extension 中，并使用 `// MARK: - 协议名` 分区
- 使用 ViewModel 来拆分视图控制器的逻辑代码，网络请求发起、请求回调原始数据处理加工、UI 状态加工代码放在 ViewModel 进行
- 控制器只负责协调逻辑，不负责具体视图构建。

> 视图控制器也遵循第 5 节《通用代码编写规则》中的全部约定（UI 元素声明、deinit 资源清理、didSet 绑定、闭包回调、Data 分区、可选值安全处理等），本节仅列出 VC 特有的规则。

示例结构：

```swift
class ExampleViewController: BaseViewController {

    // MARK: - Properties
    private let customView = ExampleView()
    private var data: [Item] = []
  	private let exampleViewModel = ExampleViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
        makeConstraints()
        loadData()
    }
  
  	override func viewWillAppear(_ animated: Bool) {
      	super.viewWillAppear(animated)
      	...
    }
  
  	override func viewWillDisappear(_ animated: Bool) {
      	super.viewWillDisappear(animated)
      	...
    }

    // MARK: - ViewInit
    private func viewInit() { ... }
    private func makeConstraints() { ... }

    // MARK: - Data
    private func loadData() { ... }

    // MARK: - Actions
    @objc private func didTapSubmit() { ... }
}

extension ExampleViewController: UITableViewDataSource, UITableViewDelegate {
  	// MARK: - UITableViewDataSource
  	...
  
  	// MARK: - UITableViewDelegate
  	...
}
```

---

## 4. 视图代码结构

本节仅列出 UIView / Cell 特有的规则。与 VC 共享的通用规则（UI 元素声明、deinit、didSet、闭包回调、Data 分区、Theme 分区、可选值处理）见第 5 节《通用代码编写规则》。

- 所有自定义视图使用 `// MARK: -` 进行分区，遵循统一模板
- 统一在 `viewInit` 进行 addSubview 以及各种样式配置，包括字体、颜色、对齐方式、换行、圆角、阴影等
- 统一在 `makeConstraints` 中使用 **SnapKit** 进行布局初始化，遵循 UI 控件自撑开大小的布局原则，有布局冲突时设置好视图的抗拉伸和抗压缩优先级
- CAGradientLayer 在 layoutSubviews() 方法中确定了父 layer 的大小后再更新 frame
- **尽可能**使用 `UIStackView` 来处理视图的自撑开大小，并实现视图的整体居中对齐
- 公开配置方法使用 `configure(with:)` 或类似名称，不暴露内部控件。

示例结构：

```swift
class UserHeaderView: UIView {

    // MARK: - UI Elements
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let badgeView = BadgeView()
  	private let tapHeaderButton = UIButton(type: .custom)
  	private lazy var cardListCollectionView: UICollectionView = {
    			let flowLayout = UICollectionViewFlowLayout()
      		flowLayout.itemSize = CGSize(width: 300.0, height: 80.0)
      		...
      
      		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
      		collectionView.dataSource = self
      		...
      
      		return collectionView
    }()
  
  	// MARK: - Public Properties
  	public var headerTapAction: (() -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupData()       // 可选：viewInit() 依赖预计算数据时调用（见 5.6 节）
        viewInit()
      	makeConstraints()
        updateTheme()     // 可选：阅读器日夜间模式支持时调用（见 5.7 节）
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Data（可选，见 5.6 节）
   	private func setupData() { ... }

    // MARK: - UI Setup
   	private func viewInit() {
      	avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 24
        avatarImageView.clipsToBounds = true
        addSubview(avatarImageView)
      
      	nameLabel.font = .appHeadline
        nameLabel.textColor = .appTextPrimary
        addSubview(nameLabel)
      
        addSubview(badgeView)
      	
      	tapHeaderButton.addTarget(self, action: #selector(onHeaderButtonTap))
      	addSubview(tapHeaderButton)
    }
  
  	private func makeConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.leading.top.equalToSuperview().inset(16)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.centerY.equalTo(avatarImageView)
        }
        badgeView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(avatarImageView)
        }
    }

    // MARK: - Theme（可选，见 5.7 节）
    @objc func updateTheme() { ... }
  
  	// MARK: - Actions
  	@objc private func onHeaderButtonTap() {
    	  if let headerTapAction = headerTapAction {
        		headerTapAction()
        }
    }

    // MARK: - Public Configuration
    public func configure(with user: User) {
        avatarImageView.image = UIImage(named: user.avatarName)
        nameLabel.text = user.displayName
    }
}
```

### 4.1 Cell 视图补充规则

**UITableViewCell / UICollectionViewCell** 中的子视图**必须**添加到 `contentView` 而非 `self`：

```swift
// ✅ 正确：子视图加到 contentView
contentView.addSubview(titleLabel)
contentView.addSubview(iconImageView)

// ❌ 禁止：直接加到 self 会导致滑动/编辑时布局异常
self.addSubview(titleLabel)
```

Cell 的背景色应设为 `.clear`（`backgroundColor = .clear`），由 `contentView` 或 Cell 选中样式控制外观。

---

## 5. 通用代码编写规则

以下规则同时适用于**视图控制器（ViewController）**和**自定义视图（UIView / Cell）**，是两者通用的代码编写模式。各节特有的补充规则在第 3 节（VC）和第 4 节（View）中单独说明。

### 5.1 UI 元素声明

- UI 元素统一在对应 `// MARK: -` 分区顶部声明
- 普通 UIView / UILabel / UIButton 等**推荐**使用 `private let` 声明并初始化：

```swift
private let titleLabel = UILabel()
private let submitButton = UIButton(type: .custom)
private let avatarImageView = UIImageView()
```

- UICollectionView 需要自定义 FlowLayout 时，**允许**使用 `private lazy var`，在闭包内完成 FlowLayout 配置和 CollectionView 初始化
- **非 UICollectionView 不得使用 `lazy var`** 声明 UI 元素

```swift
// ✅ 正确：CollectionView 使用 lazy var
private lazy var cardListCollectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.itemSize = CGSize(width: 300.0, height: 80.0)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.dataSource = self
    return collectionView
}()

// ✅ 正确：普通视图使用 let
private let nameLabel = UILabel()

// ❌ 禁止：普通 UILabel 使用 lazy var
private lazy var nameLabel: UILabel = {
    let label = UILabel()
    return label
}()
```

### 5.2 init / viewDidLoad 调用顺序

视图控制器的 `viewDidLoad` 和自定义视图的 `init` 方法均应遵循固定的方法调用顺序，按需裁剪，不调用的方法直接删除，不留空方法体：

| 场景 | ViewController（viewDidLoad） | UIView（init） |
|------|------------------------------|----------------|
| **默认** | `viewInit()` → `makeConstraints()` | `viewInit()` → `makeConstraints()` |
| **有 Data 依赖** | `setupData()` → `viewInit()` → `makeConstraints()` | `setupData()` → `viewInit()` → `makeConstraints()` |
| **有 Theme 支持** | 末尾追加 `updateTheme()` | 末尾追加 `updateTheme()` |
| **最完整** | `setupData()` → `viewInit()` → `makeConstraints()` → `updateTheme()` | `setupData()` → `viewInit()` → `makeConstraints()` → `updateTheme()` |

```swift
// UIView 示例 — 完整顺序
override init(frame: CGRect) {
    super.init(frame: frame)
    setupData()       // 可选：viewInit() 依赖预计算数据时调用
    viewInit()
    makeConstraints()
    updateTheme()     // 可选：阅读器日夜间模式支持时调用
}
```

### 5.3 deinit 资源清理

注册了 Observer / Timer / Notification 的视图或视图控制器，**必须**在 `deinit` 中取消注册，防止对象释放后回调导致野指针崩溃：

```swift
deinit {
    if let bookId = chapterInfo?.bookId {
        HYBookTimeLimitFreeManager.shareInstance().unregisterObserverTimeLimitFree(self, bookId: bookId)
    }
}
```

常见需要清理的资源：`NotificationCenter` observer、`Timer`、`KVO`、第三方 SDK 的回调注册（如限免倒计时观察者）。

### 5.4 属性 `didSet` 驱动 UI 绑定

Cell 和简单 View 接收数据时，优先使用属性观察器 `didSet` 触发 UI 更新，外部只需给属性赋值即可：

```swift
public var chapterInfo: HYChapterModel? {
    didSet {
        guard let chapterInfo = chapterInfo else { return }
        chapterNameLabel.text = chapterInfo.chapterTitle
        iconImageView.isHidden = chapterInfo.isFree
        updateThemeForReadStatus(chapterInfo.isRead)
        updateSubviewConstraints()
    }
}
```

复杂页面（多个输入源或异步数据流）仍建议使用 `configure(with:)` 公开方法。

### 5.5 闭包回调替代 Delegate

简单 View 对外暴露事件时，使用闭包属性而非定义 delegate 协议，减少样板代码：

```swift
// 声明闭包属性
public var headerViewTapAction: (() -> Void)?
public var sortAction: ((Bool) -> Void)?

// 触发回调
@objc private func onViewTap() {
    headerViewTapAction?()
}

@objc private func onSortButtonTap() {
    sortButton.isSelected.toggle()
    sortAction?(sortButton.isSelected)
}
```

外部调用时直接赋值闭包：

```swift
headerView.sortAction = { isSelected in
    // 处理排序切换
}
```

**适用场景**：事件类型 ≤ 3 个的简单 View。若回调超过 3 个或需要传递复杂上下文，仍使用 delegate 协议。

### 5.6 Data 分区（可选）

当 `viewInit()` 中的 UI 初始化依赖内部计算/推导的数据结果时，在 `Initialization` 和 `viewInit()` 之间增加 `Data` 分区，将数据准备逻辑收敛到 `setupData()` 方法。

**适用条件**（需全部满足）：
- 视图/控制器在 init / viewDidLoad 时需要根据外部配置值计算/推导内部数据（如根据 `fontSize` 查找在 `sizes` 数组中的索引）
- `viewInit()` 中的 label 文本、控件状态等直接依赖该计算结果
- 数据计算不依赖视图层级（不要求 `addSubview` 先执行）

**不适用场景**：数据由外部通过 `configure(with:)` 或属性 `didSet` 注入。

```swift
// MARK: - Data
private func setupData() {
    // 例：根据当前 fontSize 计算其在预设数组中的索引
    let sizes = [16, 18, 19, 20, 21, 22, 24, 26, 29, 32, 36, 40]
    let currentValue = Int(HYReaderConfig.sharedInstance().fontSize)
    for i in 0..<sizes.count {
        if sizes[i] == currentValue {
            currentIndex = i
            break
        }
    }
}
```

### 5.7 Theme 分区（可选）

阅读器模块内的视图如需响应 `HYReaderConfig.sharedInstance().theme` 的独立日夜间切换（非系统 Dark Mode），增加 `Theme` 分区承载 `updateTheme()` 方法。

**适用条件**（需全部满足）：
- 视图属于阅读器模块（`BusinessModules/Reader/`）或被阅读器视图引用
- 颜色/图片需要根据 `HYReaderConfig.sharedInstance().theme` 在日间/夜间之间切换
- 无法通过系统 `UIUserInterfaceStyle` + ColorSet 自动适配

**不适用场景**：
- 仅跟随系统 Dark Mode 的视图（ColorSet 自动适配即可）
- 非阅读器业务模块的视图

**方法约定**：
- 方法签名固定为 `@objc func updateTheme()`，供 OC 父视图在主题变更时统一触发
- 内部通过 `HYReaderConfig.sharedInstance().theme == .black` 判断夜间模式
- 所有子视图的颜色、图片切换逻辑均收敛在此方法内，不改动 Auto Layout 约束

```swift
// MARK: - Theme
@objc func updateTheme() {
    let isNightMode = HYReaderConfig.sharedInstance().theme == .black
    valueLabel.textColor = HYReaderConfig.sharedInstance().themeModel.readerGroupViewTextColor
    if isNightMode {
        reduceBtn.setImage(HYReaderConfig.sharedInstance().themeModel.hy_readerReduceSizeFontImage(), for: .normal)
        plusBtn.setImage(HYReaderConfig.sharedInstance().themeModel.hy_readerPlusSizeFontImage(), for: .normal)
    } else {
        reduceBtn.setImage(HYReaderConfig.sharedInstance().themeModel.hy_readerReduceSizeFontImage(), for: .normal)
        plusBtn.setImage(HYReaderConfig.sharedInstance().themeModel.hy_readerPlusSizeFontImage(), for: .normal)
    }
}
```

### 5.8 可选值安全处理

**禁止使用 `!` 强制解包可选值**。所有可选值必须通过 `??` 提供合理的默认值。

| 场景 | 错误写法 | 正确写法 | 默认值 |
|------|---------|---------|--------|
| 颜色初始化 | `UIColor(hex: 0x000, alpha: 0.1)!` | `UIColor(hex: 0x000, alpha: 0.1) ?? .clear` | `.clear` |
| 颜色取 `.cgColor` | `UIColor(hex: 0x000, alpha: 0.1)!.cgColor` | `(UIColor(hex: 0x000, alpha: 0.1) ?? .clear).cgColor` | `.clear` |
| 图片加载 | `UIImage(named: "icon")!` | `UIImage(named: "icon") ?? UIImage()` | `UIImage()` |
| 数组取首尾 | `array.first!` / `array.last!` | `array.first ?? defaultValue` | 按业务定义 |
| 字典取值 | `dict[key]!` | `dict[key] ?? defaultValue` | 按业务定义 |

**不适用场景**：
- `@IBOutlet` 属性（Xcode 自动生成，隐式解包为历史遗留，不强制修改）

---

## 6. 布局管理

### 6.1 布局方式

- UIView 及其子类 **统一使用 SnapKit** 进行自动布局，禁止混用原生 `NSLayoutConstraint` 或 Storyboard / XIB。
- **一个视图布局只能二选一**：要么用 SnapKit 约束定位，要么手动设置 frame，严禁对同一个视图既设约束又设 frame。
- 以下场景使用 frame 布局（**不使用** SnapKit）：
  - **UITableView / UICollectionView 的直接子视图**（非 cell/header/footer 的装饰性浮动视图，如关闭按钮）：必须用 frame 在 `layoutSubviews` 中定位，避免 Auto Layout 与列表内部布局系统冲突。

### 6.2 约束书写示例
```swift
// ✅ 正确
titleLabel.snp.makeConstraints { make in
    make.top.leading.equalToSuperview().inset(16)
    make.trailing.equalTo(iconView.snp.leading).offset(-12)
}

// ❌ 禁止硬编码坐标和原生混合
titleLabel.frame = CGRect(x: 16, y: 20, width: 100, height: 30)
```

### 6.3 动态约束更新

当 UI 状态变化导致子视图显隐或布局关系改变时，使用 `snp.remakeConstraints` **重建约束**，而非仅更新 `constant` 值：

```swift
private func updateSubviewConstraints(onlyShowChapterName: Bool) {
    chapterNameLabel.snp.remakeConstraints { make in
        make.top.left.equalToSuperview().offset(16)
        if onlyShowChapterName {
            make.right.equalToSuperview().offset(-16)
        } else {
            make.right.equalTo(iconImageView.snp.left).offset(-16)
        }
        make.height.equalTo(18)
    }
}
```

`remakeConstraints` 会先移除旧约束再创建新约束，适用于结构变化场景；若仅偏移量变化，使用 `updateConstraints` 修改 `constant` 即可。

### 6.4 抗拉伸与抗压缩优先级

`UIStackView` 内部元素通过设置 Content Hugging Priority 和 Content Compression Resistance Priority 控制布局行为：

- **`setContentHuggingPriority(.required, for: .horizontal)`** — 不希望被拉伸，保持内容自身尺寸
- **`setContentCompressionResistancePriority(.required, for: .horizontal)`** — 不希望被压缩，保证内容完整显示

```swift
rightStackView.setContentHuggingPriority(.required, for: .horizontal)
rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
```

典型场景：列表右侧的状态标签组需要完整显示，不被左侧长文本挤掉，此时应对右侧 StackView 设置 `.required` 优先级。

### 6.5 屏幕尺寸与安全区域常量

布局中涉及屏幕宽高、安全区域、导航栏/TabBar 高度等尺寸时，**禁止**自行 `UIScreen.main.bounds` 或手动计算。项目有两套并行的常量定义，分别服务于 OC 和 Swift：

#### 6.5.1 OC文件— HYScreen.h

**文件**：`Classes/BaseModules/Kits/Macro/HYScreen.h`

| 常量 | 类型 | 说明 |
|------|------|------|
| `SCREEN_WIDTH` | 宏 | 屏幕宽度（逻辑 pt） |
| `SCREEN_HEIGHT` | 宏 | 屏幕高度（逻辑 pt） |
| `TopMargin` | 宏 | 顶部安全区域高度 |
| `BottomMargin` | 宏 | 底部安全区域高度 |
| `STATUS_BAR_HEIGHT` | 宏 | 状态栏高度 |
| `NAVIGATION_BAR_HEIGHT` | 宏 | 导航栏 + 状态栏总高度 |
| `TAB_BAR_HEIGHT` | 宏 | TabBar 高度（49 + 底部安全区域） |
| `IS_IPAD` | 宏 | 判断 iPad 设备 |
| `IS_IPHONE_BANG_SCREEN` | 宏 | 判断刘海屏机型 |
| `UI(x)` / `UISize(w,h)` 等 | 内联函数 | UI 适配缩放（以 iPhone6 375pt 为基准） |

```objc
// ✅ 正确
CGFloat statusBarH = STATUS_BAR_HEIGHT;
CGFloat navBarH = NAVIGATION_BAR_HEIGHT;
CGFloat tabBarH = TAB_BAR_HEIGHT;
CGFloat top = TopMargin;
CGFloat bottom = BottomMargin;
CGFloat adapted = UI(16);  // 按屏幕宽度等比缩放

// ❌ 禁止：硬编码或自行计算
CGFloat navBarH = 44 + 20;   // 未考虑刘海屏
CGFloat bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
```

#### 6.5.2 Swift文件 — SwiftMacro.swift

**文件**：`Classes/BaseModules/SwiftUtils/SwiftMacro.swift`

OC 宏**不会**桥接到 Swift，Swift 侧使用 `SwiftMacro.swift` 定义的全局常量和 `UIDevice` 扩展方法。同名常量大小写风格不同，注意区分：

| 常量 | 类型 | 说明 | 对应 OC 等价物 |
|------|------|------|---------------|
| `SCREEN_WIDTH` | `let` | 屏幕宽度 | 同名宏 |
| `SCREEN_HEIGHT` | `let` | 屏幕高度 | 同名宏 |
| `TopMargin` | `let` | 顶部安全区域 | 同名宏 |
| `BottomMargin` | `let` | 底部安全区域 | 同名宏 |
| `StatusBarHeight` | `var` | 状态栏高度（可变，适应显隐切换） | `STATUS_BAR_HEIGHT` |
| `NavigationBarHeight` | `let` | 导航栏 + 状态栏总高度 | `NAVIGATION_BAR_HEIGHT` |
| `TabBarHeight` | `let` | TabBar 高度 | `TAB_BAR_HEIGHT` |
| `isIPad` | `let` | 判断 iPad | `IS_IPAD` |
| `IS_BAND_SCREEN` | `let` | 判断刘海屏 | `IS_IPHONE_BANG_SCREEN` |
| `isRTL` | `var` | RTL 布局判断（阿拉伯语） | OC 宏 `isRTL()` |
| `SCREEN_WIDTH_DIFF_RATIO` | `let` | 屏幕宽度缩放比（iPad: /768, iPhone: /375） | — |
| `SCREEN_WIDTH_RATIO` | `let` | 屏幕宽度相对于 iPhone 的比例 | — |
| `SCREEN_HEIGHT_DIFF_RATIO` | `let` | 屏幕高度缩放比（/667） | — |
| `BOOK_COVER_WIDTH_HEIGHT_RATIO` | `let` | 书籍封面宽高比（7:10） | — |
| `SectionLeftRightMargin` | `let` | 标准左右边距（12pt） | — |
| `CornerRadiusRate5` | `let` | 圆角比例常量（0.05） | — |

**UIDevice 扩展方法**（SwiftMacro.swift 内定义）：

```swift
UIDevice.hy_safeDistanceTop()       // 顶部安全区域
UIDevice.hy_safeDistanceBottom()    // 底部安全区域
UIDevice.hy_statusBarHeight()       // 状态栏高度
UIDevice.hy_navigationBarHeight()   // 导航栏+状态栏高度
UIDevice.hy_tabBarHeight()          // TabBar高度
UIDevice.hy_getKeyWindow()          // 获取 KeyWindow
```

```swift
// ✅ 正确：使用 SwiftMacro 全局常量
let width = SCREEN_WIDTH
headerView.snp.makeConstraints { make in
    make.bottom.equalToSuperview().offset(-BottomMargin)
}
batchUnlockLabel.snp.makeConstraints { make in
    make.bottom.equalToSuperview().offset(-BottomMargin - batchUnlockHeight)
}

// ✅ 正确：需要方法调用时使用 UIDevice 扩展
let safeTop = UIDevice.hy_safeDistanceTop()

// ❌ 禁止：自行获取或计算
let width = UIScreen.main.bounds.width
let safeBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
```

---

## 7. 颜色管理

**禁止**在业务代码中使用 `UIColor(red:green:blue:alpha:)` 直接构造颜色。

### 7.1 非 SwiftModule 模块（OC / 老模块）

使用 `UIColor+HYColorSet` 分类提供的设计系统色值方法（定义于 `Classes/BaseModules/Utils/Theme/UIColor+HYColorSet.h`）。

根据 Figma 设计稿中的色值语义，选择对应的 ColorSet 方法。调用方式使用 OC 点语法：

```objc
// 文字色
UIColor.color_txt_ic_primary       // 主要文字 #000000 90%
UIColor.color_txt_ic_secondary     // 次要文字 #000000 70%
UIColor.color_txt_ic_placeholder   // 占位文字 #000000 50%
UIColor.color_txt_ic_dis           // 禁用文字 #000000 30%
UIColor.color_txt_ic_anti1         // 反色文字1 #FFFFFF
UIColor.color_txt_ic_anti2         // 反色文字2 #FFFFFF 80%
UIColor.color_txt_ic_anti3         // 反色文字3 #FFFFFF 50%
UIColor.color_txt_ic_link          // 链接色
UIColor.color_txt_ic_error         // 错误文字

// 背景色
UIColor.color_bg_page              // 页面背景 #F5F5F5
UIColor.color_bg_container         // 容器背景 #FFFFFF
UIColor.color_bg_secondarycontainer // 次级容器背景 #FAFAFA
UIColor.color_bg_component         // 组件背景 #E7E7E7
UIColor.color_bg_Reader            // 阅读器背景 #FBFBFB

// 品牌色
UIColor.color_brand_normal         // 品牌常态
UIColor.color_brand_hover          // 品牌悬停
UIColor.color_brand_active         // 品牌激活
UIColor.color_brand_heavy          // 品牌深色
UIColor.color_brand_focus          // 品牌聚焦
UIColor.color_brand_dis            // 品牌禁用

// 功能色
UIColor.color_error_normal         // 错误常态
UIColor.color_Warning_normal       // 警告常态
UIColor.color_Success_normal       // 成功常态
UIColor.color_Actv_normal          // 活动/促销常态

// 填充色
UIColor.color_fill_0               // 填充0
UIColor.color_fill_1               // 填充1
UIColor.color_fill_2               // 填充2
UIColor.color_fill_mask            // 遮罩 #000000 60%
UIColor.color_fill_toast           // Toast 背景

// 边框色
UIColor.color_border_default       // 默认边框
UIColor.color_border_dis           // 禁用边框
UIColor.color_border_stroke        // 描边

// 渐变色
UIColor.color_gradient_normal_start  // 渐变常态起点
UIColor.color_gradient_normal_mid    // 渐变常态中点
UIColor.color_gradient_normal_end    // 渐变常态终点
// ...更多渐变状态见源文件
```

**暗黑模式**：所有 `d_` 前缀的对应方法（如 `UIColor.d_color_txt_ic_primary`）提供暗黑模式色值，系统自动根据当前外观切换，直接调用即可，无需手动判断。

#### ColorSet 中找不到的色值

当 Figma 色值在 `UIColor+HYColorSet` 中没有对应方法时，使用 `HexColor` 宏或 `UIColor(hex:)` 直接构造：

```objc
// HexColor 宏
view.backgroundColor = HexColor(0xE5406A);

// 带透明度
view.backgroundColor = HexColorA(0xFFFFFF, 0.4);

// UIColor(hex:) Swift 风格构造器（OC 中也可使用）
label.textColor = [UIColor colorWithHex:0xB857FF];
```

使用示例：
```objc
// Figma: 页面背景
self.view.backgroundColor = UIColor.color_bg_page;

// Figma: 主要文本
titleLabel.textColor = UIColor.color_txt_ic_primary;

// Figma: 次要文本（暗黑模式）
descLabel.textColor = UIColor.d_color_txt_ic_secondary;

// Figma: 色值不在 ColorSet 中
button.backgroundColor = HexColor(0xE5406A);
```

### 7.2 SwiftModule 模块

使用 `UIColor(resource: C.xxx)` 通过 SwiftGen 生成的资源引用获取颜色（定义于 `Classes/SwiftModules/Base/Resource/Sources/`）。

`C` 是 SwiftGen 为 Assets.xcassets 中 Color Set 自动生成的类型安全引用。根据 Figma 设计稿中的色值，查找对应的 Color Set 名称：

| Figma 场景 | 示例调用 |
|------------|----------|
| **主文本色** | `UIColor(resource: C.color_txt_ic_primary)` |
| **次要文本色** | `UIColor(resource: C._00000080)` |
| **品牌色** | `UIColor(resource: C.color_brand_active)` |
| **页面背景** | `UIColor(resource: C._FCF9FE)` |
| **浅灰背景** | `UIColor(resource: C._F4F4F4)` |
| **反色/白色** | `UIColor(resource: C.color_txt_w_ic_anti)` |

使用示例：
```swift
// Figma: 主要文本色
titleLabel.textColor = UIColor(resource: C.color_txt_ic_primary)

// Figma: 页面背景
view.backgroundColor = UIColor(resource: C._FCF9FE)

// Figma: 透明 / 无背景
view.backgroundColor = .clear
```

**注意**：并非所有 Figma 颜色在 Assets.xcassets 中都有对应 Color Set。优先查找语义匹配的 Color Set（如 `color_txt_ic_primary`、`color_brand_active`）；确无匹配时，与设计师确认是否需要在 Assets.xcassets 中新增 Color Set。

### 7.3 暗黑模式
- `UIColor+HYColorSet` 中 `d_` 前缀的方法（如 `d_color_txt_ic_primary`）提供暗黑模式色值，系统自动切换。
- SwiftModule 的 Color Set 必须同时提供 `Any Appearance` 和 `Dark` 两种外观值，确保自动适配。

### 7.4 日夜间模式

阅读器相关视图（目录、菜单、设置等）除系统暗黑模式外，还需支持**独立的日夜间切换**（`HYReaderConfig.sharedInstance().theme`），与系统外观解耦。

**判断逻辑**：

```swift
let isNightMode = HYReaderConfig.sharedInstance().theme == .black
```

**颜色切换模式**：在统一的 `updateTheme` 方法中，根据 `isNightMode` 条件设置所有子视图的颜色和图片，而非散落在各处：

```swift
private func updateThemeForReadStatus(_ isRead: Bool) {
    let isNightMode = HYReaderConfig.sharedInstance().theme == .black

    // 文字颜色
    if isNightMode {
        chapterNameLabel.textColor = UIColor(hex: 0xFFFFFF, alpha: isRead ? 0.2 : 0.8)
        publishTimeLabel.textColor = UIColor(hex: 0xFFFFFF, alpha: 0.4)
    } else {
        chapterNameLabel.textColor = UIColor(hex: 0x000000, alpha: isRead ? 0.2 : 0.9)
        publishTimeLabel.textColor = UIColor(hex: 0x000000, alpha: 0.4)
    }

    // 图标切换：夜间使用 _night 后缀的图片资源
    if isNightMode {
        iconImageView.image = UIImage(named: "reading_list_lock_night")
    } else {
        iconImageView.image = UIImage(named: "reading_list_lock")
    }

    // 分割线
    line.backgroundColor = UIColor(hex: isNightMode ? 0xFFFFFF : 0x000000, alpha: 0.05)
}
```

**关键规则**：

- 日夜间模式通过 `enableDayNightMode` 属性控制是否生效，默认为 `false`，仅在阅读器相关页面启用
- 夜间图片资源使用 `_night` 后缀命名（如 `reading_list_lock_night`），放在同一个 Assets.xcassets 模块目录下

---

## 8. 字体管理

**禁止**直接使用 `UIFont.systemFont(ofSize:)` 或 `UIFont.boldSystemFont(ofSize:)`。

### 8.1 非 SwiftModule 模块（OC / 老模块）

使用 `UIFont+Dreame` 分类提供的方法（定义于 `Classes/BaseModules/Kits/Categories/UIKit/UIFont+Dreame.h`）。

根据 Figma 设计稿中的 **fontSize** 和**样式**（Regular、Medium、Semibold、Bold 等），调用对应方法：

| Figma 样式 | 调用方法 | 示例 |
|------------|----------|------|
| **Regular** (400) | `appleSFUIFontRegularWithSize:` | `[UIFont appleSFUIFontRegularWithSize:14]` |
| **Medium** (500) | `appleSFUIFontMediumWithSize:` | `[UIFont appleSFUIFontMediumWithSize:16]` |
| **SemiBold** (600) | `appleSFUIFontSemiBoldWithSize:` | `[UIFont appleSFUIFontSemiBoldWithSize:18]` |
| **Bold** (700) | `appleSFUIFontBoldWithSize:` | `[UIFont appleSFUIFontBoldWithSize:22]` |
| **Black** (900) | `appleSFUIFontBlackWithSize:` | `[UIFont appleSFUIFontBlackWithSize:28]` |

使用示例：
```objc
// Figma: fontSize=16, style=Medium
titleLabel.font = [UIFont appleSFUIFontMediumWithSize:16];

// Figma: fontSize=22, style=Bold
nameLabel.font = [UIFont appleSFUIFontBoldWithSize:22];
```

### 8.2 SwiftModule 模块

使用 `UIFont.hyfont.*` 命名空间提供的方法（定义于 `Classes/SwiftModules/Base/BaseKit/Sources/BaseKit/Utils/Font.swift`）。

根据 Figma 设计稿中的 **fontSize** 和**粗细**，调用对应方法：

| Figma 样式 | 调用方法 |
|------------|----------|
| **Light** | `UIFont.hyfont.systemLightFont(size:)` |
| **Regular** | `UIFont.hyfont.systemRegularFont(size:)` |
| **Medium** | `UIFont.hyfont.systemMediumFont(size:)` |
| **Semibold** | `UIFont.hyfont.systemSemiboldFont(size:)` |
| **Bold** | `UIFont.hyfont.systemBoldFont(size:)` |
| **Heavy** | `UIFont.hyfont.systemHeavyFont(size:)` |

等宽数字字体（倒计时等场景，避免文字跳动）：

| Figma 样式 | 调用方法 |
|------------|----------|
| **Light** | `UIFont.hyfont.systemLightMonospacedDigitFont(size:)` |
| **Regular** | `UIFont.hyfont.systemRegularMonospacedDigitFont(size:)` |
| **Medium** | `UIFont.hyfont.systemMediumMonospacedDigitFont(size:)` |
| **Semibold** | `UIFont.hyfont.systemSemiboldMonospacedDigitFont(size:)` |
| **Bold** | `UIFont.hyfont.systemBoldMonospacedDigitFont(size:)` |

使用示例：
```swift
// Figma: fontSize=16, weight=Medium
titleLabel.font = UIFont.hyfont.systemMediumFont(size: 16)

// Figma: fontSize=22, weight=Bold
nameLabel.font = UIFont.hyfont.systemBoldFont(size: 22)
```

---

## 9. 图片资源管理

**禁止**在代码中硬编码图片路径或使用 `UIImage(contentsOfFile:)` 加载资源。

### 9.1 资源存放位置

项目中图片资源按模块类型分开存放，**所有 Assets.xcassets 内部均按功能模块使用文件夹分组**：

| 模块类型 | Assets.xcassets 位置 | 内部分组示例 |
|----------|---------------------|-------------|
| **非 SwiftModule** | `ReaderPackage/{产品名}/Resources/Assets.xcassets/` | BookCity / Reading / Me / Global / TabBar / Discover / Search / BookRanking / Login / Library / Detail / Comics / Video / store / community 等 40+ 模块子目录 |
| **SwiftModule (Dreame)** | `Classes/SwiftModules/Base/Resource/Sources/ResourceDR/Assets.xcassets` | Audio / Common / Community / Discover / Revenue / Search / TabBar / Video |
| **SwiftModule (Starynovel)** | `Classes/SwiftModules/Base/Resource/Sources/ResourceSN/Assets.xcassets` | Starynovel 主题资源 |

> 新增图片时，根据当前开发的模块类型和功能域，选择对应的 Assets.xcassets 并在对应的模块子目录下创建 Image Set。

### 9.2 命名规范

- 全小写 + 下划线分隔，带类型前缀：
  - 图标：`ic_nav_close`、`ic_direction_right`、`ic_hint`
  - 图片：`img_empty_state`、`img_placeholder_user`
  - 模块特有：`bookCityPersonalTagsClose`、`reading_menu_list`、`actionbar_discover_normal`
- Xcode Assets.xcassets 中所有 Image Set 形成**扁平命名空间**：虽然图片按模块子目录组织，但 OC 代码引用时只写 Image Set 名称本身，不包含目录路径
- SwiftModule Resources 中的图片在 `ResourceDR.swift` 枚举定义中需要写出相对路径，格式为 `子目录/图片名`，如 `"Common/default_head_small"`、`"Revenue/vip_icon_big"`

### 9.3 从 Figma 获取图片

当设计稿中包含图标或图片资源时，按以下流程处理：

1. **调用 Figma MCP 工具**：使用 `mcp__figma_get_images` 下载图片，指定 `scale: 2` 获取 2x 分辨率
2. **创建 Image Set**：在对应模块的 Assets.xcassets 中新建 Image Set，将下载的 2x 图片拖入 `2x` 槽位
3. **Figma 矢量图标**：对于 SVG 矢量图标，以 2x 导出为 PDF 格式放入 Image Set，勾选 `Preserve Vector Data` 以实现任意缩放不失真
4. **多语言图片**：若图片包含文字且需适配多语言，需下载对应语言版本，使用 `[UIImage multilingualImageNamed:]` 加载（仅非 SwiftModule）

### 9.4 非 SwiftModule（OC 代码）引用方式

使用原生 API `[UIImage imageNamed:]` 直接加载：

```objc
// 本地图标
_arrowImageView.image = [UIImage imageNamed:@"ic_direction_right"];

// 作为网络图片的占位图
[self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
                        placeholderImage:[UIImage imageNamed:@"me_head"]];

// 多语言图片（自动按当前语言查找对应后缀版本）
_writerImageView.image = [UIImage multilingualImageNamed:@"author_icon"];
```

**注意**：OC 代码引用图片时，图片名是**硬编码字符串**，编译器不会校验图片是否存在。命名时必须与 Assets.xcassets 中的 Image Set 名称**严格一致**。

### 9.5 SwiftModule（Swift 代码）引用方式

使用类型安全的资源引用，通过 `HYImageResource` 结构体 + 枚举定义，**编译期保证图片存在**。

**Dreame 主题**（`ResourceDR`）使用 `I` 枚举：

```swift
// I 是按功能域组织的嵌套枚举，定义于 ResourceDR.swift
closeButton.setImage(UIImage(resource: I.common.bookCityPersonalTagsClose), for: .normal)
bgImageView.image = UIImage(resource: I.revenue.vip_light)

// 作为占位图
cell.imageView?.hyimageview.loadImage(url: banner.picUrl,
    placeholderImage: UIImage(resource: I.common.normal_banner))
```

**Starynovel 主题**（`ResourceSN`）使用 `_I` 委托 R.swift：

```swift
imageView.image = UIImage(resource: _I.common.xxx)
```

#### 新增 SwiftModule 图片资源

在 Assets.xcassets 中新增 Image Set 后，必须同步更新对应的资源定义文件：

- **ResourceDR**：在 `Classes/SwiftModules/Base/Resource/Sources/ResourceDR/ResourceDR.swift` 的 `I` 枚举中，按功能域找到对应子枚举，添加新的 `static let` 属性
- **ResourceSN**：依赖 R.swift 自动生成，重新编译即可

```swift
// ResourceDR.swift 中的定义格式
public enum I {
    public enum common {
        public static let default_head_small = HYImageResource("Common/default_head_small")
        public static let navigation_return_normal = HYImageResource("Common/navigation_return_normal")
        // 新增图片：在对应子枚举中添加
        public static let ic_new_feature = HYImageResource("Common/ic_new_feature")
    }
}
```

### 9.6 远程图片加载

| 模块类型 | 加载方式 | 底层库 |
|----------|---------|--------|
| **非 SwiftModule** | `sd_setImageWithURL:placeholderImage:` | SDWebImage |
| **SwiftModule** | `hyimageview.loadImage(url:placeholderImage:)` | AlamofireImage（封装） |

使用时尽量传入本地占位图，占位图的引用方式遵循各模块的本地图片引用规范。

---

## 10. 组件复用与基类

项目中基类和公共组件按模块类型分为两套体系，开发时必须继承或使用对应的组件。

### 10.1 非 SwiftModule（OC）基类

所有 OC 基类位于 `Classes/BaseModules/Kits/BaseClasses/`：

| 基类 | 说明 |
|------|------|
| **HYBaseViewController** | **所有 VC 的基类**。封装导航栏显隐/半透明/阴影/侧滑返回、防截屏、默认白色背景、模态覆盖全屏、Crashlytics 生命周期日志。子类覆写 `navigationBarHidden` / `navigationPopEnable` 等定制行为。 |
| **HYNavigationController** | 自定义导航控制器。实现 `BackButtonHandlerProtocol` 拦截返回按钮，提供默认白底黑字导航栏样式。 |
| **HYBaseTableViewCell** | **所有 TableView Cell 的基类**。内置底部分割线（`bottomLineView`），提供 `+getCellIdentifier` 类方法，支持曝光刷新/失效机制。 |
| **HYBaseCollectionViewCell** | **所有 CollectionView Cell 的基类**。封装点击反馈色等通用逻辑，提供 `+getCellIdentifier` 类方法。 |
| **HYBaseModel** | **所有数据模型的基类**。继承 NSObject，遵循 NSCopying/NSCoding，集成 YYModel 做 JSON 映射。 |

### 10.2 SwiftModule 基类

SwiftModule 采用**面向协议 + 轻量基类**的策略，基类位于 `Classes/SwiftModules/Base/BaseKit/Sources/BaseUIKit/`：

| 基类 | 说明 |
|------|------|
| **HYViewController** | Swift 版 VC 基类，封装 `navigationHidden()` 和 `navigationPopEnable()` 控制。 |
| **HYNavigationController** (Swift) | 遵循 `ControllerProtocol`，可选绑定 ViewModel。 |
| **HYTabBarController** | 遵循 `ControllerProtocol`，可选绑定 ViewModel。 |
| **HYRoundView / HYRoundButton** | 自动圆角 View/Button，在 `draw` 中计算半径并设置圆角。 |
| **HYDashedView** | 虚线边框视图。 |
| **GradientButton** | 渐变按钮组件（配套 Gradient/Border/Appearance 配置）。 |
| **CountingLabel** | 数字滚动动画 Label。 |
| **InsetLabel** | 带内边距的 Label。 |

**Cell 复用**：Swift 侧不使用统一的 Cell 基类，而是通过 `CellProtocol`（即 `ReuseIdentifierProtocol`）协议提供 `static var reuseIdentifier` 默认实现。各业务模块自行定义 Cell 基类（如 BookCity 的 `BaseCell`、Community 的 `CommunityBaseCell`）。

### 10.3 公共复用组件

以下组件已抽取到 `Classes/BaseModules/CustomView/` 或 `Classes/CommonModules/CommonUI/`，开发时**优先查找是否已有可复用的组件**，避免重复造轮子。

#### 基础控件（BaseModules/CustomView/）

| 组件 | 路径 | 说明 |
|------|------|------|
| **HYEdgeLabel** | `BaseModules/CustomView/HYEdgeLabel.h` | 带内边距的 Label |
| **HYPlaceholderTextView** | `BaseModules/CustomView/HYPlaceholderTextView.h` | 带 placeholder 的 TextView |
| **HYTableView** | `BaseModules/CustomView/HYTableView.h` | 自定义 TableView |
| **HYRefreshControl 系列** | `BaseModules/CustomView/HYRefreshControl/` | 下拉刷新/上拉加载 |
| **HYHeadPortraitView** | `BaseModules/CustomView/HeadPortraitView/` | 用户头像视图 |
| **HYAddBookshelfToast** | `BaseModules/CustomView/HYAddBookshelfToast.h` | 加入书架提示 Toast |

**UIButton 扩大点击区域**：小尺寸图标按钮（如 20x20）应使用 `UIButton+EnlargeClickArea` 分类（`BaseModules/Kits/Categories/UIKit/UIButton+EnlargeClickArea.h`）扩大可点击范围，确保手指容易命中：

```swift
// 四周各扩大 10pt
sortButton.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
```

```objc
// 四周统一扩大
[button setEnlargeEdge:8];
```

#### 通用 UI 组件（CommonModules/CommonUI/）

| 组件 | 路径 | 说明 |
|------|------|------|
| **HYNewBookCoverView** | `CommonModules/CommonUI/BookCover/` | **书封组件（见 10.4 节）** |
| **HYCarouselView** | `CommonModules/CommonUI/BannerLoopView/` | 轮播 Banner 组件 |
| **HYAlertView / HYNewAlertView** | `CommonModules/CommonUI/Alert/` | 自定义 Alert 弹窗系统 |
| **HYLoadingView** | `CommonModules/CommonUI/Loading/` | Loading 加载视图（含 UIView/UIViewController 分类） |
| **HYBaseWarningView** | `CommonModules/CommonUI/EmptyView/` | 空页面/错误页面提示视图 |
| **HYPageTabView / HYPageContentView** | `CommonModules/CommonUI/PageTabView/` 和 `PageContentView/` | 多 Tab 页面容器 |
| **HYCircleProgressView** | `CommonModules/CommonUI/HYCircleProgressView.h` | 圆形进度条 |
| **HYGuideView** | `CommonModules/CommonUI/Guide/` | 引导页视图 |

### 10.4 书封组件：HYNewBookCoverView（强制使用）

**定义位置**：`Classes/CommonModules/CommonUI/BookCover/HYNewBookCoverView.h/.m`

项目中展示书籍封面的**唯一标准组件**。封装了封面图片异步加载、12 种角标类型（限免/折扣/漫画/会员/免费/广告/更新/系列书/完读/Hot/推荐/短篇）、自动圆角计算、日更标识、互动小说标识、中间播放按钮等完整功能。

> **规则**：非 SwiftModule 模块中，凡是需要展示书籍封面的地方，**必须使用 `HYNewBookCoverView`**，禁止自行用 UIImageView 拼凑封面。

使用方式（懒加载 + 公开配置方法）：

```objc
// 声明属性
@property (nonatomic, strong) HYNewBookCoverView *bookCoverView;

// 懒加载创建
- (HYNewBookCoverView *)bookCoverView {
    if (!_bookCoverView) {
        _bookCoverView = [[HYNewBookCoverView alloc] init];
    }
    return _bookCoverView;
}

// 配置封面
[self.bookCoverView setBookCoverUrl:coverUrl badgeType:HYBookCoverBadgeTypeFree];
```

Swift 中同样直接使用：

```swift
private let coverView = HYNewBookCoverView(frame: .zero)
```

### 10.5 弹窗组件：HYNewAlertView（推荐使用）

**定义位置**：`Classes/CommonModules/CommonUI/Alert/HYNewAlertView.swift`

项目中展示弹窗的**标准组件**。采用 **Config 驱动**模式（`HYNewAlertViewConfig`），支持图片、标题、描述、按钮、关闭按钮等元素的灵活组合，元素位置可配置（顶部/底部/居中/溢出）。

> **规则**：弹窗需求**必须优先使用 `HYNewAlertView`**。若其配置项无法满足需求，创建新弹窗类时**必须参考 `HYNewAlertView` 的样式规范和动画曲线**：

**样式规范**（新建弹窗类必须遵循）：

| 规范项 | 标准值 | 说明 |
|--------|--------|------|
| 蒙层颜色 | `UIColor.black.withAlphaComponent(0.6)` | 半透明黑色背景 |
| 内容背景 | `UIColor.colorFFFFFF` | 白色内容区域 |
| 默认圆角 | `20pt` | 内容视图圆角 |
| 内容左右间距 | `48pt`（默认） | 内容区域距屏幕边缘 |
| 内容底部间距 | `32pt`（默认） | 最后元素距内容底部 |
| 元素间距 | `24pt`（标题→描述）或 `28pt`（图片→标题） | 相邻元素垂直间距 |
| 内容宽度 | `SCREEN_WIDTH - contentInset * 2` | 自适应屏幕宽度 |
| 按钮背景 | 蓝紫渐变（`#3D88FF` → `#7E7AFF` → `#9790FF`） | 渐变方向：右到左 |
| 按钮字体 | `UIFont.appleSFUIFontRegular(withSize: 14)` | 白色文字 |
| 按钮单行圆角 | 全圆角（高度/2） | 胶囊形状 |
| 按钮多行圆角 | `20pt` | 固定圆角，字号减 2pt |

**动画规范**（新建弹窗类必须遵循）：

| 动画 | 参数 | 说明 |
|------|------|------|
| **入场** | 弹性动画，`duration: 0.5s`，`springDamping: 0.5`，`initialVelocity: 1`，`scaleX/Y: 0.7 → 1.0`，alpha `0 → 1` | 从中心弹性放大 + 淡入 |
| **退场** | `duration: 0.2s`，alpha `1 → 0` | 快速淡出后 `removeFromSuperview` |
| **展示方式** | `keyWindow.addSubview`，frame 设为全屏 `SCREEN_WIDTH x SCREEN_HEIGHT` | 覆盖在最顶层 |

```swift
// 示例：入场动画
UIView.animate(
    withDuration: 0.5,
    delay: 0,
    usingSpringWithDamping: 0.5,
    initialSpringVelocity: 1,
    options: .curveEaseInOut,
    animations: {
        self.contentView.transform = .identity    // scale 0.7 → 1.0
        self.contentView.alpha = 1.0
        self.bgView.alpha = 1                     // 蒙层淡入
    })

// 示例：退场动画
UIView.animate(withDuration: 0.2, animations: {
    self.bgView.alpha = 0.0
    self.contentView.alpha = 0.0
}, completion: { _ in
    self.removeFromSuperview()
})
```

### 10.6 复用原则

- 同一个 UI 模式在 **2 个或以上模块** 出现时，必须提取为公共组件，放入 `BaseModules/CustomView/` 或 `CommonModules/CommonUI/`。
- 公共组件通过 `configure(with:)` 或专门的配置方法暴露接口，**不暴露内部控件和布局**。
- 新增公共组件前，先搜索 `BaseModules/CustomView/` 和 `CommonModules/CommonUI/` 确认是否已有类似实现。

---

## 11. 加载动画规范

项目有两套并行的加载动画体系，分别服务于非 SwiftModule（OC）和 SwiftModule，包括 Lottie 动画、骨架屏、Shimmer 扫光等类型。

### 11.1 非 SwiftModule — HYLoadingView（核心加载组件）

**定义位置**：`Classes/CommonModules/CommonUI/Loading/HYLoadingView.h/.m`

项目中统一的加载动画组件，通过 `UIView+Loading` / `UIViewController+Loading` 分类提供便捷调用（内部通过 Associated Object 管理生命周期，强制主线程执行）。**非 SwiftModule 所有 Loading 必须通过此组件实现**，禁止自行拼凑 Lottie 视图。

五种变体对比：

| 变体 | 调用方法 | 动画资源 | 动画尺寸 | 背景/外框 | 适用场景 |
|------|---------|---------|---------|----------|---------|
| **全屏 Loading** | `showLoadingView` | `ficfun_loading.json`（独角兽） | 44pt | 白色背景 | 整页首次加载 |
| **小型 Loading** | `showSmallLoadingView` | `refreshLoading.json`（菊花） | 30pt | 透明背景 | 弹窗、卡片、局部区域 |
| **指示器 Loading** | `showIndicatorLoadingView` | `refreshLoading.json` | 30pt | 52pt 深色圆角框（`#000` 60% + 8pt 圆角），可附带 12pt 白色文字 | 需视觉突出的短暂加载 |
| **支付风格 Loading** | `showBgIndicatorLoadingView` | `refreshLoading.json` | 30pt | 52pt 白色圆角框 + 70% 黑色蒙层，可附带 16pt 白色文字（距框 8pt） | 支付、全局阻塞操作 |
| **静态骨架图** | `showSkeletonScreenView` | 自定义 UIImage | — | iPad 等比缩放填充，iPhone 原图 | 页面首次加载占位 |

```objc
// 全屏加载
[self.view showLoadingView];
[self.view showLoadingViewWithBackgroundColor:UIColor.clearColor];
[self.view hideLoadingView];

// 小型加载（支持 Y 轴偏移）
[self.view showSmallLoadingViewWithOffY:-50];
[self.view hideSmallLoadingView];

// 带文字 + 自动消失
[self.view showIndicatorLoadingViewWithTitle:@"Loading..." autoHiddenDuration:3.0];

// 支付风格
[self.view showBgIndicatorLoadingViewWithTitle:@"支付中..."];

// 静态骨架图
[self.view showSkeletonScreenViewWithImage:[UIImage imageNamed:@"skeleton_placeholder"]];
```

### 11.2 非 SwiftModule — HYShimmerAnimator（扫光动画）

**定义位置**：`Classes/BaseModules/Utils/HYShimmerAnimator.swift`

基于 `CALayer` + `CAGradientLayer` 的扫光效果，用于 VIP 会员卡、订阅卡片等组件。

| 属性 | 默认值 |
|------|--------|
| 动画时长 | 2.0s（单次扫光） |
| 停顿间隔 | 1.0s（两次扫光之间） |
| 重复 | 无限循环 |
| 自动恢复 | 监听 App 前后台切换，进入前台自动恢复 |

```swift
let animator = HYShimmerAnimator(targetView: vipCardView)
animator.image = UIImage(named: "shimmer_light")
animator.start()
animator.stop()
animator.remove()  // 完全移除，避免后台消耗 GPU
```

### 11.3 非 SwiftModule — 其他 Loading 组件

| 组件 | 位置 | 规格 | 用途 |
|------|------|------|------|
| **HYRefreshLoadingAnimationView** | `Classes/BaseModules/CustomView/HYRefreshControl/` | `refreshLoading.json`，30pt，支持单次/循环 | 下拉刷新 |
| **HYVideoLoadingView** | `Classes/BaseModules/Player/` | `CAGradientLayer` + `CAShapeLayer` 圆弧旋转，38pt，线宽 2pt，0.3s 淡入淡出 | 视频缓冲（支持显示网速） |

### 11.4 SwiftModule — HYSkeletonView（列表骨架屏）

**定义位置**：`Classes/SwiftModules/Base/BaseKit/Sources/BaseUIKit/SkeletonView/HYSkeletonView.swift`

基于 `SkeletonView` 库的泛型 CollectionView 骨架屏，用于列表数据加载前的灰色占位条展示。默认 `.clouds` 浅灰色，固定 10 行，垂直滚动，宽度 `SCREEN_WIDTH`。

**使用方式**：

1. Cell 子视图标记 `isSkeletonable = true`
2. 创建 `HYSkeletonView<YourCell>(frame: .zero)` 并添加到父视图（`didMoveToSuperview` 自动触发展示）
3. 数据加载完成后 `removeFromSuperview()`

### 11.5 SwiftModule — UIComponentLoading（DI 注入式 Loading）

**定义位置**：`Classes/SwiftModules/UIComponent/Sources/UIComponent/Components/UIComponentLoading.swift`

通过 Swift DI 系统提供的 Loading 服务。30pt `refreshLoading.json` 动画 + 52pt 白色圆角框（8pt）+ 16pt Regular 反白文字（间距 8pt），支持 `countDown` 倒计时（格式 `"标题 (Ns)"`）。

两种展示层级：**`.window`**（独立 UIWindow，覆盖所有页面）和 **`.controller`**（添加到指定 VC 的 view）。

```swift
Loading().startLoading(level: .window(()), title: "加载中...", countDown: nil)
Loading().startLoading(level: .controller(vc), title: "处理中", countDown: 30)
Loading().stopLoading()
```

### 11.6 Lottie 动画资源清单

存放于 `Classes/SwiftModules/Base/Resource/Sources/ResourceDR/Animation/`：

| 文件名 | 用途 |
|--------|------|
| `loading/refreshLoading.json` | 菊花旋转，最通用（小 Loading、下拉刷新、局部 Loading） |
| `loading/ficfun_loading.json` | 独角兽（白天），全屏 Loading 默认 |
| `loading/ficfun_loading_night.json` | 独角兽（夜间） |
| `loading/loadingdark.json` | 夜间菊花 |

> 动画资源通过 `OCCallSwiftAdapter` 桥接给 OC 侧（`HYAnimationView`）。Swift 侧通过 `F.refreshLoadingJson` 等类型安全引用，支持 `LottieAnimationCache` 缓存。新增资源需同步更新 OC 构造参数和 `ResourceDR.swift` 枚举。

### 11.7 使用原则

#### 场景选择指南

| 场景 | 推荐组件 | 模块域 |
|------|---------|--------|
| 整页首次加载 | `showLoadingView`（独角兽）或骨架图 | 非 SwiftModule |
| 弹窗/卡片内加载 | `showSmallLoadingView` | 非 SwiftModule |
| 带提示文案的加载 | `showIndicatorLoadingView` 或 `showBgIndicatorLoadingView` | 非 SwiftModule |
| 支付/阻塞操作 | `showBgIndicatorLoadingView` 或 `UIComponentLoading.window` | 非 SwiftModule / SwiftModule |
| 列表首次加载占位 | `HYSkeletonView` | SwiftModule |
| VIP 卡片扫光 | `HYShimmerAnimator` | 通用 |
| 下拉刷新 | `HYRefreshLoadingAnimationView` | 非 SwiftModule |
| 视频缓冲 | `HYVideoLoadingView` | 非 SwiftModule |

#### 关键约束

- **禁止**在业务代码中直接使用 `LottieAnimationView` 或 `MBProgressHUD` 拼凑 Loading
- Loading 展示/隐藏**必须在主线程**调用，各组件内部已做保护
- 同一视图避免同时展示多个 Loading
- 骨架屏数据加载完成后**必须移除**（`removeFromSuperview`）
- `HYShimmerAnimator` 必须在适当时机调用 `stop()` 或 `remove()`，避免后台消耗 GPU

---


## 12. 错误页与空页面规范

项目在 OC 和 Swift 两侧提供了多套错误页/空页面组件，选用时根据所在模块类型和交互复杂度决定：

| 需求场景 | 推荐组件 | 模块域 |
|----------|---------|--------|
| 全屏空状态，需刷新按钮 | `HYBaseWarningView` | 非 SwiftModule |
| 局部空状态，纯图文展示 | `UIView+Empty` | 非 SwiftModule |
| VC 级别空状态管理 | `UIViewController+Error` | 非 SwiftModule |
| Swift 页面，4 状态切换 | `StatefulViewController` 协议 | SwiftModule |
| Swift 页面，统一状态视图 | `UIComponentStateView`（`StatefulView`） | SwiftModule |

### 12.1 HYBaseWarningView（非 SwiftModule 通用空状态视图）

**文件位置**：`Classes/CommonModules/CommonUI/EmptyView/HYBaseWarningView.h/.m`

基于 `UIStackView` 纵向布局（spacing 20pt）的空状态视图，通过枚举 `HYWarningShowType`（共 47 种预设类型）驱动图标、文案和按钮样式。布局结构为 `warningImageView` → `titleLabel` → `button`（可选），StackView 居中于父视图，VC 场景中 centerY 偏移 `(TopMargin - BottomMargin) / 2.0`。

**子视图规格**：

| 子视图 | 关键属性 |
|--------|---------|
| `warningImageView` | `ScaleAspectFit` |
| `titleLabel` | 16pt Regular，60% 主色透明度，多行居中 |
| `button` | 1pt 边框 + 20pt 全圆角 + Bold 17pt 主题色 + 水平 50pt 内边距 |

**代表性枚举类型**：

| 枚举值 | 场景 | 有按钮 |
|--------|------|--------|
| `HYWarningShowTypeNoNetwork` | 无网络 | ✅ |
| `HYWarningShowTypeNoData` | 暂无数据 | ❌ |
| `HYWarningShowTypeLoadFailed` | 加载失败 | ✅ |
| `HYWarningShowTypeServerError` | 服务器错误 | ✅ |
| `HYWarningShowTypeNoNetworkDark` | 无网络（暗黑背景） | ✅ |

> 完整 47 种类型详见 `HYBaseWarningView.h`。

```objc
// VC 中使用（通过 UIViewController+Error 分类）
[self showEmptyViewWithType:HYWarningShowTypeNoNetwork
              refreshAction:^{ [self reloadData]; }
                  tapAction:nil];

// 动态修改文案
[self.baseWarningView updateTitle:@"新的提示文案"];
[self hideEmptyView];
```

### 12.2 UIView+Empty / UIViewController+Error（非 SwiftModule 分类扩展）

**文件位置**：`Classes/CommonModules/CommonUI/EmptyView/`

通过 Associated Object 为 UIView / UIViewController 提供轻量级空状态管理，无需子类化。

- **UIView+Empty**：简易纯图文空视图（`UIImageView` 居中 + `UILabel` 下方 20pt，14pt Regular 60% 黑色多行居中），支持 YYLabel 富文本高亮交互
- **UIViewController+Error**：在 `UIView+Empty` 基础上封装，内部自动将 `HYBaseWarningView` 添加到 VC 的 view 上，重复调用自动替换旧视图

```objc
// 简易空视图
[self addEmptyViewWithImageName:@"img_empty_default" title:@"暂无数据"];

// 带高亮交互
[self addEmptyViewWithImageName:@"img_empty_default"
                          title:@"还没有记录，去书城逛逛吧"
                  highlightText:@"书城"
                 highlightColor:[UIColor blueColor]
                        offsetY:0
                 hightTapAction:^{ [self goToBookCity]; }];

[self removeEmptyView];
```

### 12.3 StatefulViewController 协议体系（SwiftModule）

**文件位置**：`Classes/SwiftModules/Base/BaseKit/Sources/BaseUIKit/StatefulViewController/`

Swift 协议驱动的四状态视图管理方案，适用于需要 **内容 / 加载 / 错误 / 空** 四种状态平滑切换的页面。通过 `ViewStateMachine` 管理状态切换，动画为 UIView 0.3s 交叉淡入淡出，串行队列保证线程安全。

协议要求提供 `loadingView`、`errorView`、`emptyView_s` 三个占位视图属性，以及 `hasContent()` 判定方法。状态切换时自动处理占位视图的添加/移除和过渡动画。

### 12.4 StatefulView 统一状态视图组件（SwiftModule）

**文件位置**：`Classes/SwiftModules/UIComponent/Sources/UIComponent/Components/UIComponentStateView.swift`

`UIComponentStateView`（即 `StatefulView`）是 SwiftModule 的统一状态视图组件，UIStackView 纵向布局（spacing 20pt）：插图（Lottie 或静态图）+ 描述文案 + 刷新按钮。

**关键规格**：

| 子视图 | 规格 |
|--------|------|
| imageView | 宽度 = 父视图 × 0.5 |
| animationView | 宽度 = 父视图 × 1/3 |
| desLabel | 16pt Regular，`color_txt_w_ic_secondary`，多行，最大宽度 `SCREEN_WIDTH - 92pt` |
| refreshButton | 44pt 全圆角，宽度 `SCREEN_WIDTH - 150pt` |

**按钮样式**：实心（`.normal`：`#B857FF` 紫底白字）和边框（`.border`：紫边紫字透明底）。

遵循 `ControllerStateViewProtocol`，提供 RxSwift `refreshEvent`、`contentOffset`、`imageViewSizeProportion` 等配置项。通过 `UIComponentStateViewProtocol` 工厂方法创建：`staticStateView()`、`animationLoadingView()`、`staticEmptyView()`。

### 12.5 使用原则

- **模块边界清晰**：OC 侧用 `HYBaseWarningView` / `UIView+Empty` / `UIViewController+Error`；Swift 侧用 `StatefulViewController` 协议 + `StatefulView`
- **禁止**跨模块域引用（OC 不引用 `StatefulView`，Swift 不绕过协议直接用 `HYBaseWarningView`）
- 空视图展示时应**禁用**底层滚动视图的 `scrollEnabled`，隐藏时恢复
- 刷新回调中应**先隐藏空视图再发起请求**，避免重复展示
- 颜色使用项目 ColorSet 方法，暗黑模式自动适配

---


## 13. 多语言与国际化

项目支持 **15 种语言**（ar / de / en / es / fr / id / it / ja / ko / pt / ru / th / tl / tr / vi），Dreame 产品额外支持 `fil`（Filipino）。RTL 语言仅阿拉伯语（`ar`）。

### 13.1 资源文件存放

三套并行的多语言资源，分别服务于不同模块：

| 模块范围 | 资源路径 | 文件格式 |
|----------|---------|----------|
| **非 SwiftModule（OC）** | `Classes/BaseModules/CommonResources/LanguageLproj/{lang}.lproj/Localizable.strings` | 标准 `.strings`（EN 约 3574 行），key-value 格式，key 即为英文原文 |
| **SwiftModule (Dreame)** | `Classes/SwiftModules/Base/Resource/Sources/ResourceDR/Language/{lang}.lproj/Localizable.strings` | 标准 `.strings` |
| **SwiftModule (Starynovel)** | `Classes/SwiftModules/Base/Resource/Sources/ResourceSN/Language/{lang}.lproj/Localizable.strings` | 标准 `.strings` |
| **InfoPlist** | `ReaderPackage/Dreame/SupportingFiles/{lang}.lproj/InfoPlist.strings` | 权限说明等系统级文案 |

> 项目中**不存在** `.stringsdict` 文件（复数形式通过 `NSString stringWithFormat:` 动态拼接）。

### 13.2 非 SwiftModule（OC）字符串加载

OC 代码统一使用标准 `NSLocalizedString(key, comment:)`，**无需自定义宏**。项目通过 `NSBundle+HYLanguages` 对 `[NSBundle mainBundle]` 做了 method swizzling，自动将字符串查找重定向到当前语言对应的 `.lproj` 目录。

```objc
// 简单字符串
self.titleLabel.text = NSLocalizedString(@"ABOUT", nil);

// 带格式化的字符串
NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"quick_recharge_title_coins", nil), @(price)];

// 弹窗示例
HYAlertView *alert = [HYAlertView alertViewWithTitle:NSLocalizedString(@"notice", nil)
    message:NSLocalizedString(@"download_episodes_no_wifi_tip", nil)
    leftButtonTitle:NSLocalizedString(@"cancel", nil) leftButtonClickAction:nil
    rightButtonTitle:NSLocalizedString(@"yes", nil) rightButtonClickAction:^{ ... }];
```

**实现机制**：`NSBundle+HYLanguages`（`Classes/BaseModules/Kits/Categories/Foundation/NSBundle+HYLanguages.m`）
- 自定义 `HYCustomBundle` 子类覆盖 `localizedStringForKey:value:table:` 方法
- 从当前语言对应的 `.lproj` bundle 加载字符串
- 使用 `NSCache`（countLimit=2000）缓存查找结果

### 13.3 SwiftModule 字符串加载

SwiftModule 使用**类型安全的枚举 + 访问器**模式，杜绝硬编码字符串 key。

**定义文件**：`Classes/SwiftModules/Base/Resource/Sources/ResourceDR/ResourceDR.swift`（约 9752 行）

```swift
// 枚举定义（~1785 个 case，key 即为英文原文）
public enum HYLanguageResource: String {
    case ABOUT = "ABOUT"
    case pd_days_ago = "%d days ago"
    case you_will_also_like = "you_will_also_like"
}

// 访问器类（提供类型安全的方法调用）
public class HYLanguageResourceAccessor {
    public func ABOUT() -> String {
        return NSLocalizedString(HYLanguageResource.ABOUT.rawValue, comment: "")
    }
    public func pd_days_ago(_ args: CVarArg...) -> String {
        let format = NSLocalizedString(HYLanguageResource.pd_days_ago.rawValue, comment: "")
        return String(format: format, arguments: args)
    }
}
```

**调用方式**：通过 DI 注入的 `languageResouce` 访问器：

```swift
// 在任意 ViewController 或 View 中
let title = iUserPreferencesConfig.languageResouce.discover_fragment_top_title()
let okText = iUserPreferencesConfig.languageResouce.OK()
let noData = iUserPreferencesConfig.languageResouce.no_data()
```

> `languageResouce` 由 `UserPreferencesModule` 初始化并注入，定义于 `Base/Interface/Sources/Proto/ConfigModule/UserPreferencesModuleProtocol.swift`。

**新增字符串流程**：
1. 在三个 `Localizable.strings`（OC / ResourceDR / ResourceSN）的各语言副本中添加 key-value
2. 在 `ResourceDR.swift` 的 `HYLanguageResource` 枚举中添加新 case
3. 在 `HYLanguageResourceAccessor` 中添加对应的访问器方法

### 13.4 多语言图片

对于包含文字的图片资源，使用 `UIImage+Multilingual` 分类（`Classes/BaseModules/Utils/UIImage+Multilingual.h/.m`）加载。

**查找顺序**：`<name>_<language>` → `<name>` → `<name>_en`

```objc
// OC 示例
UIImage *image = [UIImage multilingualImageNamed:@"pay_guide"];
self.authorizationLogoImageView.image = [UIImage multilingualImageNamed:@"detail_authorized"];
```

```swift
// Swift 示例
logoImageView.image = UIImage.multilingualImageNamed("start_logo")
guideButton.setBackgroundImage(UIImage.multilingualImageNamed("reading_pay_guide"), for: .normal)
```

**存放位置**：多语言图片直接放入对应模块的 Assets.xcassets 中，通过 `_语言码` 后缀区分版本：
- `detail_authorized` — 默认/英文版
- `detail_authorized_ar` — 阿拉伯语版
- `detail_authorized_de` — 德语版

### 13.5 语言切换机制

**核心入口**：`HYClient`（`Classes/BaseModules/Utils/HYClient.h/.m`）

| API | 说明 |
|-----|------|
| `currentAppLanguage`（readonly） | 获取当前语言码，优先级：内存缓存 → `NSUserDefaults` → 系统语言白名单匹配 → 默认 `"en"` |
| `setCurrentAppLanguage:isPersistence:` | 设置语言，持久化到 `NSUserDefaults`，同时触发 `NSBundle` swizzle 重定向 |

**运行时切换流程**：
```
用户选择语言
  → HYClient.setCurrentAppLanguage:isPersistence:YES
    → NSBundle.setupCurrentLanguage:（swizzle mainBundle 到对应 .lproj）
    → NSUserDefaults 持久化
    → 通知 SwiftModule DI 服务更新
    → 各模块 changeLanguageRefresh() 刷新 UI
    → restartFirstScreenForTab（重建 TabBar）
```

**RTL 判断**：使用宏 `isRTL()`（仅当语言为 `"ar"` 时返回 YES），用于控制视图的左右镜像适配。

### 13.6 Figma 设计稿中的多语言文案

当 Figma 设计稿中包含文案时，处理策略：

1. **所有文本均走多语言**：从 Figma 中提取的**任何文本**（标题、按钮文案、提示信息、占位文字等）都必须以多语言 Key 的形式填充，**禁止**将 Figma 中看到的文字内容直接硬编码到代码中。若对应 Key 尚未在 `Localizable.strings` 中定义，则先用 Key 占位并添加 `// TODO: 多语言翻译key替换` 标记，等待后续翻译人员批量替换。
2. **不信任设计稿文字**：Figma 中的文字仅为**设计预览**，不代表最终文案。无法保证其与 `Localizable.strings` 中的翻译一致，也不能确保 Figma 中的语言就是用户当前看到的语言。
3. **确认 Key**：先搜索 `Localizable.strings` 确认是否已有对应 Key；若没有，使用小写下划线格式命名新 Key（如 `settings_new_feature_title`）。
4. **同步添加**：在三个 `Localizable.strings` 资源目录（OC / ResourceDR / ResourceSN）的**所有语言**文件中添加新条目。未翻译的语言可暂时用英文填值。
5. **SwiftModule 额外步骤**：在 `ResourceDR.swift` 的枚举和访问器类中同步添加新 case 和方法。

---

## 14. 动画与交互

- 简单动画使用 `UIView.animate(withDuration:...)` 或 `UIViewPropertyAnimator`。
- 动画时长参考：
  - 微交互（按钮点击反馈）：`0.15s - 0.2s`
  - 页面转场 / 展示：`0.3s`
  - 复杂入场效果：`0.4s - 0.5s`
- 复杂动画可引入 **Lottie**，但必须经过团队评审。
- 禁止在主线程执行耗时计算；动画帧率需保持 60fps。

---

## 15. 机型与系统版本适配

项目最低部署目标为 **iOS 13.0**，同时支持 iPhone 和 iPad。所有 UI 代码必须正确适配不同机型和系统版本。

### 15.1 iPad 适配

使用全局常量 `isIPad`（定义于 `SwiftMacro.swift`）判断当前设备：

```swift
// ✅ 正确：使用全局常量
if isIPad {
    // iPad 专用布局
} else {
    // iPhone 布局
}
```

**布局适配原则**：

- **屏幕尺寸**：`SCREEN_WIDTH` / `SCREEN_HEIGHT` 已自动反映当前设备实际尺寸，无需额外判断
- **等比缩放**：`SCREEN_WIDTH_DIFF_RATIO` 已内置 iPad 适配（iPad 以 768pt 为基准、iPhone 以 375pt 为基准），需要等比缩放的长度值直接乘以该比例
- **相对比例优先**：布局中尽量使用相对于父视图的比例（如 `width.equalToSuperview().multipliedBy(0.8)`）而非硬编码固定 pt 值
- **可调节区域**：iPad 上部分视图（如阅读器正文、弹窗）限制最大宽度以保持可读性，使用 `min(SCREEN_WIDTH, 最大宽度)` 模式
- **尺寸变化监听**：iPad 支持分屏/侧拉，视图必须能响应 `viewWillTransition(to:with:)` 中尺寸变化，使用 `layoutSubviews` 或 Auto Layout 自适应

```swift
// ✅ 正确：限制最大宽度保持可读性
let contentWidth = min(SCREEN_WIDTH, 600)

// ✅ 正确：根据设备调整比例
let ratio = isIPad ? 0.55 : 0.8
```

### 15.2 刘海屏 / 全面屏适配

使用全局常量 `IS_BAND_SCREEN`（定义于 `SwiftMacro.swift`）判断全面屏机型：

```swift
// 安全区域常量已自动适配（SwiftMacro.swift 全局定义）
// TopMargin / BottomMargin / StatusBarHeight 等直接使用即可
view.snp.makeConstraints { make in
    make.bottom.equalToSuperview().offset(-BottomMargin)
}
```

**禁止**自行通过 `safeAreaInsets.bottom > 0` 或硬编码数值判断机型。所有安全区域相关高度统一使用 6.5 节列出的全局常量。

### 15.3 系统版本适配

项目最低部署 iOS 13.0，涉及以下关键 API 分界点：

| API 分界 | 版本 | 影响 |
|----------|------|------|
| `safeAreaInsets` | iOS 11.0 | 项目最低支持，**所有机型均可直接使用**，无需 `@available` 检查 |
| `UIScene` / `keyWindow` 变更 | iOS 13.0 | `UIApplication.shared.keyWindow` 在 iOS 13+ 已废弃 |
| `UIWindowScene.keyWindow` | iOS 15.0 | 推荐的 keyWindow 获取方式 |

**Window 获取**：使用 `UIDevice.hy_getKeyWindow()` 扩展方法（`SwiftMacro.swift`），其内部已处理版本差异：

```swift
// ✅ 正确：使用封装方法
let keyWindow = UIDevice.hy_getKeyWindow()

// ❌ 禁止：直接访问已废弃 API
let window = UIApplication.shared.keyWindow
```

**API 可用性检查**：使用 `#available` 语法包裹版本敏感代码：

```swift
if #available(iOS 13.0, *) {
    // iOS 13+ 特性
} else {
    // iOS 12 降级方案
}
```

**常见需版本检查的场景**：
- `UIColor.systemBackground` 等语义色（iOS 13+），iOS 12 需使用硬编码色值
- `UISceneDelegate` 相关 API（iOS 13+）
- `SF Symbols` 图标（iOS 13+）
- `UICollectionViewCompositionalLayout`（iOS 13+）

**原则**：能用 Auto Layout + SnapKit 解决的问题不依赖特定系统版本；版本适配复杂度应封装在 `SwiftMacro.swift` 或扩展方法中，业务层直接调用封装后的 API。

---

## 16. 性能与调试

- 列表和集合视图必须使用 Cell 复用，并正确设置 `estimatedRowHeight` 以启用自定高度。
- 避免视图层级过深（一般不超过 10 层），复杂页面考虑用 `CALayer` 或异步绘制优化。
- 图像解码在后台线程进行，大图使用降采样策略。
- 调试约束冲突时，给约束设置标识：
```swift
constraint.identifier = "avatar-top"
```
- 使用 `Instruments` 的 `Core Animation` 和 `Time Profiler` 定期检查。

---

## 17. 第三方库约定

- 所有依赖通过 **CocoaPods** 和 **Swift Package Manager** 统一管理。
- **禁止**在业务代码中直接调用未封装的第三方库核心 API；需在 `Helpers` 或 `Extensions` 中二次封装，以降低耦合。

> **本规范由 StaryReader iOS 团队制定并维护，任何修改需通过 MR 合入。**  
> 所有通过 Figma 设计稿生成的代码，必须符合本规范全部条目。若发现冲突，优先遵循规范，并同步反馈至设计侧。
