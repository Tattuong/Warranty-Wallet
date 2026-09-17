import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/devices_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../../widgets/page_background.dart';
import '../main_shell.dart';
import '../privacy_policy_screen.dart';
import '../shop/shop_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final devices = context.watch<DevicesProvider>();

    return PageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: Text(AppStrings.t(context, 'settingsTitle')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
        children: [
          _SectionTitle(AppStrings.t(context, 'activeCustomization')),
          _InfoTile(
            icon: Icons.palette_outlined,
            title: AppStrings.t(context, 'activeTheme'),
            subtitle: AppStrings.t(context, _themeNameKey(shop.activeThemeId)),
          ),
          _InfoTile(
            icon: Icons.layers_outlined,
            title: AppStrings.t(context, 'activeBackground'),
            subtitle: AppStrings.t(context, _bgNameKey(shop.activeBackgroundId)),
          ),
          _InfoTile(
            icon: Icons.style_outlined,
            title: AppStrings.t(context, 'activeSkin'),
            subtitle: AppStrings.t(context, _skinNameKey(shop.activeSkinId)),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.restart_alt_outlined, color: AppColors.primary),
            title: Text(AppStrings.t(context, 'resetToDefault')),
            subtitle: const Text('Theme, background & card skin'),
            onTap: () async {
              await shop.resetThemeToDefault();
              await shop.resetBackgroundToDefault();
              await shop.resetSkinToDefault();
              if (context.mounted) {
                AppToast.show(context, title: AppStrings.t(context, 'resetDefault'), icon: Icons.check_circle_outline);
              }
            },
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'appearance')),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(AppStrings.t(context, 'darkMode')),
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
          ),
          if (shop.hasRemoveAds)
            ListTile(
              leading: const Icon(Icons.block_outlined, color: AppColors.success),
              title: Text(AppStrings.t(context, 'shopRemoveAds')),
              subtitle: Text(AppStrings.t(context, 'removeAdsActive')),
              trailing: const Icon(Icons.check_circle_outline, color: AppColors.success),
            ),
          if (shop.hasStatsPro)
            ListTile(
              leading: const Icon(Icons.insights_outlined, color: AppColors.success),
              title: Text(AppStrings.t(context, 'shopFeatStatsPro')),
              subtitle: Text(AppStrings.t(context, 'statsProActive')),
              trailing: const Icon(Icons.check_circle_outline, color: AppColors.success),
            ),
          if (shop.hasWarrantyAlert)
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined, color: AppColors.success),
              title: Text(AppStrings.t(context, 'shopFeatWarrantyAlert')),
              subtitle: Text(AppStrings.t(context, 'warrantyAlertActive')),
              trailing: const Icon(Icons.check_circle_outline, color: AppColors.success),
            ),
          if (shop.hasCustomTags)
            ListTile(
              leading: const Icon(Icons.label_outlined, color: AppColors.success),
              title: Text(AppStrings.t(context, 'shopFeatCustomTags')),
              subtitle: Text(AppStrings.t(context, 'customTagsActive')),
              trailing: const Icon(Icons.check_circle_outline, color: AppColors.success),
            ),
          if (shop.hasMultiPhotos)
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.success),
              title: Text(AppStrings.t(context, 'shopFeatMultiPhotos')),
              subtitle: Text(AppStrings.t(context, 'multiPhotosActive')),
              trailing: const Icon(Icons.check_circle_outline, color: AppColors.success),
            ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'data')),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: Text(AppStrings.t(context, 'exportDevices')),
            subtitle: Text(shop.hasExportData
                ? '${devices.totalCount} devices'
                : AppStrings.t(context, 'exportLocked')),
            trailing: const Icon(Icons.chevron_right),
            onTap: shop.hasExportData
                ? () => devices.shareExport(hasExport: true)
                : () => MainShell.of(context)?.openShop(tab: ShopRewardsTab.features),
          ),
          ListTile(
            leading: const Icon(Icons.stars_outlined),
            title: Text(AppStrings.t(context, 'openShop')),
            subtitle: Text(AppStrings.t(context, 'openShopDesc')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => MainShell.of(context)?.openShop(),
          ),
          if (!shop.isBillingDisabled && shop.billing.isAvailable)
            ListTile(
              leading: const Icon(Icons.restore_rounded, color: AppColors.primary),
              title: Text(AppStrings.t(context, 'restorePurchases')),
              subtitle: Text(AppStrings.t(context, 'restorePurchasesDesc')),
              trailing: shop.isPurchasing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right),
              onTap: shop.isPurchasing
                  ? null
                  : () async {
                      await shop.restorePurchases();
                      if (!context.mounted) return;
                      final msg = shop.lastMessage ?? 'restoreComplete';
                      AppToast.show(context, title: AppStrings.t(context, msg), icon: Icons.check_circle_outline);
                    },
            ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(AppStrings.t(context, 'privacyPolicy')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'about')),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppStrings.t(context, 'version', {'version': _version.isNotEmpty ? _version : '...'})),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(AppStrings.t(context, 'about')),
            subtitle: Text(AppStrings.t(context, 'aboutDesc')),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              AppStrings.t(context, 'copyright'),
              style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  String _themeNameKey(String id) => switch (id) {
        'theme_sunset' => 'shopThemeSunset',
        'theme_midnight' => 'shopThemeMidnight',
        'theme_neon' => 'shopThemeNeon',
        'theme_ocean' => 'shopThemeOcean',
        _ => 'shopThemeOcean',
      };

  String _bgNameKey(String id) => switch (id) {
        'bg_sunrise' => 'shopBgSunrise',
        'bg_aurora' => 'shopBgAurora',
        'bg_galaxy' => 'shopBgGalaxy',
        'bg_fire' => 'shopBgFire',
        _ => 'shopBgSunrise',
      };

  String _skinNameKey(String id) => switch (id) {
        'skin_glass' => 'shopSkinGlass',
        'skin_minimal' => 'shopSkinMinimal',
        'skin_bold' => 'shopSkinBold',
        _ => 'shopSkinGlass',
      };
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.onSurfaceVariant)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }
}
