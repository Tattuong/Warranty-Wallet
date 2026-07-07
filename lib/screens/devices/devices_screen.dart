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

    return PageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: VaultCard(
                    accentColor: AppColors.accent,
                    radius: 26,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.t(context, 'devicesTitle'),
                                style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                limit > 0
                                    ? '${devices.totalCount}/$limit ${AppStrings.t(context, 'navDevices').toLowerCase()}'
                                    : '${devices.totalCount} ${AppStrings.t(context, 'navDevices').toLowerCase()}',
                                style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        if (devices.totalCount > 0) ...[
                          _HeaderAddButton(
                            tooltip: AppStrings.t(context, 'addDevice'),
                            onPressed: () => _handleAdd(context, canAdd, limit),
                          ),
                          const SizedBox(width: 10),
                        ],
                        const CoinBalanceChip(),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: VaultCard(
                      accentColor: AppColors.upcoming,
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        AppStrings.t(context, 'advancedFiltersLocked'),
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              if (list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: VaultCard(
                        accentColor: AppColors.primary,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 52, color: AppColors.primary.withValues(alpha: 0.7)),
                            const SizedBox(height: 12),
                            Text(AppStrings.t(context, 'noResults'), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => _handleAdd(context, canAdd, limit),
                              icon: const Icon(Icons.add_rounded),
                              label: Text(AppStrings.t(context, 'addDevice')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
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
        elevation: 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.35),
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
