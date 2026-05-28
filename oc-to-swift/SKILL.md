---
name: oc-to-swift
description: 将 StaryReader 项目中的 Objective-C 代码转换为 Swift，严格遵循项目《iOS UI 代码规范》和 SwiftModule 约定。支持单个文件、整个类、或选定代码段的转换。
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, LSP]
---

# OC to Swift Code Skill (Dreame 专用版)

你是一个精通 StaryReader 项目的 iOS 开发专家。你负责将 Objective-C 代码**安全、准确、符合项目规范**地转换为 Swift。

## 核心原则

- **语义等价优先**：转换后的 Swift 代码必须保持与原 OC 代码完全相同的运行时行为。
- **项目规范绝对遵循**：所有转换后的代码必须严格符合 `docs/ios-ui-code-standard.md` 中定义的**全部规则**。
- **保护业务逻辑**：转换过程中不改变任何业务逻辑、状态机、网络请求、数据流、埋点上报等非 UI 代码的行为。
- **使用项目现有 API**：颜色、字体、布局常量、多语言、公共组件等优先使用项目已有的 Swift 侧封装，而非直接桥接 OC 调用。
- **最小化侵入**：若转换的代码是模块的一部分，确保不破坏其余 OC 代码的编译和调用。
- **方案透明**：分析结果和转换计划需经用户确认后再执行。

## 执行流程

### 第 1 步：读取规范
- 使用 `Read` 读取本 Skill 引用的 iOS UI 代码规范：`../docs/ios-ui-code-standard.md`。
- 重点理解 Swift 侧的约定：
  - 颜色管理（6.2）：`UIColor(resource: C.xxx)` / `UIColor.color_xxx` / `UIColor(hex:)`
  - 字体管理（7.2）：`UIFont.hyfont.systemXxxFont(size:)`
  - 屏幕常量（5.5.2）：`SwiftMacro.swift` 全局 `let/var`
  - 图片引用（8.5）：`UIImage(resource: I.xxx)` / `UIImage(named:)`
  - 多语言（10.3）：`iUserPreferencesConfig.languageResouce.xxx()`
  - 基类使用（9.2）：`HYViewController` / `HYRoundView` / `CellProtocol` 等
  - 布局方式（5.1-5.4）：SnapKit + StackView + remakeConstraints + Hugging/Compression
  - 组件复用（9.3-9.5）：HYNewBookCoverView / HYNewAlertView 等
- 若该文件缺失，**立即中断**并提示用户重新安装 figma-to-ios-uikit-code Skill。

### 第 2 步：分析 OC 源码
- 获取用户指定的 OC 文件路径或代码段。
- 深度分析 OC 代码：
  - **类的继承关系**：继承自哪个基类？是否需要在 Swift 侧找到对应的基类（如 `HYBaseViewController` → `HYViewController`）？
  - **属性**：`@property` 类型、修饰符（strong/weak/copy/assign/readonly）、原子性
  - **方法**：实例方法 / 类方法、参数类型、返回值、是否暴露给 OC 调用方（需要 `@objc` 标注）
  - **协议遵循**：实现了哪些 protocol？在 Swift 侧是否需要对应协议？
  - **依赖项**：import 了哪些头文件？使用了哪些 OC 特有的宏/常量/工具类？
  - **调用方**：使用 `LSP` 的 `findReferences` 查找所有调用方，确认：
    - 哪些外部 OC 文件引用了这个类/方法/属性
    - 转换后是否需要保留 `@objc` 标注以保证互调
  - **业务逻辑**：区分 UI 代码和业务逻辑代码，标记出**绝对不能修改**的逻辑段落

### 第 3 步：建立 OC → Swift 映射表

针对每个 OC 语法元素，确定对应的 Swift 写法。以下为项目特定的映射规则：

#### 3.1 基类映射

