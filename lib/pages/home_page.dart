import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/nav.dart';
import '../main.dart';
import '../models/app_info.dart';
import '../services/app_list_service.dart';
import '../widgets/app_icon_widget.dart';
import '../utils/app_launcher.dart';
import 'settings_page.dart';

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
    _getApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getApps() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apps = await AppListService.getInstalledApps();
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
    return _apps
        .where((app) =>
            app.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    });
  }

  Future<void> _launchApp(AppInfo app) async {
    AppLauncher.launchApp(app).then((succeeded) {
      if (succeeded) {
        windowManager.hide();
        debugPrint('隐藏窗口(启动app后)');
      } else {
        // TODO 应用启动失败的处理
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('启动 ${app.name} 失败'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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

  // late final _primaryColor = Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(children: [
        _buildAppBar(),
        Expanded(child: _buildContent()),
      ]),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        IconButton(
          icon: Icon(
              _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view),
          onPressed: _toggleViewMode,
          tooltip: _viewMode == ViewMode.grid ? '列表视图' : '网格视图',
        ),
        Expanded(
          child: TextField(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            autofocus: true,
            focusNode: FfaaApp.searchInputNode,
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索应用',
              hintStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: FocusScope(
                canRequestFocus: false,
                child: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _searchQuery.isEmpty
                      ? null
                      : () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        FocusScope(
          canRequestFocus: false,
          child: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => context.push(SettingsPage()),
          ),
        ),
      ]),
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
              onPressed: _getApps,
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
    // TODO 换用更流畅的宫格视图
    return GridView.builder(
      key: PageStorageKey('GridView'),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisExtent: 120,
        childAspectRatio: 1,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppIconWidget(
          appInfo: apps[index],
          isGridView: true,
          onTap: () => _launchApp(apps[index]),
          onSecondaryTap: (position) =>
              _showAppContextMenu(apps[index], position),
        );
      },
    );
  }

  Widget _buildListView(List<AppInfo> apps) {
    return ListView.builder(
      key: PageStorageKey('ListView'),
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppIconWidget(
          appInfo: apps[index],
          isGridView: false,
          onTap: () => _launchApp(apps[index]),
          onSecondaryTap: (position) =>
              _showAppContextMenu(apps[index], position),
        );
      },
    );
  }
}
