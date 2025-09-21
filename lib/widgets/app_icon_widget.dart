import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'package:app_list/app_list.dart';

class AppIconWidget extends StatefulWidget {
  final AppInfo appInfo;
  final bool isGridView;
  final VoidCallback? onTap;
  final Function(Offset) onSecondaryTap;

  const AppIconWidget({
    super.key,
    required this.appInfo,
    this.isGridView = true,
    this.onTap,
    required this.onSecondaryTap,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
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
        onFocusChange: (value) => setState(() => _isFocus = value),
        onKeyEvent: (node, event) {
          // 回车键启动应用
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap?.call();
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
          onTap: widget.onTap,
          onSecondaryTapDown: (details) {
            widget.onSecondaryTap(details.globalPosition);
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
          child: _buildIcon(64),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            widget.appInfo.name,
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
          _buildIcon(40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.appInfo.name,
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

  // TODO 图标统一尺寸和形状
  Widget _buildIcon(double size) {
    if (widget.appInfo.iconPath != null &&
        File(widget.appInfo.iconPath!).existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.2),
          image: DecorationImage(
            image: FileImage(File(widget.appInfo.iconPath!)),
          ),
        ),
      );
    }

    // 默认图标
    return Icon(Icons.error, size: size, color: Colors.grey);
  }
}
