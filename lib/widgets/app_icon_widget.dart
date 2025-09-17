import 'dart:io';
import 'package:flutter/material.dart';
import '../models/app_info.dart';

class AppIconWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridItem(context);
    } else {
      return _buildListItem(context);
    }
  }

  Widget _buildGridItem(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onSecondaryTapDown: onSecondaryTap != null
          ? (details) => onSecondaryTap!(details.globalPosition)
          : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(64),
            const SizedBox(height: 8),
            Text(
              appInfo.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onSecondaryTapDown: onSecondaryTap != null
          ? (details) => onSecondaryTap!(details.globalPosition)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _buildIcon(40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appInfo.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (appInfo.bundleId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      appInfo.bundleId!,
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
    );
  }

  Widget _buildIcon(double size) {
    if (appInfo.iconPath != null && File(appInfo.iconPath!).existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.2),
          image: DecorationImage(
            image: FileImage(File(appInfo.iconPath!)),
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