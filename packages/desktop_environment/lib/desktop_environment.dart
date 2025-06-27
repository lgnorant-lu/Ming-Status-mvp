/*
---------------------------------------------------------------
File name:          desktop_environment.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        Desktop Environment包主入口 - 导出"空间化OS"模式的所有核心组件
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b Step 7 - 创建包基础结构和主入口文件;
---------------------------------------------------------------
*/

library desktop_environment;

// 导出核心组件
export 'spatial_os_shell.dart';
export 'window_manager.dart'; 
export 'floating_window.dart';
export 'app_dock.dart';
export 'performance_monitor_panel.dart';
export 'dev_panel.dart';

// 导出工具类和类型定义
export 'types/window_types.dart';
export 'utils/desktop_utils.dart'; 