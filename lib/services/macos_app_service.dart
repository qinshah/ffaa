import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:process/process.dart';
import '../models/app_info.dart';

class MacOSAppService {
  static const ProcessManager _processManager = LocalProcessManager();

  // TODO 扫描文件夹子节点中的应用
  static Future<List<AppInfo>> getInstalledApps() async {
    try {
      final appDirentities = Directory('/Applications').listSync();
      appDirentities.addAll(Directory('/System/Applications').listSync());

      debugPrint('应用文件夹共有${appDirentities.length}个子节点');

      final List<AppInfo> apps = [];
      for (final FileSystemEntity entity in appDirentities) {
        if (entity is Directory && entity.path.endsWith('.app')) {
          final appInfo = await _getAppInfo(entity);
          if (appInfo != null) {
            apps.add(appInfo);
          }
        }
      }
      debugPrint('共扫描出${apps.length}个应用');

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
