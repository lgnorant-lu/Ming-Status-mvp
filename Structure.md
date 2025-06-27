# 项目结构

本文档基于**项目发展蓝图V2.0**，概述了 `桌宠AI助理平台` 项目的目录和文件结构。

## 项目概述

**桌宠AI助理平台** - 一个以"桌宠"为情感与交互核心的、高度模块化和可扩展的个人桌面AI助理平台。采用"桌宠-总线"插件式架构和"包驱动Monorepo"技术栈，基于Flutter构建。

**设计哲学**: "是桌宠，更是应用 (A Pet, and an App)" - 桌宠为平台注入生命和情感，强大的功能模块赋予平台真正的实用价值。

## 根目录结构

### 主应用 (`apps/platform_app/`) `[completed - Phase 1.6]`
- **功能**: 平台整合应用，聚合所有packages形成最终可执行应用
- **架构**: Flutter应用骨架，通过path依赖引用本地packages
- **主要文件**:
  - `lib/main.dart`: 应用入口，企业级启动器集成
  - `pubspec.yaml`: 主应用依赖配置，聚合所有本地packages
  - `test/`: 集成测试套件 (10个测试100%通过)
  - 平台特定目录: `android/`, `ios/`, `windows/`, `web/`, `linux/`, `macos/`

### 包驱动Monorepo (`packages/`) `[completed - Phase 1.5]`
基于"包驱动Monorepo"架构，每个核心服务和功能模块都是物理隔离的独立包：

#### **核心服务框架** (`packages/core_services/`) `[completed - Phase 1.6]`
- **功能**: 平台核心服务集合，提供企业级基础设施
- **核心服务**:
  - `LoggingService`: 分级日志系统，支持文件写入和轮转 `[completed]`
  - `ErrorHandlingService`: 全局错误处理和恢复机制 `[completed]`  
  - `PerformanceMonitoringService`: 性能监控和度量收集 `[completed]`
  - `ModuleManager`: 模块生命周期管理和依赖解析 `[completed]`
  - `NavigationService`: 统一导航和路由状态管理 `[completed]`
- **数据层**: Repository模式，IPersistenceRepository接口 + InMemoryRepository实现
- **安全服务**: 认证接口、加密服务
- **网络服务**: API客户端，JWT认证集成

#### **配置管理** (`packages/app_config/`) `[completed - Phase 1.5]`
- **功能**: 环境配置和特性开关系统
- **特性**: 多环境支持(dev/staging/prod)、特性开关、配置热更新

#### **路由服务** (`packages/app_routing/`) `[completed - Phase 1.5]`
- **功能**: 声明式路由和导航服务
- **技术**: go_router集成，深链接支持，路由状态管理

#### **UI框架** (`packages/ui_framework/`) `[completed - Phase 1.6]`
- **功能**: Material Design 3主题系统和UI框架
- **核心组件**:
  - `ThemeService`: 主题管理和切换 `[completed]`
  - `MainShell`: 主布局外壳，响应式导航 `[completed]`
  - `AdaptiveNavigationDrawer`: 自适应导航组件，完整本地化 `[completed]`
  - `PageContainer`: 页面容器和布局管理 `[completed]`

#### **业务模块** (Phase 1.5完成基础架构)

##### **事务管理中心** (`packages/notes_hub/`) `[基础完成]`
- **功能**: 笔记和任务管理的核心价值模块
- **状态**: 基础CRUD (Create/Read/Delete)，**编辑功能待Phase 2.1实现**
- **架构**: 标准化模块接口，事件驱动通信

##### **创意工坊** (`packages/workshop/`) `[基础完成]`
- **功能**: 创意项目管理和版本控制
- **状态**: 基础CRUD (Create/Read/Delete)，**编辑功能待Phase 2.1实现**
- **特色**: 8种创意类型支持，Material Design 3设计风格

##### **打卡模块** (`packages/punch_in/`) `[基础完成]`
- **功能**: 轻量级习惯追踪工具
- **状态**: 基础打卡功能完成，统计和报表待完善

### 项目文档 (根目录) `[completed - Phase 1.6]`
基于**项目发展蓝图V2.0**的完整文档体系：

