# 桌宠AI助理平台 (Pet AI Assistant Platform)

一个以"桌宠"为情感与交互核心的、高度模块化和可扩展的个人桌面AI助理平台。采用"桌宠-总线"插件式架构和"包驱动Monorepo"技术栈，基于Flutter构建。

**设计哲学**: "是桌宠，更是应用 (A Pet, and an App)" - 桌宠为平台注入生命和情感，强大的功能模块赋予平台真正的实用价值。

## 🎯 项目状态

- **Phase 1.6 完成**: 平台基础设施 ✅ (2025-06-27)
- **Phase 2.0 完成**: 双端自适应UI框架 ✅ (2025-06-27)
- **当前阶段**: Phase 2.1 - 核心功能完善与持久化 (准备中)
- **架构**: "桌宠-总线"插件式架构 + "包驱动Monorepo"
- **测试状态**: 52个测试 100% 通过，零错误零警告
- **平台支持**: Android/iOS、Windows/macOS/Linux、Web

## 🌟 核心特性

### 双端交互范式 ✅ **Phase 2.0完成**
- **PC端 (Windows/macOS/Linux)**: "空间化OS (Spatial OS)"模式
  - **WindowManager窗口管理系统**: 支持拖拽、缩放、最小化/最大化
  - **FloatingWindow浮窗组件**: ≥60fps流畅体验，智能边界约束
  - **AppDock应用程序坞**: 模块启动中心，支持≤300ms快速启动
  - **智能吸附系统**: 15px精准吸附，专业级窗口管理体验
  - **DevPanel开发者工具**: 实时窗口状态监控，性能数据可视化
  
- **移动端 (Android/iOS)**: "沉浸式标准应用"模式
  - **StandardAppShell标准外壳**: Material Design 3原生体验
  - **自适应导航系统**: 抽屉导航+模块切换无缝体验
  - **响应式布局**: 完全适配移动端交互范式

### 应用生态系统
- **核心系统应用**: 设置中心、虚拟文件系统、创意工坊
- **初始功能应用**: 事务管理中心、健康系统、打卡模块
- **长期AI集成**: RAG知识库、OCR模块、n8n自动化

## 🏗️ 技术架构

### 核心技术栈
- **框架**: Flutter 3.32.4 + Material Design 3
- **架构**: "桌宠-总线"插件式架构
- **路由**: go_router (声明式路由)
- **状态管理**: EventBus + RxDart + Streams
- **依赖注入**: get_it
- **数据层**: Repository模式 + 内存存储(规划升级Drift)
- **安全**: "城堡防御模型"(JWT认证 + AES加密 + 多层防护)

### 包驱动Monorepo架构 ✅ **Phase 2.0升级**
- **core_services**: 核心服务框架(Logging/Error/Performance/Module管理)
- **app_config**: 环境配置和特性开关系统
- **app_routing**: 声明式路由和导航服务
- **ui_framework**: Material Design 3主题和双端UI框架
- **desktop_environment**: ✨ **新增** - 空间化OS桌面环境
  - WindowManager窗口管理系统
  - FloatingWindow/AppDock/SpatialOsShell核心组件
  - DevPanel开发者工具和性能监控面板
- **notes_hub**: 事务管理中心模块
- **workshop**: 创意工坊模块
- **punch_in**: 打卡系统模块

### 模块化插件系统
每个功能模块都是物理隔离的独立包，通过事件总线进行解耦通信，支持:
- 完整的模块生命周期管理
- 依赖解析和拓扑排序
- 事件驱动的状态通知
- 模块热插拔能力(规划中)

## 🚀 快速开始

### 环境要求
- Flutter 3.32.4+
- Dart 3.5.4+

### 安装与运行
```bash
# 获取依赖
flutter pub get

# 运行应用
flutter run

# 运行测试
flutter test
```

## 📚 开发规范