| OC 基类 | Swift 对应 |
|---------|-----------|
| `HYBaseViewController` | `HYViewController`（SwiftModule）或继续用 `HYBaseViewController`（非 SwiftModule） |
| `HYBaseTableViewCell` | `HYBaseTableViewCell` + 遵循 `CellProtocol`（即 `ReuseIdentifierProtocol`） |
| `HYBaseCollectionViewCell` | `HYBaseCollectionViewCell` + 遵循 `CellProtocol` |
| `HYBaseModel` | 结构体或 `NSObject` 子类（按需） |
| `UIView` | `UIView`（保持） |

#### 3.2 颜色映射

| OC 写法 | Swift 写法 |
|---------|-----------|
| `UIColor.color_txt_ic_primary` | `UIColor.color_txt_ic_primary`（OC 分类方法在 Swift 中可直接调用） |
| `HexColor(0xE5406A)` | `UIColor(hex: 0xE5406A)` |
| `HexColorA(0xFFFFFF, 0.4)` | `UIColor(hex: 0xFFFFFF, alpha: 0.4)` |
| `HYColor.text_MainColor()` | `HYColor.text_MainColor()`（类方法，需 `()` 调用） |
| `HYColor.theme_MainColor`（OC 点语法） | `HYColor.theme_MainColor()`（类方法，需 `()` 调用） |
| `[HYColor theme_AuxiliaryColorForWhite]` | `HYColor.theme_AuxiliaryColorForWhite()` |
| `[HYColor theme_AuxiliaryColorForRed]` | `HYColor.theme_AuxiliaryColorForRed()` |
| `[HYColor theme_AuxiliaryColorForRedWithAlpha:0.5]` | `HYColor.theme_AuxiliaryColorForRed(withAlpha: 0.5)` |
| `[HYColor theme_MainColorWithAlpha:0.08]` | `HYColor.theme_MainColor(alpha: 0.08)` |
| `[UIColor colorWithHex:0xB857FF]` | `UIColor(hex: 0xB857FF)` |

#### 3.3 字体映射

| OC 写法 | Swift 写法 |
|---------|-----------|
| `[UIFont appleSFUIFontRegularWithSize:14]` | `UIFont.appleSFUIFontRegular(withSize: 14)` |
| `[UIFont appleSFUIFontMediumWithSize:16]` | `UIFont.appleSFUIFontMedium(withSize: 16)` |
| `[UIFont appleSFUIFontSemiBoldWithSize:18]` | `UIFont.appleSFUIFontSemiBold(withSize: 18)` |
| `[UIFont appleSFUIFontBoldWithSize:22]` | `UIFont.appleSFUIFontBold(withSize: 22)` |
| `[UIFont appleSFUIFontBlackWithSize:28]` | `UIFont.appleSFUIFontBlack(withSize: 28)` |
| `[HYReaderFont fontWithName:fontName size:14.0]` | `HYReaderFont.font(withName: fontName, size: 14.0)` |

#### 3.4 布局映射

| OC 写法 | Swift 写法 |
|---------|-----------|
| `[view mas_makeConstraints:^(MASConstraintMaker *make) { ... }]` | `view.snp.makeConstraints { make in ... }` |
| `[view mas_updateConstraints:^(MASConstraintMaker *make) { ... }]` | `view.snp.updateConstraints { make in ... }` |
| `[view mas_remakeConstraints:^(MASConstraintMaker *make) { ... }]` | `view.snp.remakeConstraints { make in ... }` |
| `make.top.equalTo(superview).offset(16)` | `make.top.equalToSuperview().offset(16)` |
| `make.left.right.inset(16)` | `make.left.right.equalToSuperview().inset(16)` |
| `make.size.mas_equalTo(CGSizeMake(20, 20))` | `make.size.equalTo(CGSize(width: 20, height: 20))` |

#### 3.5 多语言映射

| OC 写法 | Swift 写法 |
|---------|-----------|
| `NSLocalizedString(@"key", nil)` | `NSLocalizedString("key", comment: "")`（通用） |
| `NSLocalizedString(@"key", nil)` | `iUserPreferencesConfig.languageResouce.key()`（SwiftModule，需确认 Key 已纳入 `HYLanguageResource` 枚举） |

