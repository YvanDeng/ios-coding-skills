# iOS Coding Skills

适用于 Claude Code 的 iOS 开发 Skill 集合，基于 StaryReader（Dreame）项目规范定制。

## 目录结构

```
ios-coding-skills/
├── docs/
│   └── ios-ui-code-standard.md    # 公共 UI 编码规范（两个 Skill 共同依赖）
├── oc-to-swift/
│   └── SKILL.md
├── figma-to-ios-uikit-code/
│   └── SKILL.md
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

### oc-to-swift

将 StaryReader 项目中的 Objective-C 代码安全地转换为 Swift。对 OC 源码进行深度分析（类继承关系、属性、协议、调用方），生成转换计划后再执行。确保语义等价且符合项目规范。

**核心能力：**
- 语义等价的 OC → Swift 转换
- 自动标注 `@objc` 保证 OC 调用方兼容
- Xcode 工程集成（pbxproj 自动更新）
- 编译验证与自动修复
- 经验回写机制（更新映射表与陷阱表）

## 安装

两个 Skill 共享 `docs/` 中的 UI 编码规范，安装时需将三部分全部复制到 Claude Code 的 skills 目录：

```bash
# 安装为用户级 Skill（所有项目可用）
cp -r oc-to-swift ~/.claude/skills/
cp -r figma-to-ios-uikit-code ~/.claude/skills/
cp -r docs ~/.claude/skills/

# 安装为项目级 Skill
cp -r oc-to-swift <项目路径>/.claude/skills/
cp -r figma-to-ios-uikit-code <项目路径>/.claude/skills/
cp -r docs <项目路径>/.claude/skills/
```

> 注意：`docs/` 目录不含 `SKILL.md`，不会被 Claude Code 识别为 Skill，仅作为共享资源目录使用。

## 依赖

- `figma-to-ios-uikit-code` 需要配置 Figma MCP Server
- 两个 Skill 均通过 `../docs/ios-ui-code-standard.md` 引用规范文档 — **`docs/` 目录必须与 Skill 目录同级放置**
- 两个 Skill 均针对 StaryReader（Dreame）项目规范定制

## 许可证

[MIT](LICENSE)
