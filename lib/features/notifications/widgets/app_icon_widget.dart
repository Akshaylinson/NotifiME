import 'dart:io';
import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final String? iconPath;
  final String appName;
  final double size;
  final double borderRadius;
  final bool showShadow;

  const AppIconWidget({
    super.key,
    this.iconPath,
    required this.appName,
    this.size = 64,
    this.borderRadius = 18,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildIconContent(context),
      ),
    );
  }

  Widget _buildIconContent(BuildContext context) {
    // Try to load the actual app icon
    if (iconPath != null && iconPath!.isNotEmpty) {
      final file = File(iconPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar(context);
          },
        );
      }
    }

    // Fallback to letter avatar
    return _buildFallbackAvatar(context);
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          appName.isNotEmpty ? appName[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4375,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
