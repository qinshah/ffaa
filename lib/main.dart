import 'package:ffaa/services/app_action_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static final searchInputNode = FocusNode();
  const FfaaApp({super.key});

  @override
  State<FfaaApp> createState() => _FfaaAppState();
}

class _FfaaAppState extends State<FfaaApp> with WindowListener {
  @override
  void initState() {
    // 监听窗口事件
    windowManager.addListener(this);
    // 监听键盘事件(esc隐藏窗口)
    HardwareKeyboard.instance.addHandler(_escToHideApp);
    super.initState();
  }

  /// esc隐藏窗口
  bool _escToHideApp(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      windowManager.hide();
      debugPrint('隐藏窗口(Esc)');
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_escToHideApp);
    super.dispose();
  }

  @override
  void onWindowBlur() {
    // 窗口失去焦点时自动隐藏
    windowManager.isVisible().then((visible) {
      if (visible) {
        windowManager.hide();
        debugPrint('隐藏窗口(失去焦点)');
      }
    });
    super.onWindowBlur();
  }

  @override
  void onWindowFocus() {
    // 自动聚焦搜索输入框
    FfaaApp.searchInputNode.requestFocus();
    super.onWindowFocus();
  }

  @override
  Widget build(BuildContext context) {
    final fThemeData = FThemes.zinc.light;
    return GestureDetector(
      // 空白区域均可拖拽移动窗口
      onPanStart: (_) => windowManager.startDragging(),
      child: MaterialApp(
        theme: fThemeData.toApproximateMaterialTheme(),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
