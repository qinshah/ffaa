import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../services/app_action.dart';

class HotKeyDialog extends StatefulWidget {
  final AppAction action;
  const HotKeyDialog(this.action, {super.key});

  @override
  State<HotKeyDialog> createState() => _HotKeyDialogState();
}

class _HotKeyDialogState extends State<HotKeyDialog> {
  late List<HotKeyModifier> _modifiers = widget.action.hotKey?.modifiers ?? [];
  late KeyboardKey? _key = widget.action.hotKey?.key;

  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(_setHotKey);
    super.initState();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_setHotKey);
    super.dispose();
  }

  bool _setHotKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() {
        _modifiers =
            HotKeyModifier.values.where((m) => m.isModifierPressed).toList();
        final pressedKey = event.physicalKey;
        _key = HotKeyModifier.values
                .any((m) => m.physicalKeys.contains(pressedKey))
            ? null
            : pressedKey;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置快捷键'),
      content: Text([
        ...(_modifiers).map((e) => e.physicalKeys.first.keyLabel),
        if (_key != null) (_key as PhysicalKeyboardKey).keyLabel,
      ].join(' + ')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: widget.action.hotKey != null
              ? () {
                  widget.action.clearHotKey(widget.action.hotKey!);
                  Navigator.pop(context, true);
                }
              : null,
          child: const Text('清除'),
        ),
        TextButton(
          onPressed: _modifiers.isNotEmpty && _key != null
              ? () {
                  widget.action
                      .reSetHotKey(HotKey(modifiers: _modifiers, key: _key!));
                  Navigator.pop(context, true);
                }
              : null,
          child: const Text('确定'),
        ),
      ],
    );
  }
}
