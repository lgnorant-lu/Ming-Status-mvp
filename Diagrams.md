# 绘图日志与索引文档

本文档按类别组织项目中所有重要图表的索引，遵循v6协议的双链接要求。

## API文档体系索引 (Phase 1 - 2025-06-25建立)

### 核心服务 API文档 (Core)
- **AppRouter API** - `Docs/APIs/Core/AppRouter.md`
  - **描述**: 核心路由管理组件，基于go_router构建声明式路由系统
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 路由管理、导航控制、深链接处理

- **ModuleManager API** - `Docs/APIs/Core/ModuleManager.md`
  - **描述**: 模块管理服务，负责模块注册、生命周期管理和事件系统
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 模块管理、生命周期控制、动态加载

- **NavigationService API** - `Docs/APIs/Core/NavigationService.md`
  - **描述**: 导航服务，管理页面状态和模块间导航协调
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 导航状态管理、事件驱动导航、历史记录

### 数据模型 API文档 (Models)
- **BaseItem API** - `Docs/APIs/Models/BaseItem.md`
  - **描述**: 数据模型基础，定义业务实体的基础属性和序列化方法
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 数据模型基础、序列化支持、查询构建

- **UserModel API** - `Docs/APIs/Models/UserModel.md`
  - **描述**: 用户数据模型，包含认证相关字段和JWT token管理
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 用户身份管理、认证状态、权限控制

### 数据仓储 API文档 (Repositories)
- **IPersistenceRepository API** - `Docs/APIs/Repositories/IPersistenceRepository.md`
  - **描述**: 数据持久化核心接口，定义统一的数据访问契约
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 数据访问接口、CRUD操作、查询支持

- **InMemoryRepository API** - `Docs/APIs/Repositories/InMemoryRepository.md`
  - **描述**: 内存仓储实现，支持所有IPersistenceRepository接口功能
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 内存数据存储、测试支持、快速原型

### 安全服务 API文档 (Security)
- **AuthService API** - `Docs/APIs/Security/AuthService.md`
  - **描述**: 核心认证服务，负责用户身份验证、会话管理、权限控制
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 用户认证、会话管理、权限验证

- **EncryptionService API** - `Docs/APIs/Security/EncryptionService.md`
  - **描述**: 核心加密服务，提供数据加密、解密、哈希和密钥管理功能
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 数据加密、安全存储、密钥管理

### 网络服务 API文档 (Network)
- **ApiClient API** - `Docs/APIs/Network/ApiClient.md`
  - **描述**: 核心网络客户端服务，提供统一的HTTP/HTTPS通信接口
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 网络请求、认证管理、错误处理

### UI组件 API文档 (UI)
- **PetApp API** - `Docs/APIs/UI/PetApp.md`
  - **描述**: 主应用框架组件，负责应用初始化、配置管理、主题系统
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 应用初始化、全局配置、主题管理

- **MainShell API** - `Docs/APIs/UI/MainShell.md`
  - **描述**: 主布局壳组件，提供应用框架容器和响应式导航体验
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 布局框架、响应式导航、页面容器

- **AdaptiveNavigationDrawer API** - `Docs/APIs/UI/AdaptiveNavigationDrawer.md`
  - **描述**: 核心导航组件，提供响应式自适应导航体验
  - **版本**: v1.0 (2025-06-25)
  - **用途**: 自适应导航、模块菜单、状态指示

## 系统架构图表 (规划中)

### 架构图 (`Diagrams/Architecture/`) - 待创建
- **系统架构图**: 
  - **源文件**: `system_architecture.py` (Graphviz)
  - **输出**: `system_architecture.png`
  - **描述**: Phase 1完整的系统架构概览
  - **状态**: 规划中

- **分层架构图**: 
  - **源文件**: `layered_architecture.mmd` (Mermaid)
  - **输出**: `layered_architecture.png`
  - **描述**: 应用分层架构展示
  - **状态**: 规划中

### 模块图 (`Diagrams/Modules/`) - 待创建
- **模块依赖关系图**: 
  - **源文件**: `module_dependencies.py` (Graphviz)
  - **输出**: `module_dependencies.png`
  - **描述**: 模块间依赖关系和通信流程
  - **状态**: 规划中

### 流程图 (`Diagrams/Flowcharts/`) - 待创建
- **用户认证流程**: 
  - **源文件**: `auth_flow.mmd` (Mermaid)
  - **输出**: `auth_flow.png`
  - **描述**: 用户认证和权限验证流程
  - **状态**: 规划中

- **模块加载流程**: 
  - **源文件**: `module_loading_flow.py` (Graphviz)
  - **输出**: `module_loading_flow.png`
  - **描述**: 模块注册、初始化和生命周期管理流程
  - **状态**: 规划中

### 数据模型图 (`Diagrams/DataModels/`) - 待创建
- **实体关系模型**: 
  - **源文件**: `entity_relationship.mmd` (Mermaid)
  - **输出**: `entity_relationship.png`
  - **描述**: 核心数据模型和关系结构
  - **状态**: 规划中

## 文档维护说明

### API文档体系特点
- **完整性**: 覆盖Phase 1所有已实现的核心组件（13个API文档）
- **结构化**: 按服务类型分类组织（Core/Models/Repositories/Security/Network/UI）
- **标准化**: 每个文档包含概述、类型定义、接口规范、使用示例、最佳实践
- **版本化**: 记录创建日期和版本信息，支持演进跟踪

### 更新策略
- **同步更新**: API文档需要与代码实现保持同步
- **版本标记**: 重大更改时更新版本号和修改日期
- **正确性核对**: 定期核对文档与实际代码的一致性
- **扩展支持**: 新增组件时按照统一格式添加API文档

### 图表规划优先级
1. **高优先级**: 系统架构图、模块依赖关系图（支持开发和维护）
2. **中优先级**: 认证流程图、模块加载流程图（支持理解和调试）
3. **低优先级**: 实体关系模型图（支持数据设计）

---
*最后更新: 2025-06-25 - API文档体系建立*