#### **核心项目文档**
- `Context.md`: 项目即时记忆与上下文快照 `[已更新 - 反映蓝图V2.0]`
- `Plan.md`: 基于蓝图V2.0的宏观计划和里程碑 `[已更新]`
- `Structure.md`: 项目结构文档 (本文档) `[已更新]`
- `Thread.md`: 任务进程和决策记录 `[已更新]`
- `Design.md`: 系统架构设计和技术选型 `[需更新]`
- `Issues.md`: 问题追踪和技术债务管理 `[已更新 - 按Phase分类]`
- `Decisions.md`: 重要决策日志 `[已更新 - 新增DEC-003]`
- `Diagrams.md`: 绘图日志与索引 `[需完善]`
- `Log.md`: 变更日志索引 `[需更新]`

#### **API文档体系** (`Docs/APIs/`) `[completed - Phase 1.6]`
按服务类型分类的13个核心API文档，已核对确保与代码100%一致：
- `Core/`: ModuleManager, NavigationService, AppRouter等核心服务API
- `Models/`: BaseItem, UserModel数据模型API  
- `Repositories/`: IPersistenceRepository, InMemoryRepository数据访问API
- `Security/`: AuthService, EncryptionService安全服务API
- `Network/`: ApiClient网络服务API
- `UI/`: PetApp, MainShell, AdaptiveNavigationDrawer界面组件API

#### **任务管理** (`.tasks/`) `[ongoing]`
基于RIPER-5协议的任务定义和进度文件：
- `2025-06-24_1_phase0-foundation-mvp.md`: Phase 0架构奠基 `[completed]`
- `2025-06-25_1_phase1-platform-skeleton.md`: Phase 1平台骨架 `[completed]`
- `2025-06-26_2_phase1_5-pkg-refactor-and-i18n.md`: Phase 1.5架构升级 `[completed]`
- `2025-06-27_1_phase1_6-finalization.md`: Phase 1.6最终收尾 `[completed]`
- `2025-06-27_5_phase2-adaptive-ui-framework.md`: Phase 2.0双端UI框架 `[ready-to-start]`

#### **历史归档** (`Archived/`) `[completed - Phase 1.5]`
- `Phase0_Foundation/`: Phase 0奠基阶段文件归档，保留历史价值和演进记录

## Phase 2.0双端UI框架 ✅ **已完成** (2025-06-27)

基于项目蓝图V2.0，Phase 2.0已成功实现以下架构：

### **桌面环境包** (`packages/desktop_environment/`) ✅ `[completed - Phase 2.0]`
- **功能**: PC端"空间化OS"模式的完整实现
- **核心组件**:
  - `SpatialOsShell`: PC端外壳，桌面工作台隐喻 ✅
  - `WindowManager`: 窗口管理服务，浮窗生命周期控制 ✅
  - `FloatingWindow`: 可拖拽浮窗组件，支持8方向缩放和最小化/最大化 ✅
  - `AppDock`: 应用启动器，模块图标管理，60px高度保护区域 ✅
  - `DevPanel`: 开发者工具面板，实时窗口状态监控 ✅ **Sprint 2.0d新增**
  - `PerformanceMonitorPanel`: 专业级性能监控面板 ✅
- **交互特性**:
  - **智能边界约束**: 50px最小可见边距，15px精准吸附
  - **流畅拖拽体验**: ≥60fps性能基准
  - **专业窗口管理**: 支持Z-index管理，窗口焦点控制

### **双端外壳架构** ✅ `[completed - Phase 2.0]`
在UI框架基础上扩展完成：
- **StandardAppShell**: 移动端"沉浸式标准应用"模式 ✅
- **SpatialOsShell**: PC端"空间化OS"模式 ✅
- **自适应导航**: MainShell运行时响应式布局切换 ✅

### **性能监控增强** ✅ `[completed - Phase 2.0]`
扩展PerformanceMonitoringService：
- **窗口拖拽帧率监控**: 达成≥60fps基准 ✅
- **模块启动时间测量**: 优化至≤300ms目标 ✅  
- **实时数据可视化**: FPS趋势图，系统资源监控 ✅
- **开发者工具**: DevPanel提供窗口状态调试能力 ✅

