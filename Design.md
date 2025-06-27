# 设计文档 (Design Document)

## 系统架构设计

### 整体架构概览
桌宠AI助理平台采用"桌宠-总线"插件式架构，基于"包驱动Monorepo"技术栈构建。

#### 核心设计原则
- **模块化**: 每个功能模块作为独立包，物理隔离和逻辑独立
- **双端适配**: PC端"空间化OS"模式 + 移动端"沉浸式标准应用"模式
- **组合优于继承**: AppShell抽象基类通过组合使用不同的Renderer
- **先具体后抽象**: 从具体实现开始，积累经验后再抽象接口

### 双端UI框架架构

#### AppShell抽象基类
```dart
abstract class AppShell extends StatefulWidget {
  // 统一的Shell接口，支持模块加载、路由管理、状态同步
}
```

#### 平台特定实现
- **StandardAppShell**: 移动端沉浸式标准应用模式
- **SpatialOsShell**: PC端空间化OS桌面模式

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

## 三端架构重新设计 (Phase 2.0后期调整)

### 设计理念演进

基于Phase 2.0双端自适应UI框架的成功实现，我们重新思考了多端架构设计，形成更加系统性和符合原生体验的三端策略：

### 1. 桌面端 - "空间化OS"模式 ✅ **已完成**
- **平台**: Windows/macOS/Linux
- **特点**: WindowManager窗口管理、FloatingWindow浮窗、AppDock应用坞
- **设计哲学**: 桌面工作台隐喻，多窗口并行工作流
- **状态**: Phase 2.0完全实现

### 2. Web端 - "响应式兼容"模式 🎯 **重新定位**
- **原定位**: 移动端模拟
- **新定位**: 双端平衡的兼容模式，响应式布局
- **特点**: Material Design标准应用，BottomNavigation + Drawer
- **适用场景**: 浏览器访问、跨平台兼容、快速体验
- **技术**: StandardAppShell，自适应布局

### 3. 移动端 - "原生应用"模式 🆕 **全新设计**
- **平台**: Android/iOS
- **设计理念**: 原生应用模式，应用<->功能模块
- **核心概念**: 
  - 每个功能模块作为独立"应用"概念
  - 设置作为独立"APK"，包含system、application、个性化等
  - 符合手机原生交互习惯
- **状态**: 待Phase 2.1设计实现

### 架构优势

1. **差异化体验**: 三端各有特色，充分利用平台优势
2. **渐进式体验**: Web端作为兼容桥梁，移动端提供原生深度体验
3. **技术复用**: 底层业务逻辑和服务框架完全共享
4. **扩展性**: 为未来新平台预留架构空间

### 实施计划

- **Phase 2.1**: 设计并实现真正的移动端原生模式
- **Phase 2.2**: Web端响应式优化，移动端深度交互
- **Phase 2.3**: 三端功能对等，跨端数据同步

---

*最后更新: 2025-06-27 Sprint 2.0c Step 15*
*下次更新: 状态管理Phase升级或架构重大变更时*
