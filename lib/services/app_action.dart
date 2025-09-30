import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import '../view/settings/settings_page.dart';

class AppAction {
  final String name;

  HotKey? hotKey;

  final ValueChanged<HotKey> keyDownAction;

  static BuildContext? _context;

  AppAction(
    this.name, {
    this.hotKey,
    required this.keyDownAction,
  });

  /// 重新设置快捷键
  void reSetHotKey(HotKey newHotKey) {
    if (hotKey != null) clearHotKey(hotKey!);
    hotKey = newHotKey;
    hotKeyManager.register(
      hotKey!,
      keyDownHandler: keyDownAction,
    );
  }

  /// 清除快捷键
  void clearHotKey(HotKey existingHotKey) {
    hotKeyManager.unregister(existingHotKey);
    hotKey = null;
  }

  /// 注册快捷键
  static void registerAllHotKey() {
    hotKeyManager.unregisterAll();
    for (var action in values) {
      if (action.hotKey == null) continue;
      hotKeyManager.register(
        action.hotKey!,
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

  static final values = <AppAction>[
    AppAction(
      '隐藏/显示',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyZ,
        modifiers: [kDebugMode ? HotKeyModifier.alt : HotKeyModifier.control],
      ),
      keyDownAction: taggleShowWindow,
    ),
    AppAction(
      '其它待开发功能',
      keyDownAction: (_) {},
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