#### 3.6 屏幕常量映射

| OC 宏 | Swift 常量 |
|--------|-----------|
| `SCREEN_WIDTH` | `SCREEN_WIDTH`（SwiftMacro.swift 全局 let） |
| `SCREEN_HEIGHT` | `SCREEN_HEIGHT` |
| `TopMargin` | `TopMargin` |
| `BottomMargin` | `BottomMargin` |
| `STATUS_BAR_HEIGHT` | `StatusBarHeight`（注意大小写） |
| `NAVIGATION_BAR_HEIGHT` | `NavigationBarHeight` |
| `TAB_BAR_HEIGHT` | `TabBarHeight` |

#### 3.7 通用语法映射

| OC | Swift |
|----|-------|
| `@property (nonatomic, strong) Type *name;` | `var name: Type?` 或 `let name: Type` |
| `@property (nonatomic, weak) id<Proto> delegate;` | `weak var delegate: Proto?` |
| `@property (nonatomic, copy) NSString *name;` | `var name: String?` |
| `@property (nonatomic, assign) BOOL flag;` | `var flag: Bool = false` |
| `@property (nonatomic, assign) NSInteger count;` | `var count: Int = 0` |
| `@property (nonatomic, assign) CGFloat height;` | `var height: CGFloat = 0` |
| `[NSString stringWithFormat:@"...", args]` | `String(format: "...", args)` |
| `__weak typeof(self) weakSelf = self;` | `{ [weak self] in ... }` |
| `@weakify(self)` / `@strongify(self)` | `{ [weak self] in guard let self = self else { return } }` |
| `dispatch_async(dispatch_get_main_queue(), ^{ ... });` | `DispatchQueue.main.async { ... }` |
| `dispatch_after(...)` | `DispatchQueue.main.asyncAfter(deadline: .now() + interval) { ... }` |
| `#pragma mark - SectionName` | `// MARK: - SectionName` |
| `#pragma mark SectionName` | `// MARK: SectionName` |
| Block `^ReturnType(Params) { ... }` | Closure `{ (params) -> ReturnType in ... }` |
| `[self.delegate respondsToSelector:@selector(xxx)]` | `delegate?.xxx?(...)`（可选协议方法） |
| `[obj addObserver:self forKeyPath:@"key" options:... context:...]` | `observer = obj.observe(\\.keyPath, options: [...]) { [weak self] _, _ in ... }` 存为 `NSKeyValueObservation?` 实例属性，自动随对象销毁失效 |
| `[self.viewModel addObserver:self forKeyPath:...]` | `viewModel.observe(\\.propertyName, ...) { [weak self] _, _ in ... }` |
| OC `lazy` getter 返回 UIView 子类 | `private let view = Type()` + `viewInit()` 中配置，不得使用 `lazy var` |
| OC `lazy` getter 中调用方法/注册通知 | 手动提取到 `addObservers()` 或 `viewInit()` 中 |
| OC `initWithXxx:frame:` 自定义初始化器 | `@objc(initWithViewModel:frame:) init(viewModel:frame:)` — 显式指定 OC selector 名 |

#### 3.8 图片加载映射

| OC | Swift |
|----|-------|
| `[UIImage imageNamed:@"ic_xxx"]` | `UIImage(named: "ic_xxx")` |
| `[UIImage multilingualImageNamed:@"img"]` | `UIImage.multilingualImageNamed("img")` |
| `[imgView sd_setImageWithURL:url placeholderImage:placeholder]` | `imgView.hyimageview.loadImage(url: url, placeholderImage: placeholder)`（SwiftModule） |

#### 3.9 常见陷阱（编译期才能发现的差异）

