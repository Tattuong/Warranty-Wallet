import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';
  static const String removeAdsId = 'feat_remove_ads';

  static const List<ShopItem> items = [
    ShopItem(
      id: removeAdsId,
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.wb_twilight_outlined,
    ),
    ShopItem(
      id: 'theme_midnight',
      nameKey: 'shopThemeMidnight',
      descKey: 'shopThemeMidnightDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.nightlight_round,
    ),
    ShopItem(
      id: 'theme_neon',
      nameKey: 'shopThemeNeon',
      descKey: 'shopThemeNeonDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.bolt_outlined,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.water_outlined,
    ),
    ShopItem(
      id: 'bg_sunrise',
      nameKey: 'shopBgSunrise',
      descKey: 'shopBgSunriseDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.wb_sunny_outlined,
    ),
    ShopItem(
      id: 'bg_aurora',
      nameKey: 'shopBgAurora',
      descKey: 'shopBgAuroraDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.auto_awesome_outlined,
    ),
    ShopItem(
      id: 'bg_galaxy',
      nameKey: 'shopBgGalaxy',
      descKey: 'shopBgGalaxyDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.nightlight_outlined,
    ),
    ShopItem(
      id: 'bg_fire',
      nameKey: 'shopBgFire',
      descKey: 'shopBgFireDesc',
      price: 180,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.local_fire_department_outlined,
    ),
    ShopItem(
      id: 'skin_glass',
      nameKey: 'shopSkinGlass',
      descKey: 'shopSkinGlassDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.blur_on_outlined,
    ),
    ShopItem(
      id: 'skin_minimal',
      nameKey: 'shopSkinMinimal',
      descKey: 'shopSkinMinimalDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.crop_square_outlined,
    ),
    ShopItem(
      id: 'skin_bold',
      nameKey: 'shopSkinBold',
      descKey: 'shopSkinBoldDesc',
      price: 200,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.style_outlined,
    ),
    ShopItem(
      id: 'feat_unlimited_devices',
      nameKey: 'shopFeatUnlimitedDevices',
      descKey: 'shopFeatUnlimitedDevicesDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.devices_outlined,
    ),
    ShopItem(
      id: 'feat_advanced_filters',
      nameKey: 'shopFeatAdvancedFilters',
      descKey: 'shopFeatAdvancedFiltersDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.filter_alt_outlined,
    ),
    ShopItem(
      id: 'feat_stats_pro',
      nameKey: 'shopFeatStatsPro',
      descKey: 'shopFeatStatsProDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.insights_outlined,
    ),
    ShopItem(
      id: 'feat_export_data',
      nameKey: 'shopFeatExport',
      descKey: 'shopFeatExportDesc',
      price: 180,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.file_download_outlined,
    ),
    ShopItem(
      id: 'feat_warranty_alert',
      nameKey: 'shopFeatWarrantyAlert',
      descKey: 'shopFeatWarrantyAlertDesc',
      price: 220,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.notifications_active_outlined,
    ),
    ShopItem(
      id: 'feat_custom_tags',
      nameKey: 'shopFeatCustomTags',
      descKey: 'shopFeatCustomTagsDesc',
      price: 150,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.label_outlined,
    ),
    ShopItem(
      id: 'feat_multi_photos',
      nameKey: 'shopFeatMultiPhotos',
      descKey: 'shopFeatMultiPhotosDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.photo_library_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
