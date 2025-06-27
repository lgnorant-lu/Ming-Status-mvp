# 设计文档 (Design Document)

## 系统架构设计

### 整体架构概览
桌宠AI助理平台采用"桌宠-总线"插件式架构，基于"包驱动Monorepo"技术栈构建。

#### 核心设计原则 (Phase 2.1升级)
- **模块化**: 每个功能模块作为独立包，物理隔离和逻辑独立
- **三端差异化**: PC端"空间化OS"、移动端"模块化应用生态"、Web端"响应式兼容"
- **组合优于继承**: DisplayModeAwareShell通过适配器模式集成不同Shell
- **开放性设计**: Shell-Module交互契约支持未来插件生态扩展
- **可替换外壳**: ui_framework提供外壳抽象，desktop_environment提供内核实现

### 三端UI框架架构 (Phase 2.1完整实现)

#### DisplayModeAwareShell - 核心适配器
```dart
class DisplayModeAwareShell extends StatefulWidget {
  // 三端动态切换的核心适配器
  // 监听DisplayModeService状态，实时切换Shell
  // 统一的模块管理和locale支持
}
```

#### DisplayModeService - 模式切换服务
```dart
class DisplayModeService {
  // 三种显示模式：desktop, mobile, web
  // RxDart响应式架构，Stream状态流
  // SharedPreferences持久化存储
  // DisplayModeChangedEvent事件系统
}
```

#### 三端平台特定实现
- **ModularMobileShell**: 移动端模块化应用生态，每个模块作为独立应用实例
- **ResponsiveWebShell**: Web端响应式兼容模式，多设备适配
- **SpatialOsShell**: PC端空间化OS桌面模式（复用desktop_environment）

### Shell-Module交互契约系统

#### 核心接口设计
```dart
abstract class ModuleContract {
  // 模块与Shell的标准通信接口
  String get moduleId;
  String get displayName;
  ModuleCapabilities get capabilities;
  Future<void> initialize(ShellContext context);
  Widget buildWidget(BuildContext context);
  Future<void> onShellEvent(ShellEvent event);
}

abstract class ShellContext {
  // Shell为模块提供的环境和服务
  WindowManagementService get windowManager;
  NotificationService get notifications;
  NavigationService get navigation;
  ThemeService get theme;
}
```

#### 权限与安全模型
```dart
enum ModulePermission {
  ui,           // UI渲染权限
  navigation,   // 导航控制权限
  storage,      // 数据存储权限
  network,      // 网络访问权限
  filesystem,   // 文件系统访问权限
  notifications,// 通知权限
  system        // 系统级权限
}
```

### 包架构分层

#### 核心服务层 (Core Services)
- `core_services`: 基础设施服务(日志、错误处理、性能监控)
- `app_config`: 应用配置管理
- `app_routing`: 路由和导航

#### UI框架层 (UI Framework) 
- `ui_framework`: 主题服务、Shell组件、页面容器
- `desktop_environment`: 桌面环境(窗口管理、浮窗、AppDock)

#### 业务模块层 (Business Modules)
- `notes_hub`: 事务中心(笔记、待办、项目管理)
- `workshop`: 创意工坊(8种创意类型)
- `punch_in`: 打卡系统

## 🎯 状态管理演进路径 (State Management Evolution Path)

### Phase 1: 本地状态管理 (Local State) ✅ 当前阶段
**技术栈**: StatefulWidget + setState + InMemoryRepository

**特征**:
- 应用内临时状态管理
- 内存存储，重启后数据丢失
- 适用于原型验证和基础功能实现

**实现位置**:
- `packages/core_services/lib/services/repositories/in_memory_repository.dart`
- 各业务模块的Widget状态管理

**优势**: 简单快速，易于开发和调试
**局限**: 数据不持久，无法跨会话保存

### Phase 2: 持久化状态管理 (Persistence) 🎯 Phase 2.1目标
**技术栈**: StatefulWidget + setState + Drift(SQLite)

**演进计划**:
1. **实现IPersistenceRepository的Drift版本**
   ```dart
   class DriftRepository implements IPersistenceRepository {
     // SQLite数据库持久化实现
   }
   ```

2. **数据迁移策略**
   - 从InMemoryRepository平滑迁移到DriftRepository
   - 保持Repository接口不变，业务逻辑零修改
   - 版本控制和数据备份机制

3. **本地数据管理**
   - 笔记、待办、项目等核心数据持久化
   - 用户偏好设置、窗口状态保存
   - 离线优先的数据访问策略

**技术要点**:
- 数据库模式设计和迁移管理
- 事务支持和数据一致性保障
- 性能优化(索引、查询优化)

