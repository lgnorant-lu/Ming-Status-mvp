/*
---------------------------------------------------------------
File name:          app.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        主应用程序Widget - 提供应用主体界面，支持本地化参数传递
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 i18n集成 - 支持本地化参数传递;
    2025/06/26: Phase 1.5 架构调整 - 简化为Widget，国际化配置移至main.dart;
    2025/06/26: Phase 1.5 重构 - 修正导入，简化依赖;
    2025/06/25: Initial creation - 应用程序框架搭建;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'shell/main_shell.dart';

/// 主应用程序Widget
/// 
/// 接受可选的本地化参数并传递给MainShell
class PetApp extends StatelessWidget {
  final MainShellLocalizations? localizations;
  final Function(Locale)? onLocaleChanged;
  
  const PetApp({super.key, this.localizations, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    return MainShell(
      localizations: localizations,
      onLocaleChanged: onLocaleChanged,
    );
  }
} 