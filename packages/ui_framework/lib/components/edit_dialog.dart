/*
---------------------------------------------------------------
File name:          edit_dialog.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Description:        统一编辑对话框组件 - 支持所有业务模块的编辑功能
---------------------------------------------------------------
Change History:
    2025/06/28: Phase 2.2 Sprint 1 - 创建统一编辑组件，解决编辑功能完全缺失问题;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import '../l10n/ui_l10n.dart';

/// 编辑项目类型枚举
enum EditItemType {
  note,        // 笔记
  todo,        // 待办
  project,     // 项目
  creative,    // 创意项目
  punchRecord, // 打卡记录
}

/// 编辑数据接口
abstract class EditableItem {
  String get id;
  String get title;
  String get description;
  String get content;
  List<String> get tags;
  
  /// 创建编辑后的副本
  EditableItem copyWith({
    String? title,
    String? description, 
    String? content,
    List<String>? tags,
  });
}

/// 统一编辑对话框组件
class UniversalEditDialog extends StatefulWidget {
  /// 被编辑的项目
  final EditableItem item;
  
  /// 项目类型
  final EditItemType itemType;
  
  /// 保存回调
  final Function(EditableItem editedItem) onSave;
  
  /// 对话框标题（可选，默认根据itemType生成）
  final String? dialogTitle;
  
  /// 是否显示标签编辑（默认true）
  final bool showTagsEditor;
  
  /// 是否显示描述字段（默认true）
  final bool showDescription;

  const UniversalEditDialog({
    super.key,
    required this.item,
    required this.itemType,
    required this.onSave,
    this.dialogTitle,
    this.showTagsEditor = true,
    this.showDescription = true,
  });

  @override
  State<UniversalEditDialog> createState() => _UniversalEditDialogState();
}

class _UniversalEditDialogState extends State<UniversalEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  late List<String> _tags;
  late TextEditingController _tagInputController;
  
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description);
    _contentController = TextEditingController(text: widget.item.content);
    _tags = List<String>.from(widget.item.tags);
    _tagInputController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context),
            Expanded(
              child: _buildDialogBody(context),
            ),
            _buildDialogActions(context),
          ],
        ),
      ),
    );
  }

  /// 构建对话框头部
  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getItemTypeIcon(),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.dialogTitle ?? _getDefaultTitle(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  /// 构建对话框主体
  Widget _buildDialogBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题输入
            _buildTitleField(),
            
            const SizedBox(height: 16),
            
            // 描述输入（可选）
            if (widget.showDescription) ...[
              _buildDescriptionField(),
              const SizedBox(height: 16),
            ],
            
            // 内容输入
            _buildContentField(),
            
            const SizedBox(height: 16),
            
            // 标签编辑（可选）
            if (widget.showTagsEditor) ...[
              _buildTagsSection(),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建标题输入字段
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: UIL10n.t('title_label'),
        hintText: UIL10n.t('title_hint').replaceAll('{type}', _getItemTypeName()),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.title),
      ),
      maxLength: 100,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return UIL10n.t('title_empty_error');
        }
        if (value.trim().length < 2) {
          return UIL10n.t('title_min_length_error');
        }
        return null;
      },
    );
  }

  /// 构建描述输入字段
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: UIL10n.t('description_label'),
        hintText: UIL10n.t('description_hint').replaceAll('{type}', _getItemTypeName()),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 2,
      maxLength: 200,
    );
  }

  /// 构建内容输入字段
  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: UIL10n.t('content_label'),
        hintText: UIL10n.t('content_hint'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.notes),
        alignLabelWithHint: true,
      ),
      maxLines: 6,
      minLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return UIL10n.t('content_empty_error');
        }
        return null;
      },
    );
  }

  /// 构建标签编辑区域
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UIL10n.t('tags_label'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        // 标签输入框
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagInputController,
                decoration: InputDecoration(
                  hintText: UIL10n.t('tags_hint'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.tag),
                ),
                onFieldSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addTag(_tagInputController.text),
              icon: const Icon(Icons.add),
              tooltip: UIL10n.t('add_tag'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 标签显示区域
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.label_outline,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  UIL10n.t('no_tags'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建标签芯片
  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeTag(tag),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }

  /// 构建对话框操作按钮
  Widget _buildDialogActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text(UIL10n.t('cancel_button')),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _saveChanges,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(UIL10n.t('save_button')),
          ),
        ],
      ),
    );
  }

  /// 添加标签
  void _addTag(String tagText) {
    final tag = tagText.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagInputController.clear();
    }
  }

  /// 移除标签
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  /// 保存更改
  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final editedItem = widget.item.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        content: _contentController.text.trim(),
        tags: _tags,
      );

      widget.onSave(editedItem);
      
      if (mounted) {
        Navigator.of(context).pop(editedItem);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UIL10n.t('save_failed').replaceAll('{error}', e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 获取项目类型图标
  IconData _getItemTypeIcon() {
    switch (widget.itemType) {
      case EditItemType.note:
        return Icons.note;
      case EditItemType.todo:
        return Icons.check_box;
      case EditItemType.project:
        return Icons.folder;
      case EditItemType.creative:
        return Icons.lightbulb;
      case EditItemType.punchRecord:
        return Icons.access_time;
    }
  }

  /// 获取默认标题
  String _getDefaultTitle() {
    switch (widget.itemType) {
      case EditItemType.note:
        return UIL10n.t('edit_note');
      case EditItemType.todo:
        return UIL10n.t('edit_todo');
      case EditItemType.project:
        return UIL10n.t('edit_project');
      case EditItemType.creative:
        return UIL10n.t('edit_creative');
      case EditItemType.punchRecord:
        return UIL10n.t('edit_punch_record');
    }
  }

  /// 获取项目类型名称
  String _getItemTypeName() {
    switch (widget.itemType) {
      case EditItemType.note:
        return UIL10n.t('note_type');
      case EditItemType.todo:
        return UIL10n.t('todo_type');
      case EditItemType.project:
        return UIL10n.t('project_type');
      case EditItemType.creative:
        return UIL10n.t('creative_type');
      case EditItemType.punchRecord:
        return UIL10n.t('punch_record_type');
    }
  }
}

/// 快速显示编辑对话框的辅助函数
Future<T?> showEditDialog<T extends EditableItem>({
  required BuildContext context,
  required T item,
  required EditItemType itemType,
  required Function(T editedItem) onSave,
  String? dialogTitle,
  bool showTagsEditor = true,
  bool showDescription = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) => UniversalEditDialog(
      item: item,
      itemType: itemType,
      onSave: (editedItem) => onSave(editedItem as T),
      dialogTitle: dialogTitle,
      showTagsEditor: showTagsEditor,
      showDescription: showDescription,
    ),
  );
} 