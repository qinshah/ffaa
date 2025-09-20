import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AdaptiveThemeManager _themeManager = AdaptiveTheme.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            title: const Text('系统主题色'),
            subtitle: Text('切换待开发'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: SystemTheme.accentColor.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          ListTile(
            title: const Text('深色模式跟随系统'),
            trailing: Switch(
              value: _themeManager.mode.isSystem,
              onChanged: (value) {
                setState(() {
                  value ? _themeManager.setSystem() : _themeManager.setLight();
                });
              },
            ),
          ),
          ListTile(
            title: const Text('深色模式'),
            trailing: Switch(
              value: AdaptiveTheme.of(context).mode.isDark,
              onChanged: _themeManager.mode.isSystem
                  ? null
                  : (value) {
                      setState(() {
                        value
                            ? _themeManager.setDark()
                            : _themeManager.setLight();
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }
}
