/*
---------------------------------------------------------------
File name:          notes_hub_zh.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Notes Hub中文翻译 - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// Notes Hub中文翻译提供者
class NotesHubZhProvider extends BasePackageI18nProvider {
  NotesHubZhProvider() : super('notes_hub_zh') {
    addTranslations(SupportedLocale.chinese, _zhTranslations);
  }

  static const Map<String, String> _zhTranslations = {
    // 模块标题
    'notes_hub_title': '事务中心',
    'module_name': '事务中心',
    'module_description': '管理您的笔记和任务',
    
    // 基本操作
    'search_hint': '搜索事务...',
    'initializing': '正在初始化事务管理中心...',
    'create_new': '新建',
    'edit': '编辑',
    'delete': '删除',
    'save': '保存',
    'cancel': '取消',
    'close': '关闭',
    
    // 项目类型
    'note': '笔记',
    'todo': '待办',
    'project': '项目',
    'reminder': '提醒',
    'habit': '习惯',
    'goal': '目标',
    'all_types': '全部类型',
    
    // 状态
    'total': '总计',
    'active': '活跃',
    'completed': '已完成',
    'archived': '已归档',
    
    // 优先级
    'priority': '优先级',
    'priority_urgent': '紧急',
    'priority_high': '高',
    'priority_medium': '中',
    'priority_low': '低',
    
    // 字段
    'title': '标题',
    'content': '内容',
    'status': '状态',
    'created_at': '创建时间',
    'updated_at': '更新时间',
    'due_date': '截止日期',
    'tags': '标签',
    
    // 创建和编辑
    'create_new_item': '新建{itemType}',
    'edit_item': '编辑{itemType}',
    'item_created': '已创建新的{itemType}',
    'item_updated': '已更新{itemType}',
    'item_deleted': '已删除{itemType}',
    
    // 空状态
    'no_items_found': '暂无{itemType}',
    'create_item_hint': '点击 + 按钮创建{itemType}',
    
    // 确认对话框
    'confirm_delete': '确认删除',
    'confirm_delete_message': '确定要删除"{itemName}"吗？此操作无法撤销。',
    
    // 错误和成功消息
    'create_failed': '创建失败',
    'update_failed': '更新失败',
    'delete_failed': '删除失败',
    'item_not_found': '项目不存在',
    'operation_success': '操作成功',
    'item_updated_success': '{itemType} 编辑成功',
    'edit_failed_item_not_found': '编辑失败：事务不存在',
    
    // 时间格式化
    'today': '今天',
    'yesterday': '昨天',
    'days_ago': '{days}天前',
    
    // 界面元素
    'welcome_title': '欢迎使用笔记中心',
    'welcome_description': '这里是您的个人事务管理中心，支持笔记、待办、项目等多种类型的事务管理。',
    'active_badge': '活跃',
    'new_item_button': '新建笔记',
  };
} 