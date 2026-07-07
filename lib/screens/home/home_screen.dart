import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/warranty_device.dart';
import '../../providers/devices_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/device_card.dart';
import '../../widgets/page_background.dart';
import '../../widgets/vault_ui.dart';
import '../devices/device_detail_screen.dart';
import '../devices/device_form_sheet.dart';
import '../main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DevicesProvider>();
    final shop = context.watch<ShopProvider>();
    final expired = devices.expiredDevices;
    final expiring = devices.expiringSoonDevices;
    final active = devices.activeDevices;
    final myDevices = devices.devices.take(4).toList();

    return PageBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _HeroHeader(total: devices.totalCount)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _StatsPanel(
                  showStats: shop.hasStatsPro,
                  expiredCount: expired.length,
                  expiringCount: expiring.length,
                  activeCount: active.length,
                  totalCount: devices.totalCount,
                ),
              ),
            ),
            if (devices.totalCount == 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _EmptyCard(),
                ),
              )
            else ...[
              if (myDevices.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: _MyDevicesSection(devices: myDevices),
                  ),
                ),
              ..._buildWarrantySlivers(context, shop, expired, expiring),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 130)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWarrantySlivers(
    BuildContext context,
    ShopProvider shop,
    List<WarrantyDevice> expired,
    List<WarrantyDevice> expiring,
  ) {
    final slivers = <Widget>[];

    if (expired.isNotEmpty) {
      slivers.addAll(_section(context, shop, AppStrings.t(context, 'expiredWarranties'), AppColors.expired, expired, 3, 'expired'));
    }
    if (expiring.isNotEmpty) {
      slivers.addAll(_section(context, shop, AppStrings.t(context, 'expiringSoon'), AppColors.expiringSoon, expiring, 5, 'expiring'));
    }

    return slivers;
  }

  List<Widget> _section(
    BuildContext context,
    ShopProvider shop,
    String title,
    Color color,
    List<WarrantyDevice> items,
    int showCount,
    String filter,
  ) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: VaultSectionLabel(
            title: title,
            dotColor: color,
            action: AppStrings.t(context, 'viewAll'),
            onAction: () => MainShell.of(context)?.openDevices(filter: filter),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WarrantyReminderCard(
                device: items[i],
                highlight: shop.hasWarrantyAlert,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DeviceDetailScreen(deviceId: items[i].id)),
                ),
              ),
            ),
            childCount: showCount.clamp(0, items.length),
          ),
        ),
      ),
    ];
  }
}

class _HeroHeader extends StatelessWidget {
  final int total;

  const _HeroHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t(context, 'homeGreeting'),
                  style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.t(context, 'appName'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1),
                ),
              ],
            ),
          ),
          const CoinBalanceChip(),
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final bool showStats;
  final int expiredCount;
  final int expiringCount;
  final int activeCount;
  final int totalCount;

  const _StatsPanel({
    required this.showStats,
    required this.expiredCount,
    required this.expiringCount,
    required this.activeCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return VaultCard(
      accentColor: null,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: totalCount.toString(),
                  label: AppStrings.t(context, 'totalDevices'),
                  icon: Icons.layers_outlined,
                  color: AppColors.primary,
                  onTap: () => MainShell.of(context)?.openDevices(),
                ),
              ),
              _divider(),
              Expanded(
                child: _StatCell(
                  value: expiringCount.toString(),
                  label: AppStrings.t(context, 'expiringSoon'),
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.expiringSoon,
                  onTap: () => MainShell.of(context)?.openDevices(filter: 'expiring'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: expiredCount.toString(),
                  label: AppStrings.t(context, 'expiredWarranties'),
                  icon: Icons.error_outline_rounded,
                  color: AppColors.expired,
                  onTap: () => MainShell.of(context)?.openDevices(filter: 'expired'),
                ),
              ),
              _divider(),
              Expanded(
                child: _StatCell(
                  value: showStats ? activeCount.toString() : '—',
                  label: showStats ? AppStrings.t(context, 'activeWarranties') : AppStrings.t(context, 'statsProLocked'),
                  icon: showStats ? Icons.verified_outlined : Icons.lock_outline_rounded,
                  color: showStats ? AppColors.active : AppColors.onSurfaceVariant,
                  onTap: showStats
                      ? () => MainShell.of(context)?.openDevices(filter: 'active')
                      : () => MainShell.of(context)?.openShop(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => DeviceFormSheet.show(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(AppStrings.t(context, 'addDevice')),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 52, margin: const EdgeInsets.symmetric(horizontal: 8), color: AppColors.surfaceVariant);
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, height: 1.15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyDevicesSection extends StatelessWidget {
  final List<WarrantyDevice> devices;

  const _MyDevicesSection({required this.devices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VaultSectionLabel(
          title: AppStrings.t(context, 'homeMyDevices'),
          action: AppStrings.t(context, 'homeViewAllDevices'),
          onAction: () => MainShell.of(context)?.openDevices(),
        ),
        ...devices.map(
          (device) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DeviceCard(
              device: device,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeviceDetailScreen(deviceId: device.id)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VaultCard(
      radius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.55)),
          const SizedBox(height: 12),
          Text(
            AppStrings.t(context, 'homeNoDevicesYet'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.t(context, 'noWarrantyHint'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
