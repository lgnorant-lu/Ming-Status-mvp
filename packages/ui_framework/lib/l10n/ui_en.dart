/*
---------------------------------------------------------------
File name:          ui_en.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        UI framework English translations - Phase 2.2 Sprint 2 distributed i18n system
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// UI framework English translation provider
class UIFrameworkEnProvider extends BasePackageI18nProvider {
  UIFrameworkEnProvider() : super('ui_framework_en') {
    addTranslations(SupportedLocale.english, _enTranslations);
  }

  static const Map<String, String> _enTranslations = {
    // EditDialog related translations
    'edit_note': 'Edit Note',
    'edit_todo': 'Edit Todo',
    'edit_project': 'Edit Project',
    'edit_creative': 'Edit Creative Project',
    'edit_punch_record': 'Edit Punch Record',
    
    'note_type': 'Note',
    'todo_type': 'Todo',
    'project_type': 'Project',
    'creative_type': 'Creative Project',
    'punch_record_type': 'Punch Record',
    
    'title_label': 'Title',
    'title_hint': 'Please enter {type} title',
    'title_empty_error': 'Title cannot be empty',
    'title_min_length_error': 'Title must be at least 2 characters',
    
    'description_label': 'Description',
    'description_hint': 'Brief description of this {type}',
    
    'content_label': 'Content',
    'content_hint': 'Enter detailed content...',
    'content_empty_error': 'Content cannot be empty',
    
    'tags_label': 'Tags',
    'tags_hint': 'Enter tag and press enter to add',
    'add_tag': 'Add Tag',
    'no_tags': 'No tags',
    
    'save_button': 'Save',
    'cancel_button': 'Cancel',
    'close_button': 'Close',
    
    'save_failed': 'Save failed: {error}',
    
    // Common UI text
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Info',
    
    'confirm': 'Confirm',
    'yes': 'Yes',
    'no': 'No',
    'ok': 'OK',
    
    'retry': 'Retry',
    'refresh': 'Refresh',
    'back': 'Back',
    'next': 'Next',
    'previous': 'Previous',
    
    'delete_confirm': 'Confirm Delete',
    'delete_confirm_message': 'Are you sure you want to delete "{name}"? This action cannot be undone.',
    
    // Form validation
    'required_field': 'This field is required',
    'invalid_email': 'Invalid email format',
    'invalid_phone': 'Invalid phone number format',
    'password_too_short': 'Password must be at least {minLength} characters',
    
    // File operations
    'file_upload': 'Upload File',
    'file_download': 'Download File',
    'file_delete': 'Delete File',
    'file_size_too_large': 'File size exceeds limit',
    'file_format_not_supported': 'Unsupported file format',
    
    // Search and filter
    'search': 'Search',
    'search_hint': 'Enter search keywords',
    'filter': 'Filter',
    'sort': 'Sort',
    'clear_filter': 'Clear Filter',
    
    // Pagination
    'page': 'Page {current}',
    'total_pages': '{total} Pages Total',
    'items_per_page': '{count} items per page',
    'first_page': 'First',
    'last_page': 'Last',
    
    // Time and date
    'today': 'Today',
    'yesterday': 'Yesterday',
    'tomorrow': 'Tomorrow',
    'this_week': 'This Week',
    'this_month': 'This Month',
    'this_year': 'This Year',
    
    // Status
    'active': 'Active',
    'inactive': 'Inactive',
    'pending': 'Pending',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'archived': 'Archived',
    
    // Mobile interaction text
    'minimize_to_background': 'Minimize to Background',
    'close_module': 'Close Module',
    'task_manager': 'Task Manager',
    'toggle_system_bar': 'Toggle System Bar',
    'running_modules_count': 'Running Modules ({count})',
    'no_running_modules': 'No Running Modules',
    'running_foreground': 'Running in Foreground',
    'running_background': 'Running in Background',
    'modular_mobile_platform': 'Modular Mobile Platform',
    'phase_description': 'Phase 2.1 - Each Module is Independent App',
    'tap_icon_to_launch': 'Tap Bottom Icons to Launch Modules',
    'module_launched': 'Launched {moduleName} Module',
    'module_closed': 'Closed {moduleName} Module',
    
    // Settings page
    'settings_title': 'Settings',
    'language_settings': 'Language Settings',
    'current_language': 'Current Language: {language}',
    'switch_to_next_language': 'Switch to Next Language',
    'language_switched_to': 'Switched to ',
    'language_switch_error': 'Language switch failed',
    
    // Theme settings
    'theme_settings': 'Theme Settings',
    'theme_mode': 'Theme Mode',
    'current_theme_mode': 'Current Theme: {mode}',
    'light_theme': 'Light Theme',
    'dark_theme': 'Dark Theme',
    'system_theme': 'Follow System',
    'color_scheme': 'Color Scheme',
    'current_color_scheme': 'Current Color: {scheme}',
    'material_purple': 'Material Purple',
    'blue_scheme': 'Blue',
    'green_scheme': 'Green',
    'orange_scheme': 'Orange',
    'red_scheme': 'Red',
    'pink_scheme': 'Pink',
    'teal_scheme': 'Teal',
    'custom_scheme': 'Custom',
    'font_settings': 'Font Settings',
    'font_family': 'Font Family',
    'font_scale': 'Font Scale',
    'system_font': 'System Default',
    'pingfang_font': 'PingFang Font',
    'noto_font': 'Noto Font',
    'custom_font': 'Custom Font',
    'animations_enabled': 'Enable Animations',
    'theme_reset': 'Reset Theme',
    'theme_reset_confirm': 'Confirm reset theme settings?',
    'theme_reset_success': 'Theme has been reset to default',
    
    // Display mode settings
    'display_mode_settings': 'Display Mode',
    'current_mode': 'Current Mode: {mode}',
    'switch_to_next_mode': 'Switch to Next Mode',
    
    // Module management
    'module_management_settings': 'Module Management',
    'installed_modules': 'Installed Modules',
    'module_info': 'Module Info',
    'module_enabled': 'Module Enabled',
    'module_disabled': 'Module Disabled',
    'toggle_module': 'Toggle Module Status',
    'module_details': 'Module Details',
    'module_version': 'Version',
    'module_author': 'Author',
    'module_description': 'Description',
    'core_module': 'Core Module',
    'extension_module': 'Extension Module',
    'module_cannot_disable': 'Core modules cannot be disabled',
    
    // Data management
    'data_management': 'Data Management',
    'data_export': 'Export Data',
    'data_import': 'Import Data',
    'data_backup': 'Backup Data',
    'data_restore': 'Restore Data',
    'clear_cache': 'Clear Cache',
    'storage_usage': 'Storage Usage',
    'total_items': 'Total Items',
    'data_size': 'Data Size',
    'cache_size': 'Cache Size',
    'feature_coming_soon': 'Feature Coming Soon',
    
    // Navigation
    'notes_hub_nav': 'Notes Hub',
    'workshop_nav': 'Workshop',
    'punch_in_nav': 'Punch In',
    'notes_hub_description': 'Manage your notes and tasks',
    'workshop_description': 'Record your creative ideas and inspirations',
    'punch_in_description': 'Record your attendance time',
    
    // Common operations  
    'save': 'Save',
    'edit': 'Edit',
    'delete': 'Delete',
    'back_button': 'Back',
    'home_button': 'Home',
    
    // 缺失的翻译键 - 从运行日志中发现
    'settings_description': 'Personalize your app experience, manage language, theme, display mode and data',
    'core_features': 'Core Features',
    'builtin_modules': 'Built-in Modules',
    'extension_modules': 'Extension Modules',
    'system': 'System',
    'pet_assistant': 'Pet Assistant',
    'module_management': 'Module Management',
    'module_management_dialog': 'Module Management',
    'module_management_todo': 'Module management functionality will be implemented in Phase 2.3',
    'language_switch_failed': 'Language switch failed',
    
    // Web端相关翻译
    'user_profile': 'User Profile',
    'profile_feature_coming': 'User profile functionality coming soon',
    'collapse_sidebar': 'Collapse Sidebar',
    'expand_sidebar': 'Expand Sidebar',
    'select_language': 'Select Language',
    'toggle_language': 'Toggle Language',
    'module_not_found': 'Module Not Found',
  };
} 