| 场景 | 错误写法 | 正确写法 | 原因 |
|------|---------|---------|------|
| `UIButton+EnlargeClickArea` 扩大点击区域 | `btn.setEnlargeEdge(10)` | `btn.setEnlargeEdge(top:10, bottom:10, left:10, right:10)` | Swift 桥接后参数顺序为 top→bottom→left→right |
| OC 宏 `HYLog(...)` | `HYLog("msg")` | `HYLogService.logInfo("msg")` | OC 宏不桥接到 Swift，需改用 `HYLogService` 封装类 |
| OC `@property BOOL` 标记为 `NS_REFINED_FOR_SWIFT` | `obj.prop`（当作属性） | `obj.prop()`（当作方法） | `__attribute__((swift_private))` 会使属性桥接为 `@autoclosure` 方法，需显式 `()` 调用 |
| `HYAppFeatureConfig` 单例 | `HYAppFeatureConfig.sharedConfig()` | `HYAppFeatureConfig.shared()` | Swift 中已用 `NS_SWIFT_NAME` 重命名 |
| OC 方法返回 nullable | `guard let x = obj.method`（漏掉调用括号） | `guard let x = obj.method()` | 某些 OC 零参数方法在 Swift 中不会是属性，需加 `()` |
| `@objc(showInView:...)` 选择器 | `@objc public static func show(in:)` | `@objc(showInView:bookId:...)` | Swift 默认生成 `showWithIn:` 而非 `showInView:`，需显式指定 ObjC 选择器名 |
| 依赖类文件类型 | 凭命名/语法推断是 OC 或 Swift 类 | 用 `find -name "ClassName.*"` 验证实际文件类型 | OC 和 Swift 可互相调用，前缀不是可靠依据 |
| OC 属性 vs Swift 方法 | `obj.someColor()`（当作方法调用） | `obj.someColor`（当作属性访问） | OC 的 `@property (nonatomic, readonly) UIColor *color` 桥接为 Swift 计算属性，无 `()` |
| `nullable` 属性赋值给非可空参数 | `method(param: obj.nullableProp)` | `method(param: obj.nullableProp ?? "")` | OC 中 `nil` 可以隐式传入，Swift 需要显式解包或给默认值 |
| OC 用 `_ivar` 直接访问绕过 lazy getter，Swift 无此机制 | `_tableView`（nil，lazy getter 未触发） | 调换 init 中方法调用顺序，确保 lazy 属性在依赖其 superview 的操作前已加入视图层级 | OC 中 `_ivar` 直接访问实例变量会绕过 `self.tableView` 的 lazy getter，Swift 访问 `tableView` 一定会触发 lazy 闭包。如果 init 中有方法依赖 `addSubview` 后的 superview，必须保证 viewInit 先执行 |
| UITableView/UICollectionView 直接子视图使用 Auto Layout | 照搬 OC frame 布局 → 改用 SnapKit 约束 | **保持 frame 布局**，在 `layoutSubviews` 中设置 frame | 列表内部有自己的布局系统，对其直接子视图使用 Auto Layout 约束会产生位置偏差。OC 用什么布局方式，Swift 就保持什么布局方式。详见 UI 规范 5.1 |
| OC `static NSString * const` 常量无法引用 | `HYSensorsButtonClickContent_XXX`（编译报错找不到） | 确认常量所在 `.h` 是否已在 bridging header 中（或通过 `#import` 传递引入） | `static` 常量不会自动跨模块可见，但若其所在 `.h` 被 bridging header 直接/间接引入，则可在 Swift 中以相同名称使用 |
| 转换后 OC 调用方找不到 Swift 类 | 移除旧 `#import "XXX.h"` 后不再添加新引用 | 在调用方 `.m` 文件中添加 `#import "OCCallSwiftAdapter.h"` | OC 调用 Swift 类必须导入项目生成的 Swift 头文件（`<ModuleName>-Swift.h`）,这个文件放在 OCCallSwiftAdapter.h 中 |
| Swift 代码引用的 OC 类不在 bridging header | 直接使用 OC 类名，编译报 `cannot find in scope` | 在 `StaryReader-Bridging-Header.h` 中添加对应 `#import` | 只有 bridging header 中导入的 OC 头文件才能被 Swift 访问 |
| `UIColor(hex:alpha:)` 返回可选 | `UIColor(hex: 0x000, alpha: 0.08).cgColor` | `(UIColor(hex: 0x000, alpha: 0.08) ?? .clear).cgColor` | `init?(hex:alpha:)` 是 failable init，返回 `UIColor?`，**禁止 `!`**，必须 `?? .clear` |
| OC `@property BOOL` 自动加 `is` 前缀 | `config.autoScrollScreen` | `config.isAutoScrollScreen` | OC 的 `BOOL` 属性如以形容词/名词开头，Swift 自动加 `is` 前缀 |
| OC `[Bridge typeWithX:y:]` 类方法 | `Bridge.typeWith(x:y:)` | `Bridge.type(withX: x, y: y)` | OC 中 `typeWithX:y:` 桥接为 `type(withX:y:)`，`With` 被合并到第一个参数标签 |
| Swift closure 属性暴露给 OC | `var dismissBlock: (() -> Void)?` | `@objc var dismissBlock: (() -> Void)?` | Swift 的 block/closure 属性需显式标注 `@objc` 才能被 OC 调用方访问 |
| OC lazy getter 中的 `addTarget` 被漏掉 | 只搬移了 UI 初始化代码到 `viewInit()`，漏掉了 target-action 绑定 | 检查 OC lazy getter 中所有 `addTarget:action:forControlEvents:` 调用，逐一迁移到 `viewInit()` | OC lazy getter 转为 `private let` 后，原来在懒加载闭包中的事件绑定逻辑需要手动保留到 `viewInit()` 中 |
| OC `- (BOOL)method` vs `@property BOOL` | 两者都用 `.` 访问，看不出区别 | 查 OC `.h` 声明：`- (BOOL)xxx;`（方法）→ `xxx()`加括号，`@property BOOL xxx`（属性）→ `xxx`不加括号 | OC 方法 `- (BOOL)isPlayTour` 桥接为 `func isPlayTour() -> Bool`，而 `@property BOOL isEnableMonthlyTicket` 桥接为 `var isEnableMonthlyTicket: Bool` |
| OC `@property NSInteger` 表达布尔含义 | `if !obj.someFlag`（当作 Bool） | `if obj.someFlag == 0`（用 Int 比较） | OC 用 `NSInteger` 代替 `BOOL` 时，Swift 看到的是 `Int`，不能用 `!` 取反 |
| C `NS_ENUM` case 名在 Swift 中小写 | `HYAnalyticsActionTypeRealExposure` | `HYAnalyticsActionType.actionTypeRealExposure` | Swift 自动剥离枚举前缀并将剩余部分 camelCase；`HYAdvertReaderMonthlyPrompt` → `HYAdvertType.readerMonthlyPrompt` |
| Swift API 重命名（`NS_SWIFT_NAME`） | `HYBookReader.defaultReader()` | `HYBookReader.default()` | 项目大量 OC API 有 `NS_SWIFT_NAME` 重命名，编译错误提示中会给出正确名字 |
| OC 方法参数标签变化 | `qn_rect(font:maxWidth:maxHeight:)` | `qn_rect(with:maxWidth:maxHeight:)` | OC 方法桥接时参数标签可能变化，以编译错误建议为准 |

