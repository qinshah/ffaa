import 'package:ffaa/services/app_action_service.dart';
import 'package:flutter/material.dart';
import 'package:forui/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 窗口管理
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    skipTaskbar: true, // 隐藏任务栏
    titleBarStyle: TitleBarStyle.hidden, // 隐藏标题栏
    windowButtonVisibility: false, // 隐藏窗口按钮
  );
  windowManager.waitUntilReadyToShow(windowOptions, windowManager.show);

  // 快捷键注册
  AppAction.registerHitKey();

  runApp(const FfaaApp());
}

class FfaaApp extends StatefulWidget {
  const FfaaApp({super.key});

  @override
  State<FfaaApp> createState() => _FfaaAppState();
}

class _FfaaAppState extends State<FfaaApp> with WindowListener {
  @override
  void initState() {
    // 监听窗口事件
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void onWindowBlur() {
    windowManager.isVisible().then((visible) {
      if (visible) {
        windowManager.hide();
        debugPrint('隐藏App(失去焦点)');
      }
    });
    super.onWindowBlur();
  }

  @override
  Widget build(BuildContext context) {
    final fThemeData = FThemes.zinc.light;
    return MaterialApp(
      title: 'FlutterFAA(随时随地查找)',
      theme: fThemeData.toApproximateMaterialTheme(),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
