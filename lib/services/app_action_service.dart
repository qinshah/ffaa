import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import '../pages/settings_page.dart';

class AppActionService {
  final String name;

  HotKey hotKey;

  final ValueChanged<HotKey> keyDownAction;

  static BuildContext? _context;

  AppActionService(
    this.name, {
    required this.hotKey,
    required this.keyDownAction,
  });

  /// 设置全局上下文
  static void setContext(BuildContext context) {
    _context = context;
  }

  /// 注册快捷键
  static void registerHitKey() {
    hotKeyManager.unregisterAll();
    for (var action in values) {
      hotKeyManager.register(
        action.hotKey,
        keyDownHandler: action.keyDownAction,
      );
    }
  }

  /// 隐藏/显示窗口
  static void taggleShowWindow(_) async {
    if (await windowManager.isFocused()) {
      windowManager.hide();
      debugPrint('主动隐藏窗口');
    } else {
      windowManager.setSkipTaskbar(true); // 隐藏任务栏
      await windowManager.show();
      windowManager.focus();
      debugPrint('主动显示窗口');
    }
  }

  /// 打开设置页
  static void openSettings(_) async {
    if (_context != null) {
      await windowManager.show();
      windowManager.focus();
      Navigator.of(_context!).push(
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
      debugPrint('打开设置页');
    }
  }

  static final values = <AppActionService>[
    AppActionService(
      '隐藏/显示',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyZ,
        modifiers: [kDebugMode ? HotKeyModifier.alt : HotKeyModifier.control],
      ),
      keyDownAction: taggleShowWindow,
    ),
    // AppActionService(
    //   '设置',
    //   hotKey: HotKey(
    //     key: PhysicalKeyboardKey.keyS,
    //     modifiers: [HotKeyModifier.alt],
    //   ),
    //   keyDownAction: openSettings,
    // ),
  ];
}
