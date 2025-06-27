/*
---------------------------------------------------------------
File name:          desktop_utils.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        桌面工具类 - 提供桌面环境相关的工具函数和常量
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b Step 7 - 创建桌面工具类基础结构;
---------------------------------------------------------------
*/

/// 桌面环境工具类
class DesktopUtils {
  DesktopUtils._(); // 私有构造函数，防止实例化

  /// 默认窗口尺寸
  static const double defaultWindowWidth = 400.0;
  static const double defaultWindowHeight = 300.0;
  
  /// 最小窗口尺寸
  static const double minWindowWidth = 200.0;
  static const double minWindowHeight = 150.0;
  
  /// 应用程序坞配置
  static const double dockHeight = 60.0;
  static const double dockItemSize = 48.0;
  static const double dockItemSpacing = 8.0;
  
  /// 窗口装饰配置
  static const double titleBarHeight = 32.0;
  static const double windowBorderWidth = 1.0;
  static const double windowShadowBlur = 8.0;
  
  /// 性能配置
  static const int maxConcurrentWindows = 10;
  static const Duration windowAnimationDuration = Duration(milliseconds: 200);
  static const Duration dragUpdateThrottle = Duration(milliseconds: 16); // ~60fps
  
  /// 计算窗口居中位置
  static Map<String, double> calculateCenterPosition({
    required double screenWidth,
    required double screenHeight,
    required double windowWidth,
    required double windowHeight,
  }) {
    return {
      'x': (screenWidth - windowWidth) / 2,
      'y': (screenHeight - windowHeight) / 2,
    };
  }
  
  /// 检查窗口是否在屏幕边界内
  static bool isWindowInBounds({
    required double x,
    required double y,
    required double width,
    required double height,
    required double screenWidth,
    required double screenHeight,
  }) {
    return x >= 0 && 
           y >= 0 && 
           x + width <= screenWidth && 
           y + height <= screenHeight;
  }
  
  /// 将窗口限制在屏幕边界内
  static Map<String, double> clampWindowToBounds({
    required double x,
    required double y,
    required double width,
    required double height,
    required double screenWidth,
    required double screenHeight,
  }) {
    final clampedX = (x + width > screenWidth) 
        ? screenWidth - width 
        : (x < 0 ? 0.0 : x);
    final clampedY = (y + height > screenHeight) 
        ? screenHeight - height 
        : (y < 0 ? 0.0 : y);
    
    return {
      'x': clampedX,
      'y': clampedY,
    };
  }
} 