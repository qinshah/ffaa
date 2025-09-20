import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class AppAction {
  final String name;

  HotKey hotKey;

  final ValueChanged<HotKey> keyDownAction;

  AppAction(this.name, this.hotKey, this.keyDownAction);

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

  static final values = <AppAction>[
    // TODO 实现隐藏功能
    AppAction(
      '隐藏/显示',
      HotKey(
        key: PhysicalKeyboardKey.keyH,
        modifiers: [HotKeyModifier.alt],
      ),
      (_) async {
        if (await windowManager.isFocused()) {
          windowManager.hide();
          debugPrint('隐藏窗口(快捷键)');
        } else {
          windowManager.show().then((_) => windowManager.focus());
          debugPrint('显示窗口(快捷键)');
        }
      },
    ),
  ];
}
