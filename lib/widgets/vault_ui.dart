import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/shop_provider.dart';

/// Ambient mesh orbs behind screens.
class VaultMeshBackground extends StatelessWidget {
  final Widget child;
  final bool showOrbs;

  const VaultMeshBackground({super.key, required this.child, this.showOrbs = true});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? shop.activeTheme.darkBackground : shop.activeTheme.background;
    final accent = shop.activeBackground.gradient.colors.first;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: base)),
        if (showOrbs) ...[
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(color: accent.withValues(alpha: isDark ? 0.22 : 0.18), size: 260),
          ),
          Positioned(
            top: 120,
            left: -90,
            child: _Orb(color: AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.10), size: 200),
          ),
          Positioned(
            bottom: 80,
            right: -40,
            child: _Orb(color: AppColors.accentAlt.withValues(alpha: isDark ? 0.08 : 0.07), size: 180),
          ),
        ],
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;

  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

/// Elevated card with optional accent stripe.
class VaultCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool glass;

  const VaultCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.glass = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface.withValues(alpha: glass ? 0.72 : 1) : AppColors.surface.withValues(alpha: glass ? 0.82 : 1);

    Widget card = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: (accentColor ?? AppColors.primary).withValues(alpha: isDark ? 0.10 : 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            if (accentColor != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: accentColor),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    if (glass) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: card,
        ),
      );
    }

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: card),
    );
  }
}

class VaultSectionLabel extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Color? dotColor;

  const VaultSectionLabel({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor ?? AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: (dotColor ?? AppColors.primary).withValues(alpha: 0.45), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
          ),
          if (action != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class VaultStatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool large;

  const VaultStatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return VaultCard(
      onTap: onTap,
      accentColor: color,
      padding: EdgeInsets.all(large ? 20 : 14),
      radius: large ? 24 : 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: large ? 22 : 18),
          ),
          SizedBox(height: large ? 16 : 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: large ? 32 : 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: isDark ? Colors.white : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: large ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class VaultActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const VaultActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return VaultCard(
      onTap: onTap,
      accentColor: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      radius: 18,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class VaultSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;

  const VaultSearchField({
    super.key,
    this.controller,
    this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary.withValues(alpha: 0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class VaultFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  const VaultFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 6)],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