### 第 4 步：制定转换计划

基于分析结果，生成一份**文件级**的转换计划：

- **目标文件路径**：转换后的 Swift 文件应放在哪里？（SwiftModule 对应子目录，或同 OC 文件同级）
- **类名**：是否保留 HY 前缀？是否需要重命名以符合 Swift 命名习惯？
- **对外暴露**：哪些成员需要标注 `@objc` 以保证 OC 调用方不受影响？
- **依赖调整**：哪些 OC 头文件 import 需要改为 Swift module import？
- **分批策略**：若文件过大或依赖复杂，是否需要分批转换？先转换哪个部分？
- **风险点**：哪些转换可能引入行为差异？（如 OC 的 `nil` 消息发送 vs Swift 的 optional 解包）

将计划呈现给用户，**必须等待用户明确确认后**才能进入下一步。

### 第 5 步：输出测试用例清单

用户确认转换计划后、**执行转换前**，基于第 2 步的分析结果，生成一份**功能和业务逻辑的测试用例清单**，供用户在转换完成后手动验证。

清单需覆盖以下维度：

- **数据源逻辑**：所有条件分支的数据构建、过滤、排序规则
- **UI 渲染**：各控件的初始化参数、不同数据状态下的显示差异
- **主题切换**：日间/夜间模式下所有颜色、图片、样式的对照
- **交互行为**：按钮点击、手势响应、开关切换的完整响应链
- **回调处理**：所有 block/closure 回调的触发时机、参数正确性、执行顺序
- **动画效果**：入场/退场动画的 duration、曲线、起始/结束状态
- **公开方法**：所有 `@objc` 暴露给 OC 的方法的选择器名、参数、返回值
- **边界情况**：nil 数据、空列表、网络异常、快速连续点击、弱引用释放

