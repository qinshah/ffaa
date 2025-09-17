class AppInfo {
  final String name;
  final String path;
  final String? bundleId;
  final String? iconPath;
  final String? version;

  AppInfo({
    required this.name,
    required this.path,
    this.bundleId,
    this.iconPath,
    this.version,
  });

  @override
  String toString() {
    return 'AppInfo(name: $name, path: $path, bundleId: $bundleId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppInfo &&
        other.name == name &&
        other.path == path &&
        other.bundleId == bundleId;
  }

  @override
  int get hashCode => name.hashCode ^ path.hashCode ^ bundleId.hashCode;
}