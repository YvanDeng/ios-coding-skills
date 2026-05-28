# iOS Coding Skills

Claude Code skills for iOS development, designed for StaryReader project conventions.

## Skills

### figma-to-ios-uikit-code

Convert Figma designs to iOS UIKit code. Intelligently decides whether to generate new code, modify existing views, or suggest refactoring by analyzing the relationship between Figma designs and existing project code. Strictly follows the iOS UI Code Standard.

**Key capabilities:**
- Auto-analyze Figma design nodes and extract UI component specs
- Scan existing project code to find matching views
- Generate change plans (new / modify / partial / refactor)
- All output strictly follows project UI code conventions

### oc-to-swift

Convert Objective-C code to Swift in the StaryReader project. Performs deep analysis of OC source code including class hierarchy, properties, protocols, and callers before producing a conversion plan. Ensures semantic equivalence and project convention compliance.

**Key capabilities:**
- Semantic-preserving OC→Swift conversion
- Automatic @objc annotation for OC callers
- Xcode project integration (pbxproj updates)
- Compile verification and auto-fix
- Experience feedback loop (updates mapping tables)

## Installation

Copy the desired skill folder to your Claude Code skills directory:

```bash
# For user-level skills (available across all projects)
cp -r oc-to-swift ~/.claude/skills/
cp -r figma-to-ios-uikit-code ~/.claude/skills/

# For project-level skills
cp -r oc-to-swift <project>/.claude/skills/
cp -r figma-to-ios-uikit-code <project>/.claude/skills/
```

## Dependencies

- `figma-to-ios-uikit-code` requires Figma MCP server configured
- `oc-to-swift` depends on `figma-to-ios-uikit-code/docs/ios-ui-code-standard.md`
- Both skills are tailored for the StaryReader (Dreame) project conventions
