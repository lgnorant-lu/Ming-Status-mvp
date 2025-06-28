/*
---------------------------------------------------------------
File name:          workshop_zh.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Workshop中文翻译 - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// Workshop中文翻译提供者
class WorkshopZhProvider extends BasePackageI18nProvider {
  WorkshopZhProvider() : super('workshop_zh') {
    addTranslations(SupportedLocale.chinese, _zhTranslations);
  }

  static const Map<String, String> _zhTranslations = {
    // 模块标题
    'workshop_title': '创意工坊',
    'module_name': '创意工坊',
    'module_description': '记录您的创意和灵感',
    
    // 基本操作
    'initializing': '正在初始化创意工坊...',
    'no_creative_projects': '暂无创意项目',
    'create_new_creative_project': '新建创意项目',
    'new_creative_idea': '新创意想法',
    'new_creative_description': '描述创意想法',
    'detailed_creative_content': '创意详细内容',
    'creative_project_created': '创意项目已创建',
    'creative_project_deleted': '创意项目已删除',
    
    // 界面元素
    'add_project': '添加项目',
    'project_list': '项目列表',
    'project_details': '项目详情',
    'edit_project': '编辑项目',
    'delete_project': '删除项目',
    'save_project': '保存项目',
    'cancel': '取消',
    'edit': '编辑',
    'delete': '删除',
    
    // 编辑和更新
    'creative_project_updated': '创意项目已更新',
    'edit_creative_project': '编辑创意项目',
    
    // 状态
    'draft': '草稿',
    'in_progress': '进行中',
    'completed': '已完成',
    'archived': '已归档',
    
    // 操作确认
    'confirm_delete': '确认删除',
    'delete_project_message': '确定要删除此创意项目吗？此操作无法撤销。',
    'yes': '是',
    'no': '否',
    
    // 表单字段
    'project_title': '项目标题',
    'project_description': '项目描述',
    'project_content': '项目内容',
    'project_tags': '项目标签',
    'created_date': '创建日期',
    'updated_date': '更新日期',
    
    // 错误消息
    'title_required': '标题为必填项',
    'description_required': '描述为必填项',
    'save_failed': '保存失败',
    'delete_failed': '删除失败',
    'load_failed': '加载失败',
  };
} 