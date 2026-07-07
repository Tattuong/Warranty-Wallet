import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/warranty_device.dart';
import '../providers/shop_provider.dart';
import 'vault_ui.dart';

enum DeviceHighlight { expired, expiringSoon }

class DeviceCard extends StatelessWidget {
  final WarrantyDevice device;
  final VoidCallback? onTap;
  final DeviceHighlight? highlight;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final skin = shop.activeSkin;
    final dateFmt = DateFormat.yMMMd();
    final status = device.warrantyStatus;

    final accent = switch (highlight) {
      DeviceHighlight.expired => AppColors.expired,
      DeviceHighlight.expiringSoon => AppColors.expiringSoon,
      _ => switch (status) {
          WarrantyStatus.expired => AppColors.expired,
          WarrantyStatus.expiringSoon => AppColors.expiringSoon,
          WarrantyStatus.active => AppColors.active,
        },
    };

    return VaultCard(
      onTap: onTap,
      accentColor: accent,
      radius: skin.borderRadius,
      glass: skin.blur > 0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DeviceAvatar(emoji: device.emoji, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppStrings.t(context, device.deviceCategory.labelKey),
                      style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              _WarrantyBadge(status: status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetaPill(icon: Icons.qr_code_2_rounded, label: device.serialNumber.isNotEmpty ? device.serialNumber : AppStrings.t(context, 'noSerial')),
              const SizedBox(width: 8),
              _MetaPill(icon: Icons.event_available_rounded, label: dateFmt.format(device.warrantyExpiryDate)),
            ],
          ),
          if (device.tags.isNotEmpty && shop.hasCustomTags) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: device.tags.asMap().entries.map((e) {
                final color = AppColors.tagPalette[e.key % AppColors.tagPalette.length];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    e.value,
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceAvatar extends StatelessWidget {
  final String emoji;
  final Color accent;

  const _DeviceAvatar({required this.emoji, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0.08)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}

class _WarrantyBadge extends StatelessWidget {
  final WarrantyStatus status;

  const _WarrantyBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (labelKey, color) = switch (status) {
      WarrantyStatus.expired => ('warrantyExpired', AppColors.expired),
      WarrantyStatus.expiringSoon => ('warrantyExpiringSoon', AppColors.expiringSoon),
      WarrantyStatus.active => ('warrantyActive', AppColors.active),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        AppStrings.t(context, labelKey),
        style: GoogleFonts.plusJakartaSans(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WarrantyReminderCard extends StatelessWidget {
  final WarrantyDevice device;
  final bool highlight;
  final VoidCallback? onTap;

  const WarrantyReminderCard({
    super.key,
    required this.device,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.MMMd();
    final status = device.warrantyStatus;

    final statusColor = switch (status) {
      WarrantyStatus.expired => AppColors.expired,
      WarrantyStatus.expiringSoon => AppColors.expiringSoon,
      WarrantyStatus.active => AppColors.active,
    };

    return VaultCard(
      onTap: onTap,
      accentColor: highlight ? statusColor : statusColor.withValues(alpha: 0.65),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _DeviceAvatar(emoji: device.emoji, accent: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(
                  device.serialNumber.isNotEmpty ? device.serialNumber : AppStrings.t(context, 'noSerial'),
                  style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateFmt.format(device.warrantyExpiryDate),
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor),
              ),
              if (status != WarrantyStatus.expired)
                Text(
                  AppStrings.t(context, 'daysLeft', {'count': device.daysUntilExpiry.toString()}),
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