### Phase 3: 事件驱动状态管理 (EventBus) 🔮 Phase 2.2目标
**技术栈**: EventBus + RxDart + 持久化存储

**演进目标**:
1. **统一事件通信机制**
   ```dart
   class PlatformEventBus {
     // 跨模块异步事件通信
     // 状态变更通知和响应
   }
   ```

2. **解耦模块间依赖**
   - 模块通过事件而非直接调用通信
   - 支持模块的热插拔和动态加载
   - 事件溯源和状态重放能力

3. **响应式状态管理**
   - Stream-based状态流
   - 自动UI更新和状态同步
   - 复杂状态变更的精确控制

### Phase 4: 同步接口状态管理 (Sync Interface) 🚀 Phase 2.3+目标
**技术栈**: EventBus + 云端同步 + 冲突解决

**前瞻性功能**:
1. **多设备状态同步**
   - PC端和移动端数据实时同步
   - 离线优先，在线同步的Hybrid模式
   - 冲突检测和解决机制

2. **协作式状态管理**
   - 多用户共享工作空间
   - 实时协作编辑
   - 版本控制和变更追踪

3. **智能状态调度**
   - 基于使用模式的状态预加载
   - 智能缓存和内存管理
   - 性能自适应调优

### 状态管理接口设计

#### 统一Repository接口
```dart
abstract class IPersistenceRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
  Future<void> clear();
  
  // Phase 2.2: 事件驱动扩展
  Stream<List<T>> watchAll();
  Stream<T?> watchById(String id);
  
  // Phase 2.3+: 同步扩展
  Future<void> sync();
  Future<void> resolveConflict(T localItem, T remoteItem);
}
```

#### 状态管理服务接口
```dart
abstract class IStateManager {
  // Phase 2.1: 基础状态管理
  T getState<T>();
  void setState<T>(T state);
  
  // Phase 2.2: 事件驱动
  void emit<T>(StateEvent<T> event);
  Stream<T> watch<T>();
  
  // Phase 2.3+: 同步管理
  Future<void> syncState<T>();
  void enableAutoSync<T>(Duration interval);
}
```

### 迁移策略和风险控制

#### 渐进式升级原则
1. **向后兼容**: 每个Phase保持对前一Phase的API兼容
2. **逐步迁移**: 允许不同模块处于不同Phase
3. **降级支持**: 支持从高级Phase降级到基础Phase

#### 风险缓解措施
- **数据备份**: 每次Phase升级前强制数据备份
- **回滚机制**: 升级失败时自动回滚到前一状态
- **A/B测试**: 新Phase功能在隔离环境中验证
- **监控告警**: 状态管理性能和稳定性实时监控

## 技术选型与架构决策

### 核心技术栈
- **Flutter**: 跨平台UI框架，统一代码库
- **Dart**: 类型安全的编程语言，优秀的异步支持
- **get_it**: 依赖注入容器，支持Singleton和Factory模式
- **go_router**: 声明式路由，支持嵌套路由和Shell Route

### 窗口管理系统 (Desktop Environment)
- **WindowManager**: 具体类实现，管理窗口生命周期和Z-order
- **FloatingWindow**: 可拖拽可缩放的浮窗组件
- **AppDock**: 应用启动器，任务栏功能
- **SpatialOsShell**: 空间化OS桌面环境

### 安全架构
- **城堡防御模型**: 多层纵深防御策略
- **数据加密**: 敏感数据端到端加密
- **输入验证**: 所有用户输入严格校验
- **权限控制**: 基于角色的访问控制

## API设计规范

### RESTful API原则
- 使用标准HTTP动词(GET、POST、PUT、DELETE)
- 资源导向的URL设计
- 统一的错误响应格式
- 版本控制支持

### GraphQL扩展计划
为复杂查询和实时订阅提供GraphQL端点支持。

## 非功能性需求 (NFRs)

### 性能基准
- **窗口拖拽帧率**: ≥60fps (16ms响应时间)
- **模块启动时间**: ≤300ms (从点击到显示)
- **浮窗内存占用**: ≤50MB per窗口
- **数据库查询**: 90%的查询≤100ms

### 可用性目标
- **系统可用率**: ≥99.9% (月停机时间≤43分钟)
- **故障恢复时间**: ≤30秒
- **数据一致性**: 强一致性要求

### 扩展性设计
- **模块热插拔**: 支持运行时模块加载/卸载
- **水平扩展**: 支持多实例部署和负载均衡
- **垂直扩展**: 支持硬件资源的弹性伸缩

### 安全需求
- **数据保护**: 符合GDPR和本地数据保护法规
- **访问控制**: 基于角色和权限的细粒度控制
- **审计日志**: 完整的操作审计和安全事件记录

