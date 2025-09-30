import 'dart:io';
import 'package:app_manager/app_manager.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:process/process.dart';

class AppLauncher {
  static const ProcessManager _processManager = LocalProcessManager();

  static Future launchApp(App app) async {
    if (Platform.isMacOS) {
      _launchMacOSApp(app);
    } else if (Platform.isAndroid) {
      // TODO 一些应用打不开
      LaunchApp.openApp(androidPackageName: app.packageName);
      // final intent = AndroidIntent(
      //   package: appInfo.bundleId,
      //   action: 'android.intent.action.MAIN',
      //   category: 'android.intent.category.LAUNCHER',
      //   flags: [Flag.FLAG_ACTIVITY_NEW_TASK], // 确保能从任何上下文启动
      // );
      // intent.launch();
    } else {
      throw UnimplementedError('当前平台不支持应用启动功能');
    }
  }

  static Future<bool> _launchMacOSApp(App app) async {
    try {
      final result = await _processManager.run([
        'open',
        '-a',
        app.path!, // 空安全
      ]);

      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openAppInFinder(App app) async {
    try {
      if (Platform.isMacOS) {
        final result = await _processManager.run([
          'open',
          '-R',
          app.path!, // 空安全
        ]);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
