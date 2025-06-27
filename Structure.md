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

## Phase 2.1三端UI框架与开放性设计 ✅ **已完成** (2025-06-28)

基于Phase 2.0的双端架构成功，Phase 2.1实现了真正的三端UI框架和开放性模块生态设计：

### **核心服务增强** (`packages/core_services/`) ✅ `[completed - Phase 2.1]`
- **DisplayModeService**: 三端模式切换的核心服务 ✅
  - 支持三种显示模式：`desktop`（桌面）、`mobile`（移动）、`web`（Web）
  - 基于RxDart的响应式架构，实时模式状态流
  - SharedPreferences持久化存储，支持模式切换历史记录
  - 完整的事件系统：DisplayModeChangedEvent流式通知
  - 24个单元测试100%通过，覆盖所有核心功能

### **三端UI外壳系统** (`packages/ui_framework/`) ✅ `[completed - Phase 2.1]`
重构UI框架，实现真正的三端外壳架构：

#### **DisplayModeAwareShell** ✅ `[核心适配器]`
- **功能**: 三端动态切换的核心适配器，监听DisplayModeService状态
- **特性**: 
  - 实时响应模式切换事件，无缝切换Shell
  - 加载状态管理，确保服务初始化完成后再渲染
  - 模块列表统一管理，支持自定义和默认模块配置
  - locale变更回调支持，为国际化预留接口

#### **ModularMobileShell** ✅ `[移动端真正模块化]`
- **设计理念**: "每个模块 = 独立应用实例"，借鉴desktop_environment的模块独立性
- **核心特性**:
  - **模块生命周期管理**: _ModuleInstance类独立管理每个模块的运行状态
  - **系统级任务管理器**: 查看、切换、关闭运行中的模块实例
  - **模块启动器**: 类似AppDock的移动端适配，底部图标启动器
  - **系统状态栏**: 实时显示时间、活跃模块数、系统控制按钮
  - **移动端优化**: 全屏卡片布局、触控交互优化、流畅动画效果
- **交互模式**: 模块完全解耦，各自管理独立状态，真正体现原生模块化应用设计

#### **ResponsiveWebShell** ✅ `[Web端响应式]`
- **设计理念**: 多设备适配的Web响应式体验
- **核心特性**:
  - **自适应导航**: NavigationRail（大屏）↔ BottomNavigationBar（小屏）
  - **响应式网格**: 智能调整模块卡片列数（1-4列），适配多种屏幕尺寸
  - **面包屑导航**: Web端特有的路径导航和页面定位
  - **浏览器优化**: URL路由支持、SEO友好、键盘鼠标操作
- **屏幕适配**: 320px-1920px全范围响应，支持手机、平板、桌面、大屏

#### **SpatialOsShell集成** ✅ `[桌面端复用]`
- **架构设计**: 复用`desktop_environment`包的SpatialOsShell
- **理念澄清**: 
  - `ui_framework` = 可替换外壳层
  - `desktop_environment` = 共用内核层
- **集成方式**: DisplayModeAwareShell通过适配器模式集成SpatialOsShell

### **开放性设计与模块生态** ✅ `[completed - Phase 2.1]`
建立完整的Shell-Module交互契约和开发者规范：

#### **Shell-Module交互契约** (`docs/03_protocols_and_guides/shell_module_contract_v1.md`) ✅
- **核心通信协议**: ModuleContract接口、ShellContext环境
- **服务请求机制**: 窗口管理、通知系统、导航服务请求
- **事件响应系统**: Shell生命周期、主题变更、显示模式切换事件
- **数据交换规范**: ModuleDataPacket标准格式，类型安全的数据传递
- **安全权限模型**: 7种权限类型（UI、Navigation、Storage等）+ 权限管理器
- **版本兼容性**: 向前兼容策略，API版本控制
- **实现示例**: 完整的NotesModule和WindowManagementService代码示例

#### **模块API规范** (`docs/03_protocols_and_guides/module_api_specification_v1.md`) ✅
- **模块开发标准**: 目录结构、依赖管理、UI开发规范
- **数据管理规范**: RxDart状态管理、数据模型设计规范
- **国际化支持**: ARB文件配置、本地化集成标准
- **测试规范**: 契约兼容性测试、集成测试框架
- **部署分发**: 模块打包规范、质量检查清单
- **最佳实践**: 性能优化、错误处理、安全考虑指南

### **质量保障与测试体系** ✅ `[completed - Phase 2.1]`
建立了三端UI框架的完整测试覆盖：

