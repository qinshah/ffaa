import 'package:ffaa/services/app_action_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/theme.dart';
import 'package:tray_manager/tray_manager.dart';
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

// TODO 整理代码
class FfaaApp extends StatefulWidget {
  static final searchInputNode = FocusNode();
  const FfaaApp({super.key});

  @override
  State<FfaaApp> createState() => _FfaaAppState();
}

class _FfaaAppState extends State<FfaaApp> with WindowListener, TrayListener {
  @override
  void initState() {
    // 监听窗口事件
    windowManager.addListener(this);
    // 监听托盘事件
    trayManager.addListener(this);
    // 监听键盘事件(Esc隐藏窗口)
    HardwareKeyboard.instance.addHandler(_escToHideApp);
    // 托盘菜单
    _initTrayMenu();
    super.initState();
  }

  /// 初始化托盘菜单
  void _initTrayMenu() async {
    await trayManager.setIcon('assets/img/tray-logo.png');
    final menu = Menu(items: [
      MenuItem(
        label: '退出',
        onClick: (_) {
          debugPrint('主动关闭应用');
          SystemNavigator.pop(animated: true);
        },
      ),
    ]);
    trayManager.setContextMenu(menu);
  }

  // 左键托盘同样切换隐藏/显示窗口
  @override
  void onTrayIconMouseDown() {
    AppAction.taggleShowWindow(null);
    super.onTrayIconMouseDown();
  }

// 右键托盘弹出菜单
  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  /// Esc隐藏窗口
  bool _escToHideApp(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      windowManager.hide();
      debugPrint('Esc隐藏窗口');
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
        debugPrint('窗口失去焦点自动隐藏');
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
