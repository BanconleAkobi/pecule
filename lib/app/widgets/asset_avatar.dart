import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/domain/models/asset.dart';

/// Pastille d'un actif : ses initiales dans la couleur de son type, sur un
/// fond de cette couleur légèrement teinté.
class AssetAvatar extends StatelessWidget {
  const AssetAvatar({super.key, required this.asset, this.size = 42});

  static const _maxInitials = 3;
  static const _tintOpacity = 0.14;

  final Asset asset;
  final double size;

  String get initials => asset.symbol.length > _maxInitials
      ? asset.symbol.substring(0, _maxInitials)
      : asset.symbol;

  @override
  Widget build(BuildContext context) {
    final color = context.peculeColors.forAssetType(asset.type);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: _tintOpacity),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.29,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
