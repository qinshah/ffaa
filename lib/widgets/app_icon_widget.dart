import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';

class AppIconWidget extends StatefulWidget {
  final App app;
  final bool isGridView;
  final ValueNotifier<App?> selectedAppNotifier;
  final VoidCallback? appLaunchCall;
  final Function(Offset) appContextMenuBuilder;
  final String searchText;

  const AppIconWidget({
    super.key,
    required this.app,
    this.isGridView = true,
    this.appLaunchCall,
    required this.searchText,
    required this.appContextMenuBuilder,
    required this.selectedAppNotifier,
  });

  static final _iconCache = <String, Widget>{};

  static void clearIconCache() => _iconCache.clear();

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  final _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.appLaunchCall,
      onSecondaryTapDown: (details) {
        widget.appContextMenuBuilder(details.globalPosition);
      },
      onLongPressStart: (details) async {
        widget.selectedAppNotifier.value = widget.app;
        widget.appContextMenuBuilder(details.globalPosition);
      },
      child: MouseRegion(
        onHover: (event) {
          if (!_node.hasFocus) {
            _node.requestFocus();
          }
        },
        child: ValueListenableBuilder(
            valueListenable: widget.selectedAppNotifier,
            builder: (context, selectApp, child) {
              final isSelected =
                  widget.app.packageName == selectApp?.packageName;
              return Focus(
                focusNode: _node,
                onFocusChange: (hasFocus) {
                  if (hasFocus && !isSelected) {
                    widget.selectedAppNotifier.value = widget.app;
                  }
                   else if (isSelected && !hasFocus) {
                    widget.selectedAppNotifier.value = null;
                  }
                },
                child: widget.isGridView
                    ? _buildGridItem(context, isSelected)
                    : _buildListItem(context, isSelected),
              );
            }),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, bool isSelected) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: _cacheableIcon(64),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text.rich(
            _buildHighlightedText(primaryColor),
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

  Widget _buildListItem(BuildContext context, bool isSelected) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? primaryColor.withAlpha(200) : null,
      ),
      child: Row(
        children: [
          _cacheableIcon(40),
          const SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              _buildHighlightedText(primaryColor),
              style: TextStyle(
                color: isSelected ? Colors.white : null,
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

  // TODO 字符串匹配算法
  TextSpan _buildHighlightedText(Color primaryColor) {
    if (widget.searchText.isEmpty) {
      return TextSpan(text: widget.app.name);
    } else if (widget.searchText.length == 1) {
      return TextSpan(children: [
        TextSpan(
          text: widget.app.name.substring(0, 1),
          style: TextStyle(color: primaryColor),
        ),
        TextSpan(text: widget.app.name.substring(1)),
      ]);
    }
    final List<TextSpan> spans = [];
    final String lowerText = widget.app.name.toLowerCase();
    final String lowerSearchText = widget.searchText.toLowerCase();
    int start = 0;
    int index = lowerText.indexOf(lowerSearchText, start);
    while (index >= 0) {
      // 添加匹配前的文本
      if (index > start) {
        spans.add(TextSpan(text: widget.app.name.substring(start, index)));
      }
      // 添加高亮的匹配文本
      spans.add(TextSpan(
        text:
            widget.app.name.substring(index, index + widget.searchText.length),
        style: TextStyle(color: primaryColor),
      ));
      start = index + widget.searchText.length;
      index = lowerText.indexOf(lowerSearchText, start);
    }
    // 添加剩余的文本
    if (start < widget.app.name.length) {
      spans.add(TextSpan(text: widget.app.name.substring(start)));
    }
    return TextSpan(children: spans);
  }

  Widget _cacheableIcon(double size) {
    final cachedIcon = AppIconWidget._iconCache[widget.app.packageName];
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
          AppIconWidget._iconCache[widget.app.packageName] = icon;
          return SizedBox(width: size, height: size, child: icon);
        },
      );
    }
  }
}
