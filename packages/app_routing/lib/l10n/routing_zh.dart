/*
---------------------------------------------------------------
File name:          routing_zh.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        路由中文翻译 - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// 路由中文翻译提供者
class AppRoutingZhProvider extends BasePackageI18nProvider {
  AppRoutingZhProvider() : super('app_routing_zh') {
    addTranslations(SupportedLocale.chinese, _zhTranslations);
  }

  static const Map<String, String> _zhTranslations = {
    // 应用标题
    'app_title': '桌宠AI助理平台',
    
    // 页面标题
    'home_title': '首页',
    'notes_hub_title': '事务中心',
    'workshop_title': '创意工坊',
    'punch_in_title': '打卡',
    'settings_title': '设置',
    'about_title': '关于',
    
    // 导航标签
    'home_nav': '首页',
    'notes_hub_nav': '事务中心',
    'workshop_nav': '创意工坊',
    'punch_in_nav': '打卡',
    'settings_nav': '设置',
    'about_nav': '关于',
    
    // 设置页面 - 语言设置
    'language_settings': '语言设置',
    'current_language': '当前语言: {language}',
    'switch_to_next_language': '切换到下一种语言',
    'language_switched': '已切换到{language}',
    'language_switch_failed': '语言切换失败: {error}',
    'language_switched_to': '已切换到',
    'language_switch_error': '语言切换失败',
    
    // 设置页面 - 显示模式
    'display_mode_settings': '显示模式',
    'current_mode': '当前模式: {mode}',
    'switch_to_next_mode': '切换到下一种模式',
    
    // 设置页面 - 主题设置
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
    
    // 设置页面 - 模块管理
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
    
    // 设置页面 - 数据管理
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
    
    'app_settings': '应用设置',
    'app_settings_description': '主题设置、通知偏好、数据同步等功能\n将在后续版本中实现',
    
    // 显示模式
    'mobile_mode': '移动端模式',
    'desktop_mode': '桌面端模式',
    'web_mode': '网页端模式',
    'mobile_mode_desc': '适合手机和平板设备的触摸交互界面',
    'desktop_mode_desc': '适合PC和笔记本电脑的鼠标键盘操作界面',
    'web_mode_desc': '适合浏览器环境的响应式界面',
    
    // DisplayMode国际化
    'display_mode_mobile': '移动模式',
    'display_mode_desktop': '桌面模式',
    'display_mode_web': 'Web模式',
    'display_mode_mobile_desc': '移动端沉浸式应用，遵循原生Material Design体验',
    'display_mode_desktop_desc': 'PC端空间化桌面环境，模块以独立浮动窗口形式存在',
    'display_mode_web_desc': 'Web端响应式布局，自适应不同屏幕尺寸和浏览器环境',
    
    // 首页内容
    'welcome_message': '欢迎使用桌宠AI助理平台',
    'app_description': '基于"桌宠-总线"插件式架构的智能助理平台',
    'project_info': 'Phase 2.1 三端自适应架构',
    'project_features': '✅ ModularMobileShell (真正模块化移动端) 已实现\n✅ DisplayModeAwareShell (三端智能适配) 已集成\n✅ DisplayModeService (动态切换服务) 已启用',
    
    // 模块状态
    'module_status': '模块状态',
    'module_active': '模块: {active}/{total} 活跃',
    
    // 操作按钮
    'switch_button': '切换',
    'back_button': '返回',
    'home_button': '首页',
    
    // 模块描述
    'home_description': '应用概览和模块状态',
    'notes_hub_description': '管理您的笔记和任务',
    'workshop_description': '记录您的创意和灵感',
    'punch_in_description': '记录您的考勤时间',
    
    // 占位符页面
    'under_construction': '功能开发中',
    'placeholder_description': 'Phase 2.0 Sprint 2.0a\n模块占位符UI',
    'about_app_version': '桌宠AI助理平台 v2.1.0\nPhase 2.1 三端自适应UI框架',
    
    // 错误信息
    'page_not_found': '页面未找到',
    'navigation_error': '导航错误',
    'route_error': '路由错误',
    'return_home': '返回首页',
    'path_not_found': '路径未找到: {path}',
    
    // 系统信息
    'version_info': 'Phase 2.0 - v2.0.0',
    'copyright_info': '© 2025 桌宠AI助理平台\nPowered by Flutter',
    
    // 桌面环境相关
    'desktop_app_title': '桌宠AI助理平台',
    'desktop_phase_info': 'Phase 2.0 Sprint 2.0b - 空间化OS模式',
    'window_manager_status': 'WindowManager Status',
    'active_windows': '活跃窗口',
    'focused_window': '焦点窗口',
    'no_focus': '无',
    'minimized_windows': '最小化窗口',
    'settings_window_title': '设置',
    'settings_window_subtitle': '应用程序设置和配置',
    'settings_content_placeholder': '设置页面内容\n(将集成完整的设置界面)',
    'window_opened': '已启动 {moduleName} 模块窗口',
    'window_exists_error': '{moduleName} 窗口已存在或已达到窗口数量限制',
    'settings_window_opened': '已打开设置窗口',
    'settings_window_exists': '设置窗口已存在或已达到窗口数量限制',
    'dev_panel_status': 'DevPanel开发者工具',
    'data_monitor_status': '数据监控面板',
    
    // Web端界面翻译
    'collapse_sidebar': '收起侧栏',
    'expand_sidebar': '展开侧栏',
    'select_language': '选择语言',
    'search_placeholder': '搜索...',
    'toggle_language': '切换语言',
    'user_profile': '个人资料',
    'profile_feature_coming': '个人资料功能将在后续版本中实现',
    'module_not_found': '模块未找到',
  };
} 