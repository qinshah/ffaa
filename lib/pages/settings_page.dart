import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/widgets/tabs.dart';
import 'package:system_theme/system_theme.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../services/app_action_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AdaptiveThemeManager _themeManager = AdaptiveTheme.of(context);
  bool _isRecordingHotkey = false;
  int _recordingActionIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          // ListTile(
          //   title: const Text('系统主题色'),
          //   subtitle: const Text('切换待开发'),
          //   trailing: Container(
          //     width: 24,
          //     height: 24,
          //     decoration: BoxDecoration(
          //       color: SystemTheme.accentColor.accent,
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('主题亮暗(深色模式)', style: TextStyle(fontSize: 16)),
              Spacer(),
              SizedBox(
                width: 300,
                child: FTabs(
                  initialIndex: _themeManager.mode.index,
                  children: AdaptiveThemeMode.values.map((mode) {
                    return FTabEntry(label: Text(mode.name), child: SizedBox());
                  }).toList(),
                  onChange: (index) => setState(() {
                    _themeManager.setThemeMode(AdaptiveThemeMode.values[index]);
                  }),
                ),
              ),
            ]),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '快捷键设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // ...AppActionService.values.asMap().entries.map(
          //   (entry) {
          //     final index = entry.key;
          //     final action = entry.value;
          //     return ListTile(
          //       title: Text(action.name),
          //       subtitle: Text(_formatHotKey(action.hotKey)),
          //       trailing: _isRecordingHotkey && _recordingActionIndex == index
          //           ? const SizedBox(
          //               width: 20,
          //               height: 20,
          //               child: CircularProgressIndicator(strokeWidth: 2),
          //             )
          //           : IconButton(
          //               icon: const Icon(Icons.edit),
          //               onPressed: () => _startRecordingHotkey(index),
          //             ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  /// 格式化快捷键显示
  String _formatHotKey(HotKey hotKey) {
    final modifiers = hotKey.modifiers?.map((m) {
          switch (m) {
            case HotKeyModifier.alt:
              return 'Alt';
            case HotKeyModifier.control:
              return 'Ctrl';
            case HotKeyModifier.shift:
              return 'Shift';
            case HotKeyModifier.meta:
              return 'Cmd';
            default:
              return m.toString();
          }
        }).join(' + ') ??
        '';

    final keyName = _getKeyName(hotKey.key);
    return modifiers.isNotEmpty ? '$modifiers + $keyName' : keyName;
  }

  /// 获取按键名称
  String _getKeyName(KeyboardKey key) {
    if (key == PhysicalKeyboardKey.keyH) return 'H';
    if (key == PhysicalKeyboardKey.keyS) return 'S';
    if (key == PhysicalKeyboardKey.keyT) return 'T';
    // 可以根据需要添加更多按键映射
    if (key is PhysicalKeyboardKey) {
      return key.debugName?.replaceAll('Physical Keyboard Key: ', '') ??
          key.toString();
    }
    return key.toString();
  }

  /// 开始录制快捷键
  void _startRecordingHotkey(int actionIndex) {
    setState(() {
      _isRecordingHotkey = true;
      _recordingActionIndex = actionIndex;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('录制快捷键'),
        content: const Text('请按下新的快捷键组合...'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isRecordingHotkey = false;
                _recordingActionIndex = -1;
              });
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
        ],
      ),
    );

    // 监听键盘事件
    _listenForHotkey(actionIndex);
  }

  /// 监听快捷键输入
  void _listenForHotkey(int actionIndex) {
    // 这里简化实现，实际项目中可能需要更复杂的键盘监听逻辑
    Future.delayed(const Duration(seconds: 3), () {
      if (_isRecordingHotkey) {
        // 模拟录制到新的快捷键（这里可以根据实际需求实现真正的键盘监听）
        _updateHotkey(
          actionIndex,
          HotKey(
            key: PhysicalKeyboardKey.keyT,
            modifiers: [HotKeyModifier.alt],
          ),
        );
      }
    });
  }

  /// 更新快捷键
  void _updateHotkey(int actionIndex, HotKey newHotKey) {
    setState(() {
      AppActionService.values[actionIndex].hotKey = newHotKey;
      _isRecordingHotkey = false;
      _recordingActionIndex = -1;
    });

    Navigator.of(context).pop();

    // 重新注册所有快捷键
    AppActionService.registerHitKey();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('快捷键已更新为: ${_formatHotKey(newHotKey)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