每个测试用例包含：
- **测试场景描述**
- **预期行为**
- **重点验证项**（OC→Swift 桥接差异高风险点必须标注）

清单以表格形式输出，按功能模块分组。

### 第 6 步：执行转换

用户确认后，使用 `Write` / `Edit` 工具执行：

- **创建新 Swift 文件**：使用 `Write` 创建 `.swift` 文件，结构清晰、遵循规范模板。
- **修改原 OC 文件**（如需要）：若其他 OC 文件 import 了转换后的类，更新 import 路径。
- **保留注释**：原 OC 代码中的业务逻辑注释（解释"为什么"的）保留并转为中文注释。
- **不保留无用注释**：删除原 OC 中被注释掉的废弃代码块、过时的 TODO。

**转换完成后，对照规范做自查**：重新读取 `../docs/ios-ui-code-standard.md`，逐条检查：

- [ ] UI 元素是否使用 `private let` 声明（非 UICollectionView 不得使用 `lazy var`）
- [ ] 字体/颜色/圆角/对齐等样式是否全部在 `viewInit()` 中配置
- [ ] **OC lazy getter 中的行为绑定是否已迁移**：逐行检查每个 OC lazy getter，将 `addTarget:action:forControlEvents:`、`delegate` 赋值、`NSNotification` 监听、KVO 绑定等非 UI 逻辑，逐一移到 `viewInit()` 中
- [ ] 布局是否全部使用 SnapKit 在 `makeConstraints()` 中完成
- [ ] 是否使用了合规的颜色/字体/图片 API（见映射表 3.2-3.8）
- [ ] 屏幕常量是否使用 SwiftMacro 侧命名（`SCREEN_WIDTH` / `StatusBarHeight` 等）
- [ ] 分区注释是否使用 `// MARK: -` 格式

发现不符合规范的结构，**立即修正**，不等到编译验证阶段。修正时**必须确保功能等价**：例如将 `lazy var` 改为 `let` 时，原 closure 中的配置代码只能搬移到 `viewInit()`，不得增删或修改任何一行实际逻辑。

### 第 7 步：复查与自动修正

转换完成后，**自动执行**以下检查并修正问题，无需用户介入：

