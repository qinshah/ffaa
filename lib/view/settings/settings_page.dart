import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../services/app_action.dart';
import '../../utils/const.dart';
import 'hot_key_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AdaptiveThemeManager _themeManager = AdaptiveTheme.of(context);

  /// 获取快捷键的显示名称，包含备用方案以防止release模式下debugName为null
  String _getHotKeyLabel(HotKey hotKey) {
    final List<String> parts = [];
    for (final modifier in hotKey.modifiers!) {
      parts.add(modifier.physicalKeys[0].keyLabel);
    }
    parts.add((hotKey.key as PhysicalKeyboardKey).keyLabel);
    return parts.join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(title: Text('外观')),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              ListTile(
                title: const Text('主题亮暗(深色模式)', style: TextStyle(fontSize: 16)),
                trailing: CupertinoSlidingSegmentedControl(
                  groupValue: _themeManager.mode,
                  onValueChanged: (mode) => _themeManager.setThemeMode(mode!),
                  children: Map.fromIterables(
                    AdaptiveThemeMode.values,
                    AdaptiveThemeMode.values.map((mode) => Text(mode.name)),
                  ),
                ),
              ),
              ListTile(
                title: const Text('主色调'),
                subtitle: const Text('切换功能待开发'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ]),
          ),
          SizedBox(height: 20),
          ListTile(title: Text('快捷键')),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                AppAction.values.length,
                (index) {
                  final action = AppAction.values[index];
                  return ListTile(
                    title: Text(action.name),
                    trailing: Text(
                      Const.isPC
                          ? action.hotKey != null
                              ? _getHotKeyLabel(action.hotKey!)
                              : '未设置'
                          : '手机暂不支持快捷键',
                    ),
                    onTap: Const.isPC
                        ? () => showAdaptiveDialog<bool>(
                              context: context,
                              builder: (context) => HotKeyDialog(action),
                            ).then((value) {
                              if (value == true) setState(() {}); // 显示新快捷键
                            })
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
