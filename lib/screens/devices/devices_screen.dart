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
import '../main_shell.dart';
import '../shop/shop_screen.dart';
import 'device_detail_screen.dart';
import 'device_form_sheet.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  static DevicesScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<DevicesScreenState>();

  @override
  State<DevicesScreen> createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  final _searchCtrl = TextEditingController();

  void setFilter(String filter) {
    context.read<DevicesProvider>().setFilter(filter);
  }

  void setCategoryFilter(String? category) {
    context.read<DevicesProvider>().setCategoryFilter(category);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DevicesProvider>();
    final shop = context.watch<ShopProvider>();
    final list = devices.filteredDevices;
    final limit = devices.deviceLimit(shop);
    final canAdd = devices.canAddDevice(shop);
    final hasDevices = devices.totalCount > 0;
    final isFilteredEmpty = hasDevices && list.isEmpty;

    return PageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _DevicesHeader(
                  countLabel: limit > 0
                      ? '${devices.totalCount}/$limit ${AppStrings.t(context, 'navDevices').toLowerCase()}'
                      : '${devices.totalCount} ${AppStrings.t(context, 'navDevices').toLowerCase()}',
                  showAdd: hasDevices,
                  onAdd: () => _handleAdd(context, canAdd, limit),
                ),
              ),
              if (hasDevices) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: VaultSearchField(
                      controller: _searchCtrl,
                      onChanged: devices.setSearchQuery,
                      hint: AppStrings.t(context, 'search'),
                    ),
                  ),
                ),
                if (shop.hasAdvancedFilters) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final entry in [
                              ('all', 'filterAll'),
                              ('expired', 'filterExpired'),
                              ('expiring', 'filterExpiring'),
                              ('active', 'filterActive'),
                            ])
                              VaultFilterPill(
                                label: AppStrings.t(context, entry.$2),
                                selected: devices.filter == entry.$1,
                                onTap: () {
                                  devices.setFilter(entry.$1);
                                  devices.setCategoryFilter(null);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            VaultFilterPill(
                              label: AppStrings.t(context, 'filterAll'),
                              selected: devices.categoryFilter == null,
                              onTap: () => devices.setCategoryFilter(null),
                            ),
                            for (final cat in DeviceCategory.values)
                              VaultFilterPill(
                                label: AppStrings.t(context, cat.labelKey),
                                selected: devices.categoryFilter == cat.name,
                                leading: Text(WarrantyDevice.emojiForCategory(cat.name), style: const TextStyle(fontSize: 14)),
                                onTap: () => devices.setCategoryFilter(cat.name),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else
                  const SliverToBoxAdapter(child: _UnlockFiltersRow()),
              ],
              if (list.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                    child: _DevicesEmptyCard(
                      filtered: isFilteredEmpty,
                      onAdd: () => _handleAdd(context, canAdd, limit),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final device = list[i];
                      DeviceHighlight? highlight;
                      if (shop.hasWarrantyAlert) {
                        if (device.warrantyStatus == WarrantyStatus.expired) {
                          highlight = DeviceHighlight.expired;
                        } else if (device.warrantyStatus == WarrantyStatus.expiringSoon) {
                          highlight = DeviceHighlight.expiringSoon;
                        }
                      }
                      return DeviceCard(
                        device: device,
                        highlight: highlight,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DeviceDetailScreen(deviceId: device.id)),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAdd(BuildContext context, bool canAdd, int limit) {
    if (!canAdd) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(AppStrings.t(context, 'addDevice')),
          content: Text(AppStrings.t(context, 'deviceLimitReached', {'limit': limit.toString()})),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.t(context, 'cancel'))),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                MainShell.of(context)?.openShop(tab: ShopRewardsTab.features);
              },
              child: Text(AppStrings.t(context, 'navShop')),
            ),
          ],
        ),
      );
      return;
    }
    DeviceFormSheet.show(context);
  }
}

class _DevicesHeader extends StatelessWidget {
  final String countLabel;
  final bool showAdd;
  final VoidCallback onAdd;

  const _DevicesHeader({
    required this.countLabel,
    required this.showAdd,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t(context, 'devicesTitle'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  countLabel,
                  style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          if (showAdd) ...[
            _HeaderAddButton(
              tooltip: AppStrings.t(context, 'addDevice'),
              onPressed: onAdd,
            ),
            const SizedBox(width: 10),
          ],
          const CoinBalanceChip(),
        ],
      ),
    );
  }
}

class _UnlockFiltersRow extends StatelessWidget {
  const _UnlockFiltersRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: VaultCard(
        onTap: () => MainShell.of(context)?.openShop(tab: ShopRewardsTab.features),
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.upcoming.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.filter_alt_outlined, color: AppColors.upcoming, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.t(context, 'advancedFiltersLocked'),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.t(context, 'advancedFiltersLockedDesc'),
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, height: 1.25),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

class _DevicesEmptyCard extends StatelessWidget {
  final bool filtered;
  final VoidCallback onAdd;

  const _DevicesEmptyCard({required this.filtered, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return VaultCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      child: Column(
        children: [
          Icon(
            filtered ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.t(context, filtered ? 'noResults' : 'devicesEmptyTitle'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.t(context, filtered ? 'noResultsHint' : 'devicesEmptyHint'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.4),
          ),
          if (!filtered) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(AppStrings.t(context, 'addDevice')),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderAddButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderAddButton({required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
