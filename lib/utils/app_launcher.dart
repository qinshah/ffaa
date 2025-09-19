import 'dart:io';
import 'package:process/process.dart';
import '../models/app_info.dart';

class AppLauncher {
  static const ProcessManager _processManager = LocalProcessManager();

  static Future<bool> launchApp(AppInfo appInfo) async {
    try {
      if (Platform.isMacOS) {
        return await _launchMacOSApp(appInfo);
      } else {
        throw UnimplementedError('当前平台不支持应用启动功能');
      }
    } catch (e) {
      return false;
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