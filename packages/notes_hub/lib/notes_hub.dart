/// Notes Hub Package
/// 
/// 笔记中心模块 - 提供笔记管理和编辑功能
library notes_hub;
 
// 模块组件
export 'notes_hub_module.dart';
export 'notes_hub_widget.dart';

// 导出本地化数据类
export 'notes_hub_widget.dart' show BusinessModuleLocalizations;

// Phase 2.2 Sprint 2: 分布式i18n支持
export 'l10n/notes_hub_l10n.dart';
export 'l10n/notes_hub_zh.dart';
export 'l10n/notes_hub_en.dart'; 