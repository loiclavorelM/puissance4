import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/initials.dart';

/// Avatar du joueur : sa photo si [thumbnailUrl] est renseigné, sinon ses
/// initiales (aussi tant que la photo charge, ou si elle ne charge pas).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.username,
    this.thumbnailUrl,
    this.radius = 24,
  });

  final String username;
  final String? thumbnailUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.fieldFill,
      foregroundImage: url != null ? NetworkImage(url) : null,
      // Photo injoignable : les initiales restent affichées dessous.
      onForegroundImageError: url != null ? (_, _) {} : null,
      child: Text(
        initialsOf(username),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }
}
