/*
---------------------------------------------------------------
File name:          settings_page.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Description:        应用设置页面 - 提供语言、主题、显示模式、模块管理和数据管理功能
---------------------------------------------------------------
Change History:
    2025/06/28: Phase 2.2C Step 8 - 创建完整的SettingsPage Widget，提供全方位的设置功能;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core_services/core_services.dart';
import 'package:ui_framework/core/theme_service.dart';
import 'package:ui_framework/l10n/ui_l10n.dart';
import 'package:ui_framework/shell/app_shell.dart';

/// 完整的设置页面Widget
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = BasicThemeService.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UIL10n.t('settings_title')),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题和描述
            Text(
              UIL10n.t('settings_title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              UIL10n.t('settings_description'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // 语言设置卡片
            _buildLanguageCard(),
            const SizedBox(height: 16),

            // 主题设置卡片
            _buildThemeCard(),
            const SizedBox(height: 16),

            // 显示模式卡片
            _buildDisplayModeCard(),
            const SizedBox(height: 16),

            // 模块管理卡片
            _buildModuleManagementCard(),
            const SizedBox(height: 16),

            // 数据管理卡片
            _buildDataManagementCard(),
            const SizedBox(height: 24),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  /// 构建语言设置卡片
  Widget _buildLanguageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  UIL10n.t('language_settings'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            StreamBuilder<SupportedLocale>(
              stream: localeService.localeStream,
              initialData: localeService.currentLocale,
              builder: (context, snapshot) {
                final currentLocale = snapshot.data ?? SupportedLocale.chinese;
                
                return Column(
                  children: [
                    Text(
                      '${UIL10n.t('current_language')}: ${currentLocale.displayName}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 语言选择器
                    Wrap(
                      spacing: 8,
                      children: SupportedLocale.values.map((locale) {
                        final isSelected = locale == currentLocale;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(locale.displayName),
                          onSelected: (selected) async {
                            if (selected && locale != currentLocale) {
                              try {
                                await localeService.switchToLocale(locale);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${UIL10n.t('language_switch_failed')}: $e'),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 快速切换按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await localeService.switchToChinese();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('切换失败: $e'),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.translate),
                            label: const Text('中文'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await localeService.switchToEnglish();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Switch failed: $e'),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.translate),
                            label: const Text('English'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主题设置卡片
  Widget _buildThemeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  UIL10n.t('theme_settings'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            StreamBuilder<ThemeConfig>(
              stream: _themeService.themeChanges,
              initialData: _themeService.currentConfig,
              builder: (context, snapshot) {
                final config = snapshot.data ?? const ThemeConfig();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 主题模式选择
                    Text(
                      UIL10n.t('theme_mode'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppThemeMode.values.map((mode) {
                        final isSelected = mode == config.themeMode;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(_getThemeModeDisplayName(mode)),
                          onSelected: (selected) async {
                            if (selected && mode != config.themeMode) {
                              await _themeService.setThemeMode(mode);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 颜色方案选择
                    Text(
                      UIL10n.t('color_scheme'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _themeService.getPresetColorSchemes().map((scheme) {
                        final isSelected = scheme == config.colorSchemeType;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(_getColorSchemeDisplayName(scheme)),
                          avatar: CircleAvatar(
                            radius: 8,
                            backgroundColor: scheme.seedColor,
                          ),
                          onSelected: (selected) async {
                            if (selected && scheme != config.colorSchemeType) {
                              await _themeService.setColorScheme(scheme);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 字体缩放
                    Text(
                      UIL10n.t('font_scale'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '0.8x',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Expanded(
                          child: Slider(
                            value: config.fontScale,
                            min: 0.8,
                            max: 1.4,
                            divisions: 6,
                            label: '${config.fontScale.toStringAsFixed(1)}x',
                            onChanged: (value) async {
                              await _themeService.setFontScale(value);
                            },
                          ),
                        ),
                        Text(
                          '1.4x',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 动画开关
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(UIL10n.t('animations_enabled')),
                      value: config.enableAnimations,
                      onChanged: (value) async {
                        await _themeService.setAnimationsEnabled(value);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 重置主题按钮
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showThemeResetDialog(),
                        icon: const Icon(Icons.refresh),
                        label: Text(UIL10n.t('theme_reset')),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建显示模式卡片
  Widget _buildDisplayModeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.display_settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  UIL10n.t('display_mode_settings'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            StreamBuilder<DisplayMode>(
              stream: displayModeService.currentModeStream,
              initialData: displayModeService.currentMode,
              builder: (context, snapshot) {
                final currentMode = snapshot.data ?? DisplayMode.mobile;
                
                return Column(
                  children: [
                    Text(
                      UIL10n.t('current_mode').replaceFirst('{mode}', currentMode.displayName),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentMode.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 模式切换按钮
                    Wrap(
                      spacing: 8,
                      children: DisplayMode.values.map((mode) {
                        final isSelected = mode == currentMode;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(mode.displayName),
                          onSelected: (selected) {
                            if (selected && mode != currentMode) {
                              displayModeService.switchToMode(mode);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 快速切换按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => displayModeService.switchToNextMode(),
                        icon: const Icon(Icons.swap_horiz),
                        label: Text(UIL10n.t('switch_to_next_mode')),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建模块管理卡片
  Widget _buildModuleManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.extension,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  UIL10n.t('module_management_settings'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 模块列表
            FutureBuilder<List<ModuleInfo>>(
              future: _getInstalledModules(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final modules = snapshot.data ?? [];
                
                return Column(
                  children: [
                    Text(
                      '${UIL10n.t('installed_modules')}: ${modules.length}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...modules.map((module) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          module.icon,
                          color: module.isActive 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: Text(module.name),
                        subtitle: Text(module.description),
                        trailing: Switch(
                          value: module.isActive,
                          onChanged: module.isCoreModule ? null : (value) {
                            _toggleModuleStatus(module, value);
                          },
                        ),
                        onTap: () => _showModuleDetails(module),
                      ),
                    )).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数据管理卡片
  Widget _buildDataManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  UIL10n.t('data_management'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 存储使用情况
            FutureBuilder<Map<String, dynamic>>(
              future: _getStorageInfo(),
              builder: (context, snapshot) {
                final info = snapshot.data ?? {};
                
                return Column(
                  children: [
                    _buildInfoRow(UIL10n.t('total_items'), '${info['totalItems'] ?? 0}'),
                    _buildInfoRow(UIL10n.t('data_size'), '${info['dataSize'] ?? 'N/A'}'),
                    _buildInfoRow(UIL10n.t('cache_size'), '${info['cacheSize'] ?? 'N/A'}'),
                    
                    const SizedBox(height: 16),
                    
                    // 数据管理按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportData,
                            icon: const Icon(Icons.download),
                            label: Text(UIL10n.t('data_export')),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _importData,
                            icon: const Icon(Icons.upload),
                            label: Text(UIL10n.t('data_import')),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearCache,
                        icon: const Icon(Icons.cleaning_services),
                        label: Text(UIL10n.t('clear_cache')),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            // 检查是否可以返回，如果不能则跳转到首页
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          child: Text(UIL10n.t('back_button')),
        ),
        ElevatedButton(
          onPressed: () => context.go('/'),
          child: Text(UIL10n.t('home_button')),
        ),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取主题模式显示名称
  String _getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return UIL10n.t('light_theme');
      case AppThemeMode.dark:
        return UIL10n.t('dark_theme');
      case AppThemeMode.system:
        return UIL10n.t('system_theme');
    }
  }

  /// 获取颜色方案显示名称
  String _getColorSchemeDisplayName(ColorSchemeType scheme) {
    switch (scheme) {
      case ColorSchemeType.material:
        return UIL10n.t('material_purple');
      case ColorSchemeType.blue:
        return UIL10n.t('blue_scheme');
      case ColorSchemeType.green:
        return UIL10n.t('green_scheme');
      case ColorSchemeType.orange:
        return UIL10n.t('orange_scheme');
      case ColorSchemeType.red:
        return UIL10n.t('red_scheme');
      case ColorSchemeType.pink:
        return UIL10n.t('pink_scheme');
      case ColorSchemeType.teal:
        return UIL10n.t('teal_scheme');
      case ColorSchemeType.custom:
        return UIL10n.t('custom_scheme');
    }
  }

  /// 显示主题重置确认对话框
  void _showThemeResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UIL10n.t('theme_reset')),
        content: Text(UIL10n.t('theme_reset_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(UIL10n.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await _themeService.resetToDefault();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(UIL10n.t('theme_reset_success')),
                  ),
                );
              }
            },
            child: Text(UIL10n.t('confirm')),
          ),
        ],
      ),
    );
  }

  /// 获取已安装模块列表
  Future<List<ModuleInfo>> _getInstalledModules() async {
    // 模拟模块数据
    return [
      ModuleInfo(
        id: 'notes_hub',
        name: UIL10n.t('notes_hub_nav'),
        description: UIL10n.t('notes_hub_description'),
        icon: Icons.note,
        isActive: true,
        isCoreModule: true,
        version: '1.0.0',
        author: 'System',
      ),
      ModuleInfo(
        id: 'workshop',
        name: UIL10n.t('workshop_nav'),
        description: UIL10n.t('workshop_description'),
        icon: Icons.build,
        isActive: true,
        isCoreModule: true,
        version: '1.0.0',
        author: 'System',
      ),
      ModuleInfo(
        id: 'punch_in',
        name: UIL10n.t('punch_in_nav'),
        description: UIL10n.t('punch_in_description'),
        icon: Icons.access_time,
        isActive: true,
        isCoreModule: true,
        version: '1.0.0',
        author: 'System',
      ),
    ];
  }

  /// 切换模块状态
  void _toggleModuleStatus(ModuleInfo module, bool enabled) {
    if (module.isCoreModule) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(UIL10n.t('module_cannot_disable')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    // TODO: 实现模块启用/禁用逻辑
    setState(() {
      // 更新模块状态
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enabled ? UIL10n.t('module_enabled') : UIL10n.t('module_disabled')),
      ),
    );
  }

  /// 显示模块详情
  void _showModuleDetails(ModuleInfo module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(module.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(UIL10n.t('module_version'), module.version),
            _buildInfoRow(UIL10n.t('module_author'), module.author),
            _buildInfoRow(UIL10n.t('module_description'), module.description),
            _buildInfoRow(UIL10n.t('module_info'), 
              module.isCoreModule ? UIL10n.t('core_module') : UIL10n.t('extension_module')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(UIL10n.t('close')),
          ),
        ],
      ),
    );
  }

  /// 获取存储信息
  Future<Map<String, dynamic>> _getStorageInfo() async {
    // TODO: 实现真实的存储信息获取
    return {
      'totalItems': 42,
      'dataSize': '2.3 MB',
      'cacheSize': '1.1 MB',
    };
  }

  /// 导出数据
  void _exportData() {
    // TODO: 实现数据导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${UIL10n.t('data_export')} - ${UIL10n.t('feature_coming_soon')}'),
      ),
    );
  }

  /// 导入数据
  void _importData() {
    // TODO: 实现数据导入功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${UIL10n.t('data_import')} - ${UIL10n.t('feature_coming_soon')}'),
      ),
    );
  }

  /// 清除缓存
  void _clearCache() {
    // TODO: 实现缓存清除功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${UIL10n.t('clear_cache')} - ${UIL10n.t('feature_coming_soon')}'),
      ),
    );
  }
} 