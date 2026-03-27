# .claude

Reusable Claude Code agents, rules, commands, and skills.

## Install

按需安装，在项目目录下运行：

```bash
# 安装单个组件
curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- agent architect

# 安装多个组件
curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- agent architect agent go-developer command commitpush rule security

# 安装某类型的全部组件
curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- agent all

# 安装所有组件
curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- all
```

重复运行同一命令即可更新 — 已有的 symlink 会刷新，非 symlink 文件不会被覆盖。

## Agents

专用 AI 代理，各自聚焦特定领域，可通过 `agent` 类型安装。

| 名称 | 安装命令 | 说明 |
|------|---------|------|
| architect | `agent architect` | 系统架构设计专家，负责系统扩展性、可维护性和技术决策 |
| code-optimizer | `agent code-optimizer` | 代码优化设计顾问，分析技术栈和业务领域，提供设计改进建议 |
| go-developer | `agent go-developer` | Go 语言开发专家，负责编写、审查、重构和调试 Go 代码 |
| go-reviewer | `agent go-reviewer` | Go 代码审查专家，确保代码符合 Go 惯用法和最佳实践 |
| openapi-designer | `agent openapi-designer` | OpenAPI 3.0 规范设计师，按照项目约定设计 API 规范 |
| postgresql-designer | `agent postgresql-designer` | PostgreSQL 数据库设计师，按照项目约定设计数据库表 |
| tdd-guide | `agent tdd-guide` | 测试驱动开发（TDD）专家，指导遵循测试优先的开发方法论 |

## Commands

可复用的命令/工作流，通过 `command` 类型安装。

| 名称 | 安装命令 | 说明 |
|------|---------|------|
| commitpush | `command commitpush` | 自动检测、提交和推送所有子项目的变更 |

## Rules

自动加载的规则文件，规范 Claude 的行为方式，通过 `rule` 类型安装。

| 名称 | 安装命令 | 说明 |
|------|---------|------|
| agents | `rule agents` | 代理编排规则，定义如何并行执行独立任务的代理 |
| coding-style | `rule coding-style` | 编码风格检查清单，包括代码规范、文件大小、错误处理等 |
| git-workflow | `rule git-workflow` | Git 工作流程规范，定义提交消息格式和版本控制流程 |
| hooks | `rule hooks` | Hook 系统定义，包括工具使用前后和会话结束时的钩子 |
| performance | `rule performance` | 性能优化指南，管理上下文窗口和处理不同复杂度的任务 |
| security | `rule security` | 安全检查清单，包括密钥管理、输入验证和注入防护 |
| testing | `rule testing` | 测试要求规范，定义单元测试、集成测试、E2E 测试和覆盖率目标 |

## Skills

技能模块，提供特定领域的专业能力，通过 `skill` 类型安装。

| 名称 | 安装命令 | 说明 |
|------|---------|------|
| golang-testing | `skill golang-testing` | Go 测试模式技能，包括表驱动测试、子测试、基准测试和覆盖率分析 |
| open-skill-manager | `skill open-skill-manager` | 开源技能管理器，安装、缓存和链接开源 Claude Code 技能 |
