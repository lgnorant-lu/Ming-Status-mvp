/*
---------------------------------------------------------------
File name:          ui_zh.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        UI框架中文翻译 - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// UI框架中文翻译提供者
class UIFrameworkZhProvider extends BasePackageI18nProvider {
  UIFrameworkZhProvider() : super('ui_framework_zh') {
    addTranslations(SupportedLocale.chinese, _zhTranslations);
  }

  static const Map<String, String> _zhTranslations = {
    // EditDialog 相关翻译
    'edit_note': '编辑 笔记',
    'edit_todo': '编辑 待办',
    'edit_project': '编辑 项目',
    'edit_creative': '编辑 创意项目',
    'edit_punch_record': '编辑 打卡记录',
    
    'note_type': '笔记',
    'todo_type': '待办',
    'project_type': '项目',
    'creative_type': '创意项目',
    'punch_record_type': '打卡记录',
    
    'title_label': '标题',
    'title_hint': '请输入{type}标题',
    'title_empty_error': '标题不能为空',
    'title_min_length_error': '标题至少需要2个字符',
    
    'description_label': '描述',
    'description_hint': '简要描述这个{type}',
    
    'content_label': '内容',
    'content_hint': '输入详细内容...',
    'content_empty_error': '内容不能为空',
    
    'tags_label': '标签',
    'tags_hint': '输入标签并按回车添加',
    'add_tag': '添加标签',
    'no_tags': '暂无标签',
    
    'save_button': '保存',
    'cancel_button': '取消',
    'close_button': '关闭',
    
    'save_failed': '保存失败: {error}',
    
    // 通用UI文本
    'loading': '加载中...',
    'error': '错误',
    'success': '成功',
    'warning': '警告',
    'info': '信息',
    
    'confirm': '确认',
    'yes': '是',
    'no': '否',
    'ok': 'OK',
    
    'retry': '重试',
    'refresh': '刷新',
    'back': '返回',
    'next': '下一步',
    'previous': '上一步',
    
    'delete_confirm': '确认删除',
    'delete_confirm_message': '确定要删除"{name}"吗？此操作无法撤销。',
    
    // 表单验证
    'required_field': '此字段为必填项',
    'invalid_email': '邮箱格式不正确',
    'invalid_phone': '手机号格式不正确',
    'password_too_short': '密码长度不能少于{minLength}位',
    
    // 文件操作
    'file_upload': '上传文件',
    'file_download': '下载文件',
    'file_delete': '删除文件',
    'file_size_too_large': '文件大小超过限制',
    'file_format_not_supported': '不支持的文件格式',
    
    // 搜索和筛选
    'search': '搜索',
    'search_hint': '请输入搜索关键词',
    'filter': '筛选',
    'sort': '排序',
    'clear_filter': '清除筛选',
    
    // 分页
    'page': '第{current}页',
    'total_pages': '共{total}页',
    'items_per_page': '每页{count}项',
    'first_page': '首页',
    'last_page': '末页',
    
    // 时间和日期
    'today': '今天',
    'yesterday': '昨天',
    'tomorrow': '明天',
    'this_week': '本周',
    'this_month': '本月',
    'this_year': '今年',
    
    // 状态
    'active': '活跃',
    'inactive': '非活跃',
    'pending': '待处理',
    'completed': '已完成',
    'cancelled': '已取消',
    'archived': '已归档',
    
    // 移动端交互文本
    'minimize_to_background': '最小化到后台',
    'close_module': '关闭模块',
    'task_manager': '任务管理器',
    'toggle_system_bar': '切换系统栏',
    'running_modules_count': '运行中的模块 ({count})',
    'no_running_modules': '没有运行中的模块',
    'running_foreground': '前台运行',
    'running_background': '后台运行',
    'modular_mobile_platform': '模块化移动平台',
    'phase_description': 'Phase 2.1 - 每个模块都是独立应用',
    'tap_icon_to_launch': '点击底部图标启动模块',
    'module_launched': '已启动 {moduleName} 模块',
    'module_closed': '已关闭 {moduleName} 模块',
    
    // 编辑对话框
    'edit_item': '编辑项目',
    'item_title': '标题',
    'item_description': '描述',
    'item_tags': '标签',
    'save_changes': '保存更改',
    'cancel_edit': '取消',
    'title_required': '标题不能为空',
    'save_success': '保存成功',
    
    // 通用操作
    'save': '保存',
    'delete': '删除',
    'edit': '编辑',
    'back_button': '返回',
    'home_button': '首页',
    
    // 设置页面
    'settings_title': '设置',
    'language_settings': '语言设置',
    'current_language': '当前语言: {language}',
    'switch_to_next_language': '切换到下一种语言',
    'language_switched_to': '已切换到',
    'language_switch_error': '语言切换失败',
    
    // 主题设置
    'theme_settings': '主题设置',
    'theme_mode': '主题模式',
    'current_theme_mode': '当前主题: {mode}',
    'light_theme': '浅色主题',
    'dark_theme': '深色主题',
    'system_theme': '跟随系统',
    'color_scheme': '配色方案',
    'current_color_scheme': '当前配色: {scheme}',
    'material_purple': 'Material紫色',
    'blue_scheme': '蓝色',
    'green_scheme': '绿色',
    'orange_scheme': '橙色',
    'red_scheme': '红色',
    'pink_scheme': '粉色',
    'teal_scheme': '青色',
    'custom_scheme': '自定义',
    'font_settings': '字体设置',
    'font_family': '字体族',
    'font_scale': '字体缩放',
    'system_font': '系统默认',
    'pingfang_font': '苹方字体',
    'noto_font': '思源字体',
    'custom_font': '自定义字体',
    'animations_enabled': '启用动画',
    'theme_reset': '重置主题',
    'theme_reset_confirm': '确认重置主题设置？',
    'theme_reset_success': '主题已重置为默认设置',
    
    // 显示模式设置
    'display_mode_settings': '显示模式',
    'current_mode': '当前模式: {mode}',
    'switch_to_next_mode': '切换到下一种模式',
    
    // 模块管理
    'module_management_settings': '模块管理',
    'installed_modules': '已安装模块',
    'module_info': '模块信息',
    'module_enabled': '模块已启用',
    'module_disabled': '模块已禁用',
    'toggle_module': '切换模块状态',
    'module_details': '模块详情',
    'module_version': '版本',
    'module_author': '作者',
    'module_description': '描述',
    'core_module': '核心模块',
    'extension_module': '扩展模块',
    'module_cannot_disable': '核心模块无法禁用',
    
    // 数据管理
    'data_management': '数据管理',
    'data_export': '数据导出',
    'data_import': '数据导入',
    'data_backup': '数据备份',
    'data_restore': '数据恢复',
    'clear_cache': '清除缓存',
    'storage_usage': '存储使用情况',
    'total_items': '总项目数',
    'data_size': '数据大小',
    'cache_size': '缓存大小',
    'feature_coming_soon': '功能即将推出',
    
    // 导航
    'notes_hub_nav': '事务中心',
    'workshop_nav': '创意工坊',
    'punch_in_nav': '打卡',
    'notes_hub_description': '管理您的笔记和任务',
    'workshop_description': '记录您的创意和灵感',
    'punch_in_description': '记录您的考勤时间',
    
    // 缺失的翻译键 - 从运行日志中发现
    'settings_description': '个性化定制您的应用体验，管理语言、主题、显示模式和数据',
    'core_features': '核心功能',
    'builtin_modules': '内置模块',
    'extension_modules': '扩展模块',
    'system': '系统',
    'pet_assistant': '桌宠助手',
    'module_management': '模块管理',
    'module_management_dialog': '模块管理',
    'module_management_todo': '模块管理功能将在Phase 2.3中实现',
    'language_switch_failed': '语言切换失败',
    
    // Web端相关翻译
    'user_profile': '用户资料',
    'profile_feature_coming': '用户资料功能即将推出',
    'collapse_sidebar': '折叠侧边栏',
    'expand_sidebar': '展开侧边栏',
    'select_language': '选择语言',
    'toggle_language': '切换语言',
    'module_not_found': '模块未找到',
  };
} 