import 'dart:io';
import '../models/app_info.dart';
import 'mac_app_list_service.dart';

class AppListService {
  static Future<List<AppInfo>> getInstalledApps() async {
    switch (Platform.operatingSystem) {
      case 'macos':
        return await MacAppListService.getInstalledApps();
      case 'windows':
        // TODO: 实现Windows平台支持
        throw UnimplementedError('Windows平台暂未实现');
      case 'linux':
        // TODO: 实现Linux平台支持
        throw UnimplementedError('Linux平台暂未实现');
      case 'android':
        // TODO: 实现Android平台支持
        throw UnimplementedError('Android平台暂未实现');
      case 'ios':
        // TODO: 实现iOS平台支持
        throw UnimplementedError('iOS平台暂未实现');
      default:
        throw UnimplementedError('不支持的平台: ${Platform.operatingSystem}');
    }
  }
}