## 技术状态总结

### Phase 1.6完成状态 ✅ **基础设施完成**
- **架构基础**: "桌宠-总线"插件式架构 + "包驱动Monorepo" (100%)
- **基础设施**: 企业级服务框架 (LoggingService文件写入等) (100%)
- **国际化**: 完整i18n体系，94个键值对双语支持 (100%)
- **代码质量**: flutter analyze零错误零警告，初期测试基础建立 (100%)
- **文档体系**: 13个API文档已修正，项目文档基于蓝图V2.0更新 (100%)

### Phase 2.0完成状态 ✅ **双端UI框架完成** (2025-06-27)
- **双端UI框架**: 完整实现，WindowManager+FloatingWindow+AppDock (100%)
- **性能基准**: 达成≥60fps窗口拖拽，≤300ms模块启动 (100%)
- **开发者工具**: DevPanel MVP，实时窗口状态监控 (100%)
- **分层测试架构**: 52个测试100%通过，≥80%核心服务覆盖率 (100%)
- **技术债务管理**: 11个债务追踪，偿还执行率57%，管理评级B- (100%)
- **前瞻性接口**: 状态管理演进路径，热插拔预留接口 (100%)

### 后续阶段规划状态 📋
- **Phase 2.1**: 业务功能CRUD完善、数据持久化(Drift)升级
- **Phase 2.2**: 系统应用功能、UI/UX精修、富文本支持
- **Phase 3.0+**: 生态系统、AI集成、插件开发框架

## 依赖关系图

### 当前包依赖关系 (Phase 1.6)
```
platform_app (主应用)
├── core_services (核心服务框架)
├── app_config (配置管理)  
├── app_routing (路由服务)
├── ui_framework (UI框架)
│   ├── core_services
│   └── app_routing
├── notes_hub (事务管理中心)
│   ├── core_services
│   └── ui_framework
├── workshop (创意工坊)
│   ├── core_services
│   └── ui_framework
└── punch_in (打卡模块)
    ├── core_services
    └── ui_framework
```

### Phase 2.0完成后依赖关系 ✅ **当前架构** (2025-06-27)
```
platform_app (主应用)
├── core_services (核心服务框架)
├── app_config (配置管理)  
├── app_routing (路由服务)
├── ui_framework (UI框架)
│   ├── core_services
│   └── app_routing
├── desktop_environment (✨新增 - 空间化OS桌面环境)
│   ├── core_services
│   ├── ui_framework
│   └── app_routing
├── notes_hub (事务管理中心)
│   ├── core_services
│   └── ui_framework
├── workshop (创意工坊)
│   ├── core_services
│   └── ui_framework
└── punch_in (打卡模块)
    ├── core_services
    └── ui_framework
```

## 质量保障

### Phase 1.6代码质量标准 ✅ **基础质量建立**
- **静态分析**: `flutter analyze` 零错误零警告
- **测试基础**: 初期测试框架建立，基础测试用例
- **包管理**: 每个package独立的pubspec.yaml和测试套件
- **文档同步**: API文档与代码实现100%一致

### Phase 2.0质量成果 ✅ **全面质量保障** (2025-06-27)
- **性能标准**: 达成窗口拖拽≥60fps，模块启动≤300ms ✅
- **分层测试架构**: 52个测试100%通过 ✅
  - platform_app: 18个测试 (端到端流程验证)
  - desktop_environment: 10个测试 (WindowManager核心功能)
  - ui_framework: 11个测试 (主题和UI组件)
  - app_config: 13个测试 (配置管理系统)
- **测试覆盖**: 超额完成≥80%核心服务覆盖率目标 ✅
- **技术债务管理**: 建立11个债务追踪，偿还计划和评级系统 ✅
- **开发者工具**: DevPanel和性能监控，开发调试体验提升 ✅

---

*文档状态: 基于Phase 2.0完成成果全面更新 (2025-06-27)*
*Phase 2.0成果: 双端UI框架、WindowManager系统、DevPanel工具、52个测试100%通过*
*下次更新: Phase 2.1核心功能完善与持久化开始时* 