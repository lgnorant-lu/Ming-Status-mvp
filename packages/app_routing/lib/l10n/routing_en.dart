/*
---------------------------------------------------------------
File name:          routing_en.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Routing English translations - Phase 2.2 Sprint 2 distributed i18n system
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// App routing English translation provider
class AppRoutingEnProvider extends BasePackageI18nProvider {
  AppRoutingEnProvider() : super('app_routing_en') {
    addTranslations(SupportedLocale.english, _enTranslations);
  }

  static const Map<String, String> _enTranslations = {
    // App title
    'app_title': 'Pet AI Assistant Platform',
    
    // Page titles
    'home_title': 'Home',
    'notes_hub_title': 'Notes Hub',
    'workshop_title': 'Workshop',
    'punch_in_title': 'Punch In',
    'settings_title': 'Settings',
    'about_title': 'About',
    
    // Navigation labels
    'home_nav': 'Home',
    'notes_hub_nav': 'Notes Hub',
    'workshop_nav': 'Workshop',
    'punch_in_nav': 'Punch In',
    'settings_nav': 'Settings',
    'about_nav': 'About',
    
    // Settings page
    'language_settings': 'Language Settings',
    'current_language': 'Current language: {language}',
    'switch_to_next_language': 'Switch to next language',
    'language_switched': 'Switched to {language}',
    'language_switch_failed': 'Language switch failed: {error}',
    'language_switched_to': 'Switched to',
    'language_switch_error': 'Language switch failed',
    
    'display_mode_settings': 'Display Mode',
    'current_mode': 'Current mode: {mode}',
    'switch_to_next_mode': 'Switch to next mode',
    
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
    
    'app_settings': 'App Settings',
    'app_settings_description': 'Theme settings, notification preferences, data sync and more',
    
    // Display modes
    'mobile_mode': 'Mobile Mode',
    'desktop_mode': 'Desktop Mode',
    'web_mode': 'Web Mode',
    'mobile_mode_desc': 'Touch interface optimized for phones and tablets',
    'desktop_mode_desc': 'Mouse and keyboard interface for PCs and laptops',
    'web_mode_desc': 'Responsive interface for browser environments',
    
    // DisplayMode internationalization
    'display_mode_mobile': 'Mobile Mode',
    'display_mode_desktop': 'Desktop Mode',
    'display_mode_web': 'Web Mode',
    'display_mode_mobile_desc': 'Immersive mobile app following native Material Design experience',
    'display_mode_desktop_desc': 'Spatial desktop environment with modules as independent floating windows',
    'display_mode_web_desc': 'Responsive web layout that adapts to different screen sizes and browser environments',
    
    // Home content
    'welcome_message': 'Welcome to Pet AI Assistant Platform',
    'app_description': 'Intelligent assistant platform based on "Pet-Bus" plugin architecture',
    'project_info': 'Phase 2.1 Tri-platform Adaptive Architecture',
    'project_features': '✅ ModularMobileShell (True modular mobile) Implemented\n✅ DisplayModeAwareShell (Tri-platform smart adaptation) Integrated\n✅ DisplayModeService (Dynamic switching service) Enabled',
    
    // Module status
    'module_status': 'Module Status',
    'module_active': 'Modules: {active}/{total} Active',
    
    // Action buttons
    'switch_button': 'Switch',
    'back_button': 'Back',
    'home_button': 'Home',
    
    // Module descriptions
    'home_description': 'App overview and module status',
    'notes_hub_description': 'Manage your notes and tasks',
    'workshop_description': 'Record your creativity and inspiration',
    'punch_in_description': 'Record your attendance time',
    
    // Placeholder pages
    'under_construction': 'Under Development',
    'placeholder_description': 'Phase 2.0 Sprint 2.0a\nModule Placeholder UI',
    'about_app_version': 'Pet AI Assistant Platform v2.1.0\nPhase 2.1 Tri-platform Adaptive UI Framework',
    
    // Error messages
    'page_not_found': 'Page Not Found',
    'navigation_error': 'Navigation Error',
    'route_error': 'Route Error',
    'return_home': 'Return Home',
    'path_not_found': 'Path not found: {path}',
    
    // System info
    'version_info': 'Phase 2.0 - v2.0.0',
    'copyright_info': '© 2025 Pet AI Assistant Platform\nPowered by Flutter',
    
    // Module management
    'module_management': 'Module Management',
    'module_management_dialog': 'Module Management',
    'module_management_todo': 'Module management feature will be implemented in Phase 2.1',
    
    // Core features
    'core_features': 'Core Features',
    'builtin_modules': 'Built-in Modules',
    'extension_modules': 'Extension Modules',
    'system': 'System',
    'pet_assistant': 'Pet Assistant',
    
    // Status indicators
    'module_active_indicator': '✅',
    'module_inactive_indicator': '📱',
    'loading_indicator': '⏳',
    'error_indicator': '❌',
    'success_indicator': '✅',
    
    // Desktop environment related
    'desktop_app_title': 'Pet AI Assistant Platform',
    'desktop_phase_info': 'Phase 2.0 Sprint 2.0b - Spatial OS Mode',
    'window_manager_status': 'WindowManager Status',
    'active_windows': 'Active Windows',
    'focused_window': 'Focused Window',
    'no_focus': 'None',
    'minimized_windows': 'Minimized Windows',
    'settings_window_title': 'Settings',
    'settings_window_subtitle': 'Application settings and configuration',
    'settings_content_placeholder': 'Settings content\n(Will integrate complete settings interface)',
    'window_opened': 'Opened {moduleName} module window',
    'window_exists_error': '{moduleName} window already exists or window limit reached',
    'settings_window_opened': 'Settings window opened',
    'settings_window_exists': 'Settings window already exists or window limit reached',
    'dev_panel_status': 'DevPanel developer tools',
    'data_monitor_status': 'Data monitoring panel',
    
    // Web interface translations
    'collapse_sidebar': 'Collapse Sidebar',
    'expand_sidebar': 'Expand Sidebar',
    'select_language': 'Select Language',
    'search_placeholder': 'Search...',
    'toggle_language': 'Toggle Language',
    'user_profile': 'User Profile',
    'profile_feature_coming': 'Profile feature will be implemented in future versions',
    'module_not_found': 'Module Not Found',
  };
} 