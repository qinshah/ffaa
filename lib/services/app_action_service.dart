import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class AppAction {
  final String name;

  HotKey hotKey;

  final ValueChanged<HotKey> keyDownAction;

  AppAction(
    this.name, {
    required this.hotKey,
    required this.keyDownAction,
  });

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
      await windowManager.show();
      windowManager.focus();
      debugPrint('主动显示窗口');
    }
  }

  static final values = <AppAction>[
    AppAction(
      '隐藏/显示',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyH,
        modifiers: [HotKeyModifier.alt],
      ),
      keyDownAction: taggleShowWindow,
    ),
  ];
}
