import 'dart:io';
import 'package:flutter/material.dart';
import '../models/app_info.dart';

class AppIconWidget extends StatefulWidget {
  final AppInfo appInfo;
  final bool isGridView;
  final VoidCallback? onTap;
  final Function(Offset)? onSecondaryTap;

  const AppIconWidget({
    super.key,
    required this.appInfo,
    this.isGridView = true,
    this.onTap,
    this.onSecondaryTap,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isGridView) {
      return _buildGridItem(context);
    } else {
      return _buildListItem(context);
    }
  }

  Widget _buildGridItem(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapDown: widget.onSecondaryTap != null
            ? (details) => widget.onSecondaryTap!(details.globalPosition)
            : null,
        child: Container(
          width: 100,
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: _isHovering
                ? Border.all(
                    color: Colors.blue.shade400,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(64),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  widget.appInfo.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapDown: widget.onSecondaryTap != null
            ? (details) => widget.onSecondaryTap!(details.globalPosition)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: _isHovering
                ? Border(
                    left: BorderSide(
                      color: Colors.blue.shade400,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              _buildIcon(40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appInfo.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.appInfo.bundleId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.appInfo.bundleId!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(double size) {
    if (widget.appInfo.iconPath != null && File(widget.appInfo.iconPath!).existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.2),
          image: DecorationImage(
            image: FileImage(File(widget.appInfo.iconPath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 默认图标
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
        ),
      ),
      child: Icon(
        Icons.apps,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}