### Git提交信息格式
本项目采用[约定式提交规范](https://www.conventionalcommits.org/)：

```
<type>(<scope>): <中文简短描述>

[可选的详细描述]
```

#### 常用类型 (type)
- `feat`: 新功能
- `fix`: Bug修复  
- `docs`: 文档更新
- `refactor`: 代码重构
- `test`: 测试相关
- `style`: 格式调整

#### 范围 (scope)
- `platform`: 平台架构、核心基础设施
- `core`: 核心服务
- `ui`: 界面组件
- `modules`: 业务模块
  - `notes_hub`: 事务中心模块
  - `punch_in`: 打卡模块
  - `workshop`: 创意工坊模块
- `test`: 测试
- `docs`: 文档

#### 示例
```bash
git commit -m "feat(platform): 实现双端自适应UI框架"
git commit -m "fix(modules/workshop): 修复创意项目编辑功能"
```

详细规范请参见 [Decisions.md](./Decisions.md#dec-001-git提交信息格式标准化)

## 📖 文档

### 核心文档
- [项目结构](./Structure.md) - 完整的项目文件组织
- [开发计划](./Plan.md) - 基于项目蓝图V2.0的路线图和里程碑
- [API文档](./Docs/APIs/) - 13个核心API文档
- [重要决策](./Decisions.md) - 技术选型和架构决策
- [问题追踪](./Issues.md) - 技术债务和问题管理

### 任务历史
- [Phase 0](./.tasks/2025-06-24_1_phase0-foundation-mvp.md) - 架构奠基 ✅
- [Phase 1](./.tasks/2025-06-25_1_phase1-platform-skeleton.md) - 平台骨架 ✅
- [Phase 1.5](./.tasks/2025-06-26_2_phase1_5-pkg-refactor-and-i18n.md) - 架构升级与i18n ✅
- [Phase 1.6](./.tasks/2025-06-27_1_phase1_6-finalization.md) - 最终收尾 ✅
- [Phase 2.0](./.tasks/2025-06-27_5_phase2-adaptive-ui-framework.md) - 双端UI框架 ✅ **已完成**

## 🧪 测试

### 测试覆盖 ✅ **Phase 2.0升级**
- **分层测试架构**: 单元测试(包级) + Widget测试(组件级) + 集成测试(应用级) + 性能基准测试(NFRs级)
- **platform_app应用层**: 18个测试 (端到端流程验证)
- **desktop_environment包**: 10个测试 (WindowManager核心功能)
- **ui_framework包**: 11个测试 (主题和UI组件)
- **app_config包**: 13个测试 (配置管理系统)
- **core_services基础**: 已有LoggingService和ServiceLocator测试
- **总计**: 52个测试用例，100%通过率，≥80%核心服务覆盖率

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/core/services/
flutter test test/integration/
```

### 代码质量
- **静态分析**: `flutter analyze` (零错误零警告)
- **格式化**: `dart format .`
- **测试覆盖率**: 核心功能100%覆盖

## 🔧 开发工具

- **代码分析**: `flutter analyze`
- **格式化**: `dart format .`
- **交互式审查**: `python final_review_gate.py`

## 📋 项目结构概览

```
pet_app/
├── apps/platform_app/     # 主应用(平台整合)
├── packages/              # 包驱动Monorepo
│   ├── core_services/     # 核心服务框架
│   ├── app_config/        # 配置管理
│   ├── app_routing/       # 路由服务
│   ├── ui_framework/      # UI框架
│   ├── desktop_environment/  # ✨ 空间化OS桌面环境(Phase 2.0新增)
│   ├── notes_hub/         # 事务中心模块
│   ├── workshop/          # 创意工坊模块
│   └── punch_in/          # 打卡模块
├── Docs/                  # API文档体系
│   └── APIs/              # 按服务分类的API文档
├── Archived/              # 历史版本归档
├── .tasks/               # 开发任务记录
├── Diagrams/             # 图表和可视化资源
├── Design.md             # ✨ 设计文档(Phase 2.0新增)
└── tech_debt_review_sprint_2_0d.md  # ✨ 技术债务审查报告
```

## 🎯 路线图 (基于项目蓝图V2.0)

### 🚀 Phase 2.0: 平台UI框架与核心体验构建 ✅ **已完成** (2025-06-27)
- ✅ Sprint 2.0a: 移动端验证与基础奠基
- ✅ Sprint 2.0b: 空间化桌面核心实现  
- ✅ Sprint 2.0c: 交互深化与服务集成
- ✅ Sprint 2.0d: 质量保障与开发者工具
- **核心成果**: 双端自适应UI框架、WindowManager系统、DevPanel工具、52个测试100%通过

### 🎯 Phase 2.1: 核心功能完善与持久化 (规划中)
- Drift数据库集成，替换InMemoryRepository
- 事务管理中心完整CRUD实现

### 🎨 Phase 2.2: 系统应用与体验增强 (规划中)
- 设置应用核心功能、健康系统插件
- UI/UX精修和动效打磨

### 🌟 Phase 3.0+: 生态系统与AI集成 (远期)
- 创意工坊应用商店、插件开发框架
- 后端服务、AI模块集成、开发者生态

## 🤝 贡献指南

1. 遵循约定式提交规范
2. 新功能需要包含对应测试
3. 更新相关API文档
4. 通过所有测试和代码检查
5. 参考项目发展蓝图V2.0进行功能规划

## 📄 许可证

This project is licensed under the MIT License.

---

**相关资源**:
- [Flutter官方文档](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [约定式提交规范](https://www.conventionalcommits.org/)
- [项目发展蓝图V2.0](./Plan.md)