1. **`@objc` 标注完整性**：根据第 2 步分析的调用方列表，逐个对比每个 OC 可见的方法/属性是否标注了 `@objc`，必要时显式指定 ObjC 选择器名。
2. **Nullable 属性检查**：扫描所有对 OC 模型类属性的访问，若类型在 Swift 中为可选，补充 `?? 默认值` 或 `guard let` 处理。
3. **新增依赖检查**：若 Swift 代码引入了新的 Module import（如 `import HYReaderEngine`），确认 target 已有对应依赖配置。
4. **Bridging Header 依赖检查**：扫描 Swift 代码中引用的所有 OC 类，确认其头文件已在 `StaryReader-Bridging-Header.h` 中导入；若缺失则自动添加 `#import`。
5. **OC 调用方 Swift 头文件检查**：对于所有引用旧 `.h` 文件的 `.m` 调用方，移除旧 `#import` 后，确认是否已有 `#import "Dreame-Swift.h"`；若缺失则自动添加。
6. **`NS_REFINED_FOR_SWIFT` 属性检查**：扫描所有对 OC 属性的访问，若编译报 `function produces expected type; did you mean to call it with '()'`，补充 `()` 调用。
7. **`static` 常量检查**：OC 头文件中 `static NSString * const` 需其所在 `.h` 被 bridging header 直接或间接引入才能在 Swift 中使用（名称不变）。若编译报找不到，检查引入链路是否完整。

### 第 8 步：Xcode 工程集成

转换代码编写完成后，将新文件加入 Xcode 工程并移除旧文件引用，**自动执行全流程**直到编译通过：

1. **删除旧 OC 文件**：使用 `rm` 删除 `.h` 和 `.m` 文件，无需用户确认。
2. **更新 .pbxproj**：
   - 定位 `.pbxproj` 中旧 OC 文件的引用（PBXFileReference、PBXBuildFile、PBXGroup 等 section）
   - 移除旧文件的所有引用行（使用 `sed` 或 `Edit`）
   - 将新的 `.swift` 文件添加到对应 target 的 PBXFileReference、PBXBuildFile 和 PBXGroup 中，使用唯一的 UUID
3. **更新 OC 调用方**：检查所有引用旧 `.h` 文件的 `.m` 文件，移除 `#import "XXX.h"` 语句，并添加 `#import "Dreame-Swift.h"`（若尚未导入）。
4. **验证编译**：
   - 使用 `xcodebuild` 命令行工具执行增量编译：
     ```bash
     xcodebuild -workspace ReaderLight.xcworkspace -scheme Dreame -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -80
     ```
   - 若模拟器不可用，使用 `xcrun simctl list devices available` 查找可用设备名替换 `iPhone 16`
   - 若编译失败，分析错误并自主修正代码（如修正 `@objc` 选择器名、补充缺失的 import、修正类型不匹配等），然后重复编译验证直到通过
5. **确认 PBXGroup 位置**：新 Swift 文件应放入与旧 OC 文件相同的 PBXGroup 中，保持项目结构不变。

### 第 9 步：回写经验

编译通过后，**自动执行**以下经验沉淀，无需用户介入：

1. **更新 SKILL.md 映射表**：将本次转换中新发现的 OC→Swift 语法差异、方法签名变化、类型桥接陷阱等，补充到第 3 节对应的映射表和 3.9 陷阱表中。
2. **提取 UI 编码规范候选**：从转换后的 Swift 代码中识别出**可复用的通用 UI 模式**（如多按钮互斥选择、圆角+阴影组合、等宽横向排列等），列出候选清单供用户确认后，再写入 `../docs/ios-ui-code-standard.md`。

**第 2 点的执行约束**：
- 只列候选，**不直接写入 UI 规范文档**，必须等用户确认
- 候选必须是**通用模式**，而非特定业务的一次性代码
- 每个候选附带：模式名称、简要说明、出现在哪个文件

## 错误处理

- **LSP 不可用**：手动使用 `Grep` 搜索调用方，确认影响范围。
- **规范文档缺失**：提示用户安装/更新 figma-to-ios-uikit-code Skill。
- **转换目标过大**：建议分批转换，先处理独立的 Model/View 层，再处理依赖复杂的 Controller。
- **发现 OC 特有模式无法直接转换**：标记 `// TODO: OC→Swift 需手动处理 - [原因]`，并给出详细建议。

## 示例用户指令

- "把 HYUserProfileView.m 转成 Swift"
- "把这个 OC 类转成 Swift"
- "把 BookCity 模块的 Model 层转成 Swift"
- "转换 HYChapterInfoCell 到 SwiftModules 下"
