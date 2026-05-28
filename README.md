# iOS Coding Skills

适用于 Claude Code 的 iOS 开发 Skill 集合，基于 StaryReader（Dreame）项目规范定制。

## 目录结构

```
ios-coding-skills/
├── .claude-plugin/
│   └── plugin.json                  # 插件清单（支持插件市场安装）
├── skills/
│   ├── figma-to-ios-uikit-code/
│   │   └── SKILL.md
│   └── oc-to-swift/
│       └── SKILL.md
├── docs/
│   └── ios-ui-code-standard.md      # 公共 UI 编码规范
├── install.sh
├── LICENSE
└── README.md
```

## Skill 介绍

### figma-to-ios-uikit-code

根据 Figma 设计稿自动生成 iOS UIKit 代码。通过分析设计稿与项目现有代码的关系，智能决定是全新生成、修改现有视图、还是建议重构。严格遵循《iOS UI 代码规范》。

**核心能力：**
- 自动解析 Figma 设计节点，提取 UI 组件规格
- 扫描项目现有代码，查找可匹配的视图
- 生成变更计划（新建 / 修改 / 部分新增 / 重构建议）
- 所有输出严格遵循项目 UI 编码规范

**使用示例：**

在 Claude Code 对话中输入以下指令即可触发：

```
把这个 Figma 设计稿应用一下：https://www.figma.com/design/xxx
```
```
按新设计稿更新个人中心
```
```
实现这个页面 https://www.figma.com/design/xxx
```
```
设置页改版了，帮我调整代码
```

Skill 会自动执行**分析→映射→决策→确认→执行**的完整流程，根据设计稿与现有代码的关系自主决定最合适的交付策略。

### oc-to-swift

将 StaryReader 项目中的 Objective-C 代码安全地转换为 Swift。对 OC 源码进行深度分析（类继承关系、属性、协议、调用方），生成转换计划后再执行。确保语义等价且符合项目规范。

**核心能力：**
- 语义等价的 OC → Swift 转换
- 自动标注 `@objc` 保证 OC 调用方兼容
- Xcode 工程集成（pbxproj 自动更新）
- 编译验证与自动修复
- 经验回写机制（更新映射表与陷阱表）

**使用示例：**

在 Claude Code 对话中输入以下指令即可触发：

```
把 HYUserProfileView.m 转成 Swift
```
```
把这个 OC 类转成 Swift
```
```
把 BookCity 模块的 Model 层转成 Swift
```
```
转换 HYChapterInfoCell 到 SwiftModules 下
```

Skill 会自动执行**读取规范→分析 OC 源码→建立映射表→制定转换计划→输出测试用例→执行转换→复查修正→Xcode 工程集成→回写经验**的完整流程。

## 安装

### 方式一：Claude Code 插件市场（推荐）

本仓库提供标准的 `.claude-plugin/plugin.json` 清单，支持通过 Claude Code 插件系统安装：

```bash
# 在 Claude Code 对话中直接运行
/plugin install YvanDeng/ios-coding-skills
```

也可以克隆仓库后本地安装：

```bash
git clone https://github.com/YvanDeng/ios-coding-skills.git
cd ios-coding-skills
./install.sh --plugin
```

安装后重启 Claude Code，Skill 即可自动发现并生效。

### 方式二：使用安装脚本

```bash
# 安装为用户级 Skill（所有项目可用）
./install.sh

# 安装为项目级 Skill
./install.sh -p /path/to/your-project

# 安装为 Claude Code 插件
./install.sh --plugin
```

运行脚本后即可在 Claude Code 对话中使用这些 Skill。

### 方式三：手动复制

```bash
# 安装为用户级 Skill（所有项目可用）
cp -r skills/oc-to-swift ~/.claude/skills/
cp -r skills/figma-to-ios-uikit-code ~/.claude/skills/
cp -r docs ~/.claude/skills/

# 修正规范文档引用路径（仓库中多一层 skills/，安装后需调整）
sed -i '' 's|../../docs/|../docs/|g' ~/.claude/skills/figma-to-ios-uikit-code/SKILL.md
sed -i '' 's|../../docs/|../docs/|g' ~/.claude/skills/oc-to-swift/SKILL.md

# 安装为项目级 Skill
cp -r skills/oc-to-swift <项目路径>/.claude/skills/
cp -r skills/figma-to-ios-uikit-code <项目路径>/.claude/skills/
cp -r docs <项目路径>/.claude/skills/

# 修正规范文档引用路径
sed -i '' 's|../../docs/|../docs/|g' <项目路径>/.claude/skills/figma-to-ios-uikit-code/SKILL.md
sed -i '' 's|../../docs/|../docs/|g' <项目路径>/.claude/skills/oc-to-swift/SKILL.md
```

> 注意：`docs/` 目录不含 `SKILL.md`，不会被 Claude Code 识别为 Skill，仅作为共享资源目录使用。

## 依赖

- `figma-to-ios-uikit-code` 需要配置 Figma MCP Server
- 两个 Skill 均通过 `../docs/ios-ui-code-standard.md` 引用规范文档 — **`docs/` 目录必须与 Skill 目录同级放置**
- 两个 Skill 均针对 StaryReader（Dreame）项目规范定制

## 许可证

[MIT](LICENSE)
