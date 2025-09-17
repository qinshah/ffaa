import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../services/platform_service.dart';
import '../widgets/app_icon_widget.dart';
import '../utils/app_launcher.dart';

enum ViewMode { grid, list }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AppInfo> _apps = [];
  bool _isLoading = true;
  String? _error;
  ViewMode _viewMode = ViewMode.grid;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apps = await PlatformService.getInstalledApps();
      setState(() {
        _apps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<AppInfo> get _filteredApps {
    if (_searchQuery.isEmpty) {
      return _apps;
    }
    return _apps.where((app) {
      return app.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (app.bundleId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    });
  }

  Future<void> _launchApp(AppInfo app) async {
    final success = await AppLauncher.launchApp(app);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '正在启动 ${app.name}' : '启动 ${app.name} 失败'),
          duration: const Duration(seconds: 1),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showAppContextMenu(AppInfo app, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.launch, size: 18),
              SizedBox(width: 8),
              Text('打开'),
            ],
          ),
          onTap: () => _launchApp(app),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.folder_open, size: 18),
              SizedBox(width: 8),
              Text('在Finder中显示'),
            ],
          ),
          onTap: () => AppLauncher.openAppInFinder(app),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18),
              SizedBox(width: 8),
              Text('应用信息'),
            ],
          ),
          onTap: () => _showAppInfo(app),
        ),
      ],
    );
  }

  void _showAppInfo(AppInfo app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(app.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (app.bundleId != null) ...[
              Text('Bundle ID: ${app.bundleId}'),
              const SizedBox(height: 8),
            ],
            if (app.version != null) ...[
              Text('版本: ${app.version}'),
              const SizedBox(height: 8),
            ],
            Text('路径: ${app.path}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.apps, size: 24),
            SizedBox(width: 8),
            Text(
              '应用程序',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: _toggleViewMode,
            tooltip: _viewMode == ViewMode.grid ? '列表视图' : '网格视图',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索应用...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // 应用列表
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载应用列表...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadApps,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final filteredApps = _filteredApps;
    if (filteredApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? '没有找到应用' : '没有匹配的应用',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_viewMode == ViewMode.grid) {
      return _buildGridView(filteredApps);
    } else {
      return _buildListView(filteredApps);
    }
  }

  Widget _buildGridView(List<AppInfo> apps) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppIconWidget(
          appInfo: apps[index],
          isGridView: true,
          onTap: () => _launchApp(apps[index]),
          onSecondaryTap: (position) => _showAppContextMenu(apps[index], position),
        );
      },
    );
  }

  Widget _buildListView(List<AppInfo> apps) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppIconWidget(
          appInfo: apps[index],
          isGridView: false,
          onTap: () => _launchApp(apps[index]),
          onSecondaryTap: (position) => _showAppContextMenu(apps[index], position),
        );
      },
    );
  }
}