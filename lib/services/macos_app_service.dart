import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:process/process.dart';
import '../models/app_info.dart';

class MacOSAppService {
  static const ProcessManager _processManager = LocalProcessManager();

  // 应用目录列表
  static const List<String> _appDirectories = [
    '/Applications',
    '/System/Applications',
  ];

  static Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<AppInfo> apps = [];

      // 扫描所有应用目录
      for (final String dirPath in _appDirectories) {
        final Directory dir = Directory(dirPath);
        if (await dir.exists()) {
          debugPrint('正在扫描目录: $dirPath');
          await _scanDirectoryRecursively(dir, apps);
        }
      }

      // 添加用户应用目录（如果存在）
      final String? homeDir = Platform.environment['HOME'];
      if (homeDir != null) {
        final Directory userAppsDir = Directory('$homeDir/Applications');
        if (await userAppsDir.exists()) {
          debugPrint('正在扫描用户应用目录: ${userAppsDir.path}');
          await _scanDirectoryRecursively(userAppsDir, apps);
        }
      }

      debugPrint('共扫描出${apps.length}个应用');

      // 按应用名称排序
      apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return apps;
    } catch (e) {
      debugPrint('扫描应用时出错: $e');
      return [];
    }
  }

  /// 递归扫描目录中的应用
  static Future<void> _scanDirectoryRecursively(
      Directory directory, List<AppInfo> apps,
      {int depth = 0}) async {
    try {
      // 限制递归深度，避免无限递归
      if (depth > 3) return;

      await for (final FileSystemEntity entity in directory.list()) {
        if (entity is Directory) {
          if (entity.path.endsWith('.app')) {
            // 找到应用，解析应用信息
            final appInfo = await _getAppInfo(entity);
            if (appInfo != null) {
              apps.add(appInfo);
              debugPrint('找到应用: ${appInfo.name} (${entity.path})');
            }
          } else {
            // 普通文件夹，继续递归扫描
            try {
              await _scanDirectoryRecursively(entity, apps, depth: depth + 1);
            } catch (e) {
              // 忽略无权限访问的目录
              debugPrint('无法访问目录 ${entity.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('扫描目录 ${directory.path} 时出错: $e');
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
            // TODO 个别应用图标加载不出来
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
