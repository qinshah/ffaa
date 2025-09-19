import 'dart:io';
import 'dart:convert';
import 'package:process/process.dart';
import '../models/app_info.dart';

class MacOSAppService {
  static const ProcessManager _processManager = LocalProcessManager();
  static const String _applicationsPath = '/Applications';

  static Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<AppInfo> apps = [];
      final Directory applicationsDir = Directory(_applicationsPath);
      
      if (!await applicationsDir.exists()) {
        throw Exception('Applications目录不存在');
      }

      await for (final FileSystemEntity entity in applicationsDir.list()) {
        if (entity is Directory && entity.path.endsWith('.app')) {
          final appInfo = await _getAppInfo(entity);
          if (appInfo != null) {
            apps.add(appInfo);
          }
        }
      }

      // 按应用名称排序
      apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return apps;
    } catch (e) {
      return [];
    }
  }

  static Future<AppInfo?> _getAppInfo(Directory appDir) async {
    try {
      final String appName = _getAppNameFromPath(appDir.path);
      final String infoPlistPath = '${appDir.path}/Contents/Info.plist';
      
      String? bundleId;
      String? version;
      String? iconPath;

      // 尝试读取Info.plist文件获取应用信息
      final File infoPlist = File(infoPlistPath);
      if (await infoPlist.exists()) {
        try {
          final result = await _processManager.run([
            'plutil',
            '-convert',
            'json',
            '-o',
            '-',
            infoPlistPath,
          ]);

          if (result.exitCode == 0) {
            final Map<String, dynamic> plistData = 
                json.decode(result.stdout as String);
            
            bundleId = plistData['CFBundleIdentifier'] as String?;
            version = plistData['CFBundleShortVersionString'] as String? ??
                     plistData['CFBundleVersion'] as String?;
            
            // 获取图标信息
            final iconFile = plistData['CFBundleIconFile'] as String?;
            if (iconFile != null) {
              iconPath = '${appDir.path}/Contents/Resources/$iconFile';
              if (!iconPath.endsWith('.icns')) {
                iconPath += '.icns';
              }
            }
          }
        } catch (e) {
          // 忽略解析错误
        }
      }

      return AppInfo(
        name: appName,
        path: appDir.path,
        bundleId: bundleId,
        version: version,
        iconPath: iconPath,
      );
    } catch (e) {
      return null;
    }
  }

  static String _getAppNameFromPath(String path) {
    final String fileName = path.split('/').last;
    if (fileName.endsWith('.app')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }
}