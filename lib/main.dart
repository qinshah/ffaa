import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:ffaa/services/app_action_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/localizations.dart';
import 'package:forui/theme.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 窗口管理
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      skipTaskbar: true, // 隐藏任务栏
      titleBarStyle: TitleBarStyle.normal, // 标题栏隐藏了会导致顶部标题栏高度区域触控出问题
      windowButtonVisibility: false, // 隐藏窗口关闭等按钮
    );
    windowManager.waitUntilReadyToShow(windowOptions, windowManager.show);

    // 快捷键注册
    AppActionService.registerHitKey();
  }

  // 初始化加载系统主题色
  await SystemTheme.accentColor.load();

  // 初始化app主题模式
  final initialThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(FfaaApp(initialThemeMode: initialThemeMode));
}

// TODO 整理代码
class FfaaApp extends StatefulWidget {
  static final searchInputNode = FocusNode();
  const FfaaApp({super.key, required this.initialThemeMode});

  final AdaptiveThemeMode? initialThemeMode;

  @override
  State<FfaaApp> createState() => _FfaaAppState();
}

class _FfaaAppState extends State<FfaaApp> with WindowListener, TrayListener {
  @override
  void initState() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // 监听窗口事件
      windowManager.addListener(this);
      // 监听托盘事件
      trayManager.addListener(this);
      // 托盘菜单
      _initTrayMenu();
    }
    // 监听键盘事件
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
    super.initState();
  }

  /// 初始化托盘菜单
  void _initTrayMenu() async {
    await trayManager.setIcon('assets/img/tray-logo.png');
    final menu = Menu(items: [
      // MenuItem(
      //   label: '设置',
      //   onClick: (_) {
      //     AppActionService.openSettings(null);
      //   },
      // ),
      // MenuItem.separator(),
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
  void onTrayIconMouseDown() => AppActionService.taggleShowWindow(null);

// 右键托盘弹出菜单
  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  bool _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        return _escToHideEvent(); // Esc隐藏窗口
      case LogicalKeyboardKey.arrowDown:
        // TODO 会打断输入法翻页
        // 如果在输入，切换到app列表区域选择app
        if (FfaaApp.searchInputNode.hasFocus) {
          FfaaApp.searchInputNode.nextFocus();
        }
        return false;
      default:
        return false;
    }
  }

  /// Esc隐藏窗口
  bool _escToHideEvent() {
    windowManager.hide();
    debugPrint('Esc隐藏窗口');
    return true;
  }

  /// 聚焦搜索输入框
  bool _focusSearchInput() {
    FfaaApp.searchInputNode.requestFocus();
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
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

  // 窗口获得焦点时自动聚焦搜索输入框
  @override
  void onWindowFocus() => _focusSearchInput();

  @override
  Widget build(BuildContext context) {
    // TODO 主要颜色使用系统主题色
    // final accentColor = SystemTheme.accentColor.accent;
    final fTheme = FThemes.green;
    final lightTheme = fTheme.light.toApproximateMaterialTheme().copyWith(
          // 禁用滑动内容后appbar变色
          appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
        );
    final darkTheme = fTheme.dark.toApproximateMaterialTheme().copyWith(
          // 禁用滑动内容后appbar变色
          appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
        );
    return AdaptiveTheme(
      initial: widget.initialThemeMode ?? AdaptiveThemeMode.system,
      light: lightTheme,
      dark: darkTheme,
      builder: (lightTheme, darkTheme) {
        return GestureDetector(
          // 空白区域均可拖拽移动窗口
          onPanStart: (_) => windowManager.startDragging(),
          child: MaterialApp(
            // debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            localizationsDelegates: FLocalizations.localizationsDelegates,
            supportedLocales: FLocalizations.supportedLocales,
            builder: (context, child) {
              // 设置全局上下文供AppActionService使用
              AppActionService.setContext(context);
              return child!;
            },
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