## 开发和部署

### 开发环境
- **Flutter SDK**: 3.x stable
- **Dart SDK**: 3.x stable  
- **IDE支持**: VS Code + Flutter插件、Android Studio

### 构建和测试
- **单元测试**: 核心服务包测试覆盖率≥80%
- **Widget测试**: UI组件完整测试覆盖
- **集成测试**: 端到端功能验证
- **性能测试**: NFRs基准验证

### 部署策略
- **桌面端**: Windows/macOS/Linux原生应用打包
- **移动端**: Android APK/iOS IPA应用商店分发
- **Web端**: 渐进式Web应用(PWA)部署

## 三端架构完整实现 (Phase 2.1完成)

### 设计理念实现

基于Phase 2.0双端自适应UI框架的成功实现，Phase 2.1完整实现了三端差异化架构，每端都有独特的交互体验和技术特色：

### 1. 桌面端 - "空间化OS"模式 ✅ **完全实现**
- **平台**: Windows/macOS/Linux
- **实现方案**: 复用`desktop_environment`包的SpatialOsShell
- **特点**: WindowManager窗口管理、FloatingWindow浮窗、AppDock应用坞
- **设计哲学**: 桌面工作台隐喻，多窗口并行工作流
- **架构角色**: desktop_environment作为共用内核层，ui_framework作为可替换外壳层
- **状态**: Phase 2.0-2.1持续完善

### 2. 移动端 - "模块化应用生态"模式 ✅ **全新实现**
- **平台**: Android/iOS
- **实现方案**: ModularMobileShell - 真正的模块化应用架构
- **核心特性**:
  - **每个模块 = 独立应用实例**: _ModuleInstance类管理生命周期
  - **系统级任务管理器**: 查看、切换、关闭运行中的模块
  - **模块启动器**: AppDock移动端适配，底部图标启动器
  - **系统状态栏**: 时间、活跃模块数、系统控制
- **设计哲学**: 原生应用生态模式，模块完全解耦独立运行
- **交互优势**: 全屏卡片、触控优化、流畅动画效果

### 3. Web端 - "响应式兼容"模式 ✅ **完整实现**
- **平台**: 现代Web浏览器
- **实现方案**: ResponsiveWebShell - 多设备响应式架构
- **核心特性**:
  - **自适应导航**: NavigationRail（大屏）↔ BottomNavigationBar（小屏）
  - **响应式网格**: 1-4列智能调整，适配320px-1920px屏幕
  - **面包屑导航**: Web端特有的路径导航和页面定位
  - **浏览器优化**: URL路由、SEO友好、键盘鼠标操作
- **设计哲学**: 兼容性优先，提供跨平台统一体验
- **适用场景**: 浏览器访问、快速体验、跨设备兼容

### DisplayModeService - 三端统一切换

```dart
enum DisplayMode {
  desktop,    // 桌面端：空间化OS
  mobile,     // 移动端：模块化应用生态  
  web,        // Web端：响应式兼容
}

class DisplayModeService {
  // 响应式状态流，实时切换Shell
  Stream<DisplayMode> get currentModeStream;
  Future<void> switchToMode(DisplayMode mode);
  Future<void> switchToNextMode(); // 循环切换
}
```

### 架构优势实现

1. **✅ 差异化体验**: 三端各有独特交互模式，充分发挥平台优势
2. **✅ 无缝切换**: DisplayModeAwareShell实现运行时动态切换
3. **✅ 技术复用**: 底层业务逻辑和服务框架完全共享，仅外壳差异化
4. **✅ 开放性扩展**: Shell-Module契约为未来插件生态奠定基础
5. **✅ 可替换架构**: ui_framework外壳层可独立演进，内核层保持稳定

### 测试与质量保障

- **DisplayModeService**: 24个单元测试，覆盖所有模式切换逻辑
- **三端Shell Widget测试**: 4个测试文件，验证各端特性和集成功能
- **端到端切换测试**: 验证Mobile→Web→Desktop循环切换稳定性
- **性能基准**: 模式切换响应时间、内存占用、渲染帧率监控

### 下一步演进计划

- **Phase 2.2**: 数据持久化升级，模块间状态同步优化
- **Phase 2.3**: 模块生态扩展，插件开发工具和市场
- **Phase 3.0**: AI智能模块推荐，企业级功能扩展

---

*最后更新: 2025-06-28 Phase 2.1 Step 9*
*Phase 2.1更新内容: 三端UI框架完整实现、DisplayModeService、Shell-Module交互契约*
*下次更新: Phase 2.2数据持久化升级或状态管理Phase演进时*
