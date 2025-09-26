import 'dart:io';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:process/process.dart';
import 'package:app_list/app_list.dart';

class AppLauncher {
  static const ProcessManager _processManager = LocalProcessManager();

  static Future launchApp(AppInfo appInfo) async {
    if (Platform.isMacOS) {
      _launchMacOSApp(appInfo);
    } else if (Platform.isAndroid) {
      // TODO 一些应用打不开
      LaunchApp.openApp(androidPackageName: appInfo.bundleId);
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

  static Future<bool> _launchMacOSApp(AppInfo appInfo) async {
    try {
      final result = await _processManager.run([
        'open',
        '-a',
        appInfo.path,
      ]);

      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openAppInFinder(AppInfo appInfo) async {
    try {
      if (Platform.isMacOS) {
        final result = await _processManager.run([
          'open',
          '-R',
          appInfo.path,
        ]);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
