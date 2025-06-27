/*
---------------------------------------------------------------
File name:          workshop_widget.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        创意工坊Widget - 支持8种创意类型的创作管理界面
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 模块修复 - 完全重写以匹配新API;
    2025/06/25: Initial creation - 创意工坊Widget基础实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:core_services/core_services.dart';
import 'workshop_module.dart';

enum CreativeType { idea, design, prototype, art, writing, music, video, code }
enum ProjectStatus { draft, inProgress, published, archived }
enum Priority { low, medium, high, urgent }

class CreativeProject {
  final String id;
  final String title;
  final String description;
  final String content;
  final CreativeType type;
  final ProjectStatus status;
  final Priority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  CreativeProject({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.type,
    this.status = ProjectStatus.draft,
    this.priority = Priority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });
}

/// 创意工坊本地化字符串类
class WorkshopLocalizations {
  final String workshopTitle;
  final String initializing;
  final String total;
  final String active;
  final String completed;
  final String archived;
  final String noCreativeProjects;
  final String createNewCreativeProject;
  final String newCreativeIdea;
  final String newCreativeDescription;
  final String detailedCreativeContent;
  final String creativeProjectCreated;
  final String editFunctionTodo;
  final String creativeProjectDeleted;
  final String edit;
  final String delete;

  const WorkshopLocalizations({
    required this.workshopTitle,
    required this.initializing,
    required this.total,
    required this.active,
    required this.completed,
    required this.archived,
    required this.noCreativeProjects,
    required this.createNewCreativeProject,
    required this.newCreativeIdea,
    required this.newCreativeDescription,
    required this.detailedCreativeContent,
    required this.creativeProjectCreated,
    required this.editFunctionTodo,
    required this.creativeProjectDeleted,
    required this.edit,
    required this.delete,
  });
}

/// 创意工坊Widget
class WorkshopWidget extends StatefulWidget {
  final WorkshopLocalizations? localizations;
  
  const WorkshopWidget({super.key, this.localizations});

  @override
  State<WorkshopWidget> createState() => _WorkshopWidgetState();
}

class _WorkshopWidgetState extends State<WorkshopWidget> {
  late WorkshopModule _module;
  bool _isInitialized = false;

  // 默认中文本地化（回退方案）
  WorkshopLocalizations get localizations => widget.localizations ?? const WorkshopLocalizations(
    workshopTitle: '创意工坊',
    initializing: '正在初始化创意工坊...',
    total: '总计',
    active: '活跃',
    completed: '已完成',
    archived: '已归档',
    noCreativeProjects: '暂无创意项目',
    createNewCreativeProject: '点击右下角按钮创建新的创意项目',
    newCreativeIdea: '新创意想法',
    newCreativeDescription: '这是一个新的创意想法',
    detailedCreativeContent: '详细的创意描述...',
    creativeProjectCreated: '创意项目创建成功',
    editFunctionTodo: '编辑功能待实现',
    creativeProjectDeleted: '创意项目已删除',
    edit: '编辑',
    delete: '删除',
  );

  @override
  void initState() {
    super.initState();
    _initializeModule();
  }

  Future<void> _initializeModule() async {
    try {
      _module = WorkshopModule();
      
      // 注册EventBus并初始化模块
      EventBus.register();
      await _module.initialize(EventBus.instance);
      await _module.boot();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('初始化创意工坊模块失败: $e');
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _module.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(localizations.initializing),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(localizations.workshopTitle),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFff7f7f), Color(0xFFffa500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _toggleSearch(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final items = _module.getAllItems();
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(localizations.noCreativeProjects, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(localizations.createNewCreativeProject, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(item.type.toString().split('.').last),
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(item.status.toString().split('.').last),
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              onSelected: (value) => _handleItemAction(value, item),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(localizations.edit),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(localizations.delete),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNewItem() {
    _module.createItem(
      type: CreativeItemType.idea,
      title: localizations.newCreativeIdea,
      description: localizations.newCreativeDescription,
      content: localizations.detailedCreativeContent,
    );
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.creativeProjectCreated)),
    );
  }

  void _handleItemAction(String action, CreativeItem item) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.editFunctionTodo)),
        );
        break;
      case 'delete':
        _module.deleteItem(item.id);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.creativeProjectDeleted)),
        );
        break;
    }
  }

  void _toggleSearch() {
    // Implementation of _toggleSearch method
  }
} 