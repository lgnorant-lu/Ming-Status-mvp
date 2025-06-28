/*
---------------------------------------------------------------
File name:          notes_hub_widget.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        笔记中心Widget - 统一的事务管理界面，支持6种事务类型的完整管理功能，支持i18n
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 i18n集成 - 添加本地化支持，替换所有硬编码中文字符串;
    2025/06/26: Phase 1.5 模块修复 - 完全重写为符合新API的事务管理界面;
    2025/06/25: Initial creation - 笔记中心Widget基础实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:core_services/core_services.dart' hide ItemType, ItemStatus;
import 'package:ui_framework/ui_framework.dart';
import 'notes_hub_module.dart';
import 'l10n/notes_hub_l10n.dart';

/// 业务模块本地化数据类
class BusinessModuleLocalizations {
  final String notesHubTitle;
  final String workshopTitle;
  final String punchInTitle;
  final String note;
  final String todo;
  final String project;
  final String reminder;
  final String habit;
  final String goal;
  final String allTypes;
  final String total;
  final String active;
  final String completed;
  final String archived;
  final String searchHint;
  final String initializing;
  final String priorityUrgent;
  final String priorityHigh;
  final String priorityMedium;
  final String priorityLow;
  final String createNew;
  final String noItemsFound;
  final String createItemHint;
  final String confirmDelete;
  final String confirmDeleteMessage;
  final String itemDeleted;
  final String newItemCreated;
  final String save;
  final String cancel;
  final String edit;
  final String delete;
  final String title;
  final String content;
  final String priority;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String dueDate;
  final String tags;
  final String close;
  final String createFailed;
  final String deleteSuccess;
  final String deleteFailed;
  final String itemNotFound;

  const BusinessModuleLocalizations({
    required this.notesHubTitle,
    required this.workshopTitle,
    required this.punchInTitle,
    required this.note,
    required this.todo,
    required this.project,
    required this.reminder,
    required this.habit,
    required this.goal,
    required this.allTypes,
    required this.total,
    required this.active,
    required this.completed,
    required this.archived,
    required this.searchHint,
    required this.initializing,
    required this.priorityUrgent,
    required this.priorityHigh,
    required this.priorityMedium,
    required this.priorityLow,
    required this.createNew,
    required this.noItemsFound,
    required this.createItemHint,
    required this.confirmDelete,
    required this.confirmDeleteMessage,
    required this.itemDeleted,
    required this.newItemCreated,
    required this.save,
    required this.cancel,
    required this.edit,
    required this.delete,
    required this.title,
    required this.content,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.dueDate,
    required this.tags,
    required this.close,
    required this.createFailed,
    required this.deleteSuccess,
    required this.deleteFailed,
    required this.itemNotFound,
  });
}

/// 笔记中心Widget
class NotesHubWidget extends StatefulWidget {
  final BusinessModuleLocalizations? localizations;
  
  const NotesHubWidget({super.key, this.localizations});

  @override
  State<NotesHubWidget> createState() => _NotesHubWidgetState();
}

class _NotesHubWidgetState extends State<NotesHubWidget> 
    with TickerProviderStateMixin {
  late NotesHubModule _module;
  late TabController _tabController;
  bool _isInitialized = false;
  String _searchQuery = '';
  ItemType _selectedType = ItemType.note;

  /// 便捷翻译方法 - Phase 2.2 Sprint 2 使用分布式i18n系统
  String _t(String key) {
    return NotesHubL10n.t(key);
  }

  // 定义事务类型标签
  List<Map<String, dynamic>> get _typeTabs => [
    {'type': ItemType.note, 'label': _t('note'), 'icon': Icons.note},
    {'type': ItemType.todo, 'label': _t('todo'), 'icon': Icons.check_box},
    {'type': ItemType.project, 'label': _t('project'), 'icon': Icons.folder_open},
    {'type': ItemType.reminder, 'label': _t('reminder'), 'icon': Icons.alarm},
    {'type': ItemType.habit, 'label': _t('habit'), 'icon': Icons.loop},
    {'type': ItemType.goal, 'label': _t('goal'), 'icon': Icons.flag},
  ];

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: _typeTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    _initializeModule();
  }

  void _onTabChanged() {
    if (_tabController.index < _typeTabs.length) {
      setState(() {
        _selectedType = _typeTabs[_tabController.index]['type'] as ItemType;
      });
    }
  }

  Future<void> _initializeModule() async {
    try {
      _module = NotesHubModule();
      
      // 注册EventBus并初始化模块
      EventBus.register();
      await _module.initialize(EventBus.instance);
      await _module.boot();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('初始化笔记中心模块失败: $e');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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
              Text(_t('initializing')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCard(),
          Expanded(
            child: _buildTabView(),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_t('notes_hub_title')),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: _typeTabs.map((tab) => Tab(
          icon: Icon(tab['icon'] as IconData, size: 20),
          text: tab['label'] as String,
        )).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: _t('search_hint'),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = _module.getStatistics();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_t('total'), '${stats['totalItems']}', Icons.all_inbox, Colors.blue),
          _buildStatItem(_t('active'), '${stats['activeItems']}', Icons.play_circle, Colors.green),
          _buildStatItem(_t('completed'), '${stats['completedItems']}', Icons.check_circle, Colors.orange),
          _buildStatItem(_t('archived'), '${stats['archivedItems']}', Icons.archive, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: _typeTabs.map((tab) {
        final type = tab['type'] as ItemType;
        return _buildItemList(type);
      }).toList(),
    );
  }

  Widget _buildItemList(ItemType type) {
    List<NotesHubItem> items;
    
    if (_searchQuery.trim().isNotEmpty) {
      items = _module.searchItems(_searchQuery);
      items = items.where((item) => item.type == type).toList();
    } else {
      items = _module.getItemsByType(type);
    }

    if (items.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildItemCard(items[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(ItemType type) {
    final typeInfo = _typeTabs.firstWhere((tab) => tab['type'] == type);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            typeInfo['icon'] as IconData,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _t('no_items_found').replaceAll('{itemType}', typeInfo['label'] as String),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t('create_item_hint').replaceAll('{itemType}', typeInfo['label'] as String),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(NotesHubItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showItemDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriorityChip(item.priority),
                  const SizedBox(width: 8),
                  _buildStatusChip(item.status),
                ],
              ),
              if (item.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: item.tags.take(3).map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.blue.shade50,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(item.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (item.dueDate != null) ...[
                    const Spacer(),
                    Icon(Icons.event, size: 14, color: Colors.red.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(item.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(ItemPriority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case ItemPriority.urgent:
        color = Colors.red;
        label = _t('priority_urgent');
        break;
      case ItemPriority.high:
        color = Colors.orange;
        label = _t('priority_high');
        break;
      case ItemPriority.medium:
        color = Colors.blue;
        label = _t('priority_medium');
        break;
      case ItemPriority.low:
        color = Colors.grey;
        label = _t('priority_low');
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(ItemStatus status) {
    Color color = Colors.grey;
    String label = 'Unknown';
    IconData icon = Icons.help;
    
    switch (status) {
      case ItemStatus.active:
        color = Colors.green;
        label = _t('active');
        icon = Icons.play_circle;
        break;
      case ItemStatus.completed:
        color = Colors.blue;
        label = _t('completed');
        icon = Icons.check_circle;
        break;
      case ItemStatus.archived:
        color = Colors.grey;
        label = _t('archived');
        icon = Icons.archive;
        break;
      case ItemStatus.deleted:
        color = Colors.red;
        label = _t('delete');
        icon = Icons.delete;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    final typeInfo = _typeTabs.firstWhere((tab) => tab['type'] == _selectedType);
    
    return FloatingActionButton.extended(
      onPressed: () => _showCreateDialog(_selectedType),
      backgroundColor: const Color(0xFF667eea),
      icon: Icon(typeInfo['icon'] as IconData),
      label: Text(_t('create_new').replaceAll('{itemType}', typeInfo['label'] as String)),
    );
  }

  void _showCreateDialog(ItemType type) {
    final typeInfo = _typeTabs.firstWhere((tab) => tab['type'] == type);
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    ItemPriority selectedPriority = ItemPriority.medium;
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(typeInfo['icon'] as IconData, color: const Color(0xFF667eea)),
              const SizedBox(width: 8),
              Text(_t('create_new').replaceAll('{itemType}', typeInfo['label'] as String)),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: _t('title'),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: _t('content'),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ItemPriority>(
                        value: selectedPriority,
                        decoration: InputDecoration(
                          labelText: _t('priority'),
                          border: const OutlineInputBorder(),
                        ),
                        items: ItemPriority.values.map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(_getPriorityLabel(priority)),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedPriority = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setDialogState(() {
                              selectedDueDate = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.event),
                        label: Text(selectedDueDate != null 
                          ? _formatDateTime(selectedDueDate!) 
                          : _t('due_date')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_t('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  _createItem(
                    type: type,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    priority: selectedPriority,
                    dueDate: selectedDueDate,
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
              child: Text(_t('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(NotesHubItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.content.isNotEmpty) ...[
                Text('${_t('content')}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.content),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Text('${_t('priority')}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildPriorityChip(item.priority),
                  const SizedBox(width: 16),
                  Text('${_t('status')}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatusChip(item.status),
                ],
              ),
              const SizedBox(height: 16),
              Text('${_t('created_at')}: ${_formatDateTime(item.createdAt)}'),
              Text('${_t('updated_at')}: ${_formatDateTime(item.updatedAt)}'),
              if (item.dueDate != null) 
                Text('${_t('due_date')}: ${_formatDateTime(item.dueDate!)}'),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${_t('tags')}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: item.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue.shade50,
                  )).toList(),
                ),
              ],
            ],  
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_t('close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editItem(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea)),
            child: Text(_t('edit')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteItem(item.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(_t('delete')),
          ),
        ],
      ),
    );
  }

  void _createItem({
    required ItemType type,
    required String title,
    required String content,
    required ItemPriority priority,
    DateTime? dueDate,
  }) {
    try {
      _module.createItem(
        type: type,
        title: title,
        content: content,
        priority: priority,
        dueDate: dueDate,
      );
      
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('new_item_created').replaceAll('{itemType}', _getTypeLabel(type))),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_t('create_failed')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editItem(NotesHubItem item) {
    showDialog(
      context: context,
      builder: (context) => UniversalEditDialog(
        item: item,
        itemType: EditItemType.note, // NotesHub uses generic note type for all items
        onSave: (editedItem) {
          // Update the item using the module's updateItem method
          final success = _module.updateItem(
            editedItem.id,
            title: editedItem.title,
            content: editedItem.content,
            tags: editedItem.tags,
          );
          
          if (success) {
            setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('item_updated_success').replaceAll('{itemType}', _getTypeLabel(item.type))),
            backgroundColor: Colors.green,
          ),
        );
          } else {
                    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('edit_failed_item_not_found')),
            backgroundColor: Colors.red,
          ),
        );
          }
        },
      ),
    );
  }

  void _deleteItem(String itemId) {
    try {
      final success = _module.deleteItem(itemId);
      
      if (success) {
        setState(() {});
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('delete_success')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_t('delete_failed')}，${_t('item_not_found')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_t('delete_failed')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getTypeLabel(ItemType type) {
    return _typeTabs.firstWhere((tab) => tab['type'] == type)['label'] as String;
  }

  String _getPriorityLabel(ItemPriority priority) {
    switch (priority) {
      case ItemPriority.urgent:
        return _t('priority_urgent');
      case ItemPriority.high:
        return _t('priority_high');
      case ItemPriority.medium:
        return _t('priority_medium');
      case ItemPriority.low:
        return _t('priority_low');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return '${_t('today')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return _t('yesterday');
    } else if (difference.inDays < 7) {
      return _t('days_ago').replaceAll('{days}', '${difference.inDays}');
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
} 