#### **Widget测试套件** (`packages/ui_framework/test/`) ✅
- **display_mode_aware_shell_test.dart**: DisplayModeAwareShell核心适配器测试
  - 三端模式切换验证（Mobile→Web→Desktop→Mobile循环）
  - DisplayModeService Stream集成测试
  - 模块列表处理（自定义、默认、空模块）
  - 加载状态和错误处理验证

- **modular_mobile_shell_test.dart**: ModularMobileShell移动端测试
  - 模块生命周期管理（启动、切换、最小化、关闭）
  - 任务管理器功能验证
  - 系统状态栏和模块启动器测试
  - 模块状态保持和切换验证

- **responsive_web_shell_test.dart**: ResponsiveWebShell Web端测试
  - 多屏幕尺寸适配测试（320px-1920px）
  - NavigationRail/BottomNavigationBar自适应验证
  - 响应式网格布局测试
  - 方向变化和布局重构验证

- **three_terminal_integration_test.dart**: 三端框架集成测试
  - 端到端显示模式切换验证
  - 模块数据在模式切换间的维护测试
  - 快速模式切换稳定性和性能测试
  - 错误处理和边界条件验证

#### **测试结果与质量状态** ✅
- **DisplayModeService**: 24个单元测试100%通过
- **UI框架Widget测试**: 4个测试文件，覆盖三端切换逻辑
- **运行时Bug修复**: 解决DisplayModeService初始化问题
- **代码质量**: flutter analyze结果"No issues found!"

### **技术债务清理** ✅ `[completed - Phase 2.1]`
- **core_services测试修复**: 解决ServiceLocator GetIt类型推断错误，24/24测试通过
- **应用启动流程优化**: 在main.dart中正确初始化DisplayModeService
- **应用生命周期管理**: 添加服务清理和资源管理

### **架构理念与设计思想** ✅ `[Phase 2.1核心贡献]`
- **真正的三端差异化**: 
  - 桌面端：空间化OS工作台
  - 移动端：模块化独立应用生态
  - Web端：响应式兼容体验
- **开放性生态设计**: Shell-Module契约为未来插件生态奠定基础
- **可替换外壳架构**: ui_framework提供外壳抽象，支持未来新平台扩展
- **模块完全解耦**: 每个模块都是独立的"应用"，真正实现热插拔

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

### Phase 2.1完成状态 ✅ **三端UI框架与开放性设计完成** (2025-06-28)
- **三端UI外壳系统**: DisplayModeAwareShell + 三个Shell完整实现 (100%)
- **模式切换服务**: DisplayModeService响应式架构，24个测试通过 (100%)
- **开放性模块生态**: Shell-Module交互契约v1.0 + API规范文档完成 (100%)
- **Widget测试体系**: 4个测试文件，覆盖三端切换逻辑和组件功能 (100%)
- **技术债务清理**: ServiceLocator测试修复，DisplayModeService初始化Bug解决 (100%)
- **架构理念确立**: 真正三端差异化 + 可替换外壳 + 模块完全解耦 (100%)

### 后续阶段规划状态 📋
- **Phase 2.2**: 数据持久化(Drift)升级、业务功能CRUD完善
- **Phase 2.3**: 模块生态扩展、插件开发工具、跨端数据同步
- **Phase 3.0+**: AI集成、企业级特性、开放式插件市场

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

### Phase 2.1完成后依赖关系 ✅ **当前架构** (2025-06-28)
```
platform_app (主应用)
├── core_services (核心服务框架) ✨[新增DisplayModeService]
├── app_config (配置管理)  
├── app_routing (路由服务) ✨[集成DisplayModeService切换逻辑]
├── ui_framework (UI框架) ✨[重构三端Shell系统]
│   ├── core_services [依赖DisplayModeService]
│   ├── app_routing
│   └── desktop_environment [桌面端Shell集成]
├── desktop_environment (空间化OS桌面环境)
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

### Phase 2.1新增核心依赖说明
- **DisplayModeService**: core_services提供的三端模式切换服务
- **DisplayModeAwareShell**: ui_framework的核心适配器，依赖DisplayModeService
- **三端Shell系统**: ModularMobileShell、ResponsiveWebShell、SpatialOsShell的集成
- **Shell-Module契约**: docs/文档化的开放性接口，为未来模块生态奠定基础

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

*文档状态: 基于Phase 2.1完成成果全面更新 (2025-06-28)*
*Phase 2.1成果: 三端UI框架、DisplayModeService、Shell-Module契约、4个Widget测试*
*下次更新: Phase 2.2数据持久化升级与业务功能CRUD完善开始时* 