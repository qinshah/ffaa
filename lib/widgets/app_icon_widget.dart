import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class AppIconWidget extends StatefulWidget {
  final App app;
  final bool isGridView;
  final VoidCallback? appLaunchCall;
  final Function(Offset) appContextMenuBuilder;

  const AppIconWidget({
    super.key,
    required this.app,
    this.isGridView = true,
    this.appLaunchCall,
    required this.appContextMenuBuilder,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  static final _iconCache = <String, Widget>{};
  bool _isFocus = false;
  final _focusNode = FocusNode();
  late final _primaryColor = Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        if (!_isFocus) _focusNode.requestFocus();
      },
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (value) {
          if (_isFocus != value) setState(() => _isFocus = value);
        },
        onKeyEvent: (node, event) {
          // 回车键启动应用
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.appLaunchCall?.call();
            return KeyEventResult.handled;
          } else if (!FfaaApp.searchInputNode.hasFocus &&
              ![
                LogicalKeyboardKey.arrowLeft,
                LogicalKeyboardKey.arrowRight,
                LogicalKeyboardKey.arrowDown,
                LogicalKeyboardKey.arrowUp,
                LogicalKeyboardKey.tab,
              ].contains(event.logicalKey)) {
            // 自动聚焦搜索输入框
            FfaaApp.searchInputNode.requestFocus();
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.appLaunchCall,
          onSecondaryTapDown: (details) {
            widget.appContextMenuBuilder(details.globalPosition);
          },
          onLongPressStart: (details) async {
            await widget.appContextMenuBuilder(details.globalPosition);
            _focusNode.requestFocus();
          },
          child: widget.isGridView
              ? _buildGridItem(context)
              : _buildListItem(context),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocus ? _primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: _cacheableIcon(64),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            widget.app.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _isFocus ? _primaryColor.withAlpha(200) : null,
      ),
      child: Row(
        children: [
          _cacheableIcon(40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.app.name,
              style: TextStyle(
                color: _isFocus ? Colors.white : null,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cacheableIcon(double size) {
    final cachedIcon = _iconCache[widget.app.packageName];
    if (cachedIcon != null) {
      return SizedBox(width: size, height: size, child: cachedIcon);
    } else {
      return FutureBuilder(
        future: appManager.getAppIconProvider(widget.app),
        builder: (context, snapshot) {
          Widget icon;
          if (snapshot.hasError || snapshot.data == null) {
            icon = Icon(Icons.error);
          } else if (snapshot.hasData) {
            icon = Image(image: snapshot.data!);
          } else {
            icon = Icon(Icons.hourglass_empty);
          }
          _iconCache[widget.app.packageName] = icon;
          return SizedBox(width: size, height: size, child: icon);
        },
      );
    }
  }
}
