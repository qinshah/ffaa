import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/const.dart';
import '../utils/nav.dart';
import '../main.dart';
import '../widgets/app_icon_widget.dart';
import '../utils/app_launcher.dart';
import 'settings/settings_page.dart';

enum ViewMode { grid, list }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<App> _apps = [];
  List<App> _filteredApps = [];
  final _selectAppNotifier = ValueNotifier<App?>(null);
  bool _isLoading = true;
  String? _error;
  ViewMode _viewMode = ViewMode.grid;
  final TextEditingController _searchCntlr = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getApps();
  }

  @override
  void dispose() {
    _searchCntlr.dispose();
    super.dispose();
  }

  Future<void> _getApps() async {
    setState(() {
      _isLoading = true;
      _error = null;
      AppIconWidget.clearIconCache(); // 清空图标缓存
    });
    try {
      final apps = await appManager.getApps();
      _apps = apps;
      _filterApp();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterApp() {
    final result = switch (_searchCntlr.text.length) {
      0 => _apps,
      1 => _apps
          .where((app) => app.name
              .toLowerCase()
              .startsWith(_searchCntlr.text.toLowerCase()))
          .toList(),
      _ => _apps
          .where((app) =>
              app.name.toLowerCase().contains(_searchCntlr.text.toLowerCase()))
          .toList(),
    };
    setState(() {
      _isLoading = false;
      _filteredApps = result;
      _selectAppNotifier.value = result.firstOrNull;
    });
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    });
  }

  Future<void> _launchSelecterApp() async {
    final selectedApp = _selectAppNotifier.value;
    if (selectedApp == null) return;
    try {
      if (Const.isPC) {
        windowManager.hide();
        debugPrint('启动app后隐藏窗口');
      }
      await AppLauncher.launchApp(selectedApp);
    } catch (e) {
      // TODO 应用启动失败的处理
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('启动 ${selectedApp.name} 失败: $e'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAppContextMenu(App app, Offset position) {
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
          onTap: () => _launchSelecterApp(),
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

  void _showAppInfo(App app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(app.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bundle ID: ${app.packageName}'),
            const SizedBox(height: 8),
            Text('版本: ${app.version ?? '未知'}'),
            const SizedBox(height: 8),
            Text('路径: ${app.path ?? '未知'}'),
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
    return Focus(
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: Column(children: [
          _buildAppBar(),
          Expanded(child: _buildContent()),
        ]),
      ),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        switch (event.logicalKey) {
          case LogicalKeyboardKey.enter: // 回车启动应用
            _launchSelecterApp();
            if (_selectAppNotifier.value != null) {
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          case LogicalKeyboardKey.backspace: // 聚焦搜索框
            if (FfaaApp.searchInputNode.hasFocus) {
              return KeyEventResult.ignored;
            }
            FfaaApp.searchInputNode.requestFocus();
            return KeyEventResult.handled;
          // TODO 光标在末尾时右方向键可切换应用
          case LogicalKeyboardKey.arrowDown: // 切换应用 // TODO 会打断输入法
            if (FfaaApp.searchInputNode.hasFocus) {
              FfaaApp.searchInputNode.nextFocus();
              return KeyEventResult.handled;
            } else {
              return KeyEventResult.ignored;
            }
          default:
            return KeyEventResult.ignored;
        }
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        IconButton(
          focusNode: FocusNode(skipTraversal: true),
          icon: Icon(Icons.refresh),
          onPressed: _getApps,
          tooltip: '刷新',
        ),
        Expanded(
          child: TextField(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            focusNode: FfaaApp.searchInputNode,
            controller: _searchCntlr,
            decoration: InputDecoration(
              hintText: '搜索应用',
              hintStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                focusNode: FocusNode(skipTraversal: true),
                icon: const Icon(Icons.clear),
                onPressed: _searchCntlr.text.isEmpty
                    ? null
                    : () {
                        _searchCntlr.clear();
                        _filterApp();
                      },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            onChanged: (_) => _filterApp(),
          ),
        ),
        IconButton(
          focusNode: FocusNode(skipTraversal: true),
          icon: Icon(
            _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view,
          ),
          onPressed: _toggleViewMode,
          tooltip: _viewMode == ViewMode.grid ? '列表视图' : '网格视图',
        ),
        IconButton(
          focusNode: FocusNode(skipTraversal: true),
          icon: Icon(Icons.settings),
          onPressed: () => context.push(SettingsPage()),
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

    if (_filteredApps.isEmpty) {
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
              '没有找到应用',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 使用FocusScope修复丢换app可能丢失焦点的bug
    // 因为这样能让所有app的焦点都存在FocusScope中，不会切到非app焦点导致焦点丢失
    return FocusScope(
      child: _viewMode == ViewMode.grid
          ? _buildGridView(_filteredApps)
          : _buildListView(_filteredApps),
    );
  }

  Widget _buildGridView(List<App> apps) {
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
          app: apps[index],
          searchText: _searchCntlr.text,
          isGridView: true,
          appLaunchCall: _launchSelecterApp,
          appContextMenuBuilder: (position) {
            _showAppContextMenu(apps[index], position);
          },
          selectedAppNotifier: _selectAppNotifier,
        );
      },
    );
  }

  Widget _buildListView(List<App> apps) {
    return ListView.builder(
      key: PageStorageKey('ListView'),
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppIconWidget(
          app: apps[index],
          searchText: _searchCntlr.text,
          selectedAppNotifier: _selectAppNotifier,
          isGridView: false,
          appLaunchCall: _launchSelecterApp,
          appContextMenuBuilder: (position) =>
              _showAppContextMenu(apps[index], position),
        );
      },
    );
  }
}
