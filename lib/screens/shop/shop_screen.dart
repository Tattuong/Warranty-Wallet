import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/iap_config_service.dart';
import '../../models/app_theme_preset.dart';
import '../../models/shop_item.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coin_purchase_sheet.dart';

enum ShopRewardsTab { all, premium, themes, backgrounds, skins, features }

class ShopScreen extends StatefulWidget {
  final bool embedded;

  const ShopScreen({super.key, this.embedded = false});

  @override
  ShopScreenState createState() => ShopScreenState();
}

class ShopScreenState extends State<ShopScreen> {
  ShopRewardsTab _tab = ShopRewardsTab.all;

  void selectTab(ShopRewardsTab tab) {
    if (_tab == tab) return;
    setState(() => _tab = tab);
  }

  void openUnlimitedFeature() => selectTab(ShopRewardsTab.features);

  List<ShopItem> _itemsFor(ShopRewardsTab tab) => switch (tab) {
        ShopRewardsTab.all => ShopCatalog.items,
        ShopRewardsTab.premium => ShopCatalog.items.where((i) => i.category == ShopItemCategory.premium).toList(),
        ShopRewardsTab.themes => ShopCatalog.items.where((i) => i.category == ShopItemCategory.themes).toList(),
        ShopRewardsTab.backgrounds => ShopCatalog.items.where((i) => i.category == ShopItemCategory.backgrounds).toList(),
        ShopRewardsTab.skins => ShopCatalog.items.where((i) => i.category == ShopItemCategory.skins).toList(),
        ShopRewardsTab.features => ShopCatalog.items.where((i) => i.category == ShopItemCategory.features).toList(),
      };

  bool _isVisualTab(ShopRewardsTab tab) =>
      tab == ShopRewardsTab.themes || tab == ShopRewardsTab.backgrounds || tab == ShopRewardsTab.skins;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _itemsFor(_tab);
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return ColoredBox(
      color: bg,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _WalletHero(shop: shop, embedded: widget.embedded)),
            if (shop.configStatus == IapConfigStatus.timeout || shop.configStatus == IapConfigStatus.networkError)
              SliverToBoxAdapter(child: _ConfigBanner(status: shop.configStatus)),
            SliverToBoxAdapter(child: _EarnStrip(shop: shop)),
            SliverToBoxAdapter(child: _CategoryBar(selected: _tab, onSelect: (t) => setState(() => _tab = t))),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(AppStrings.t(context, 'shopEmptyCategory'), style: const TextStyle(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              )
            else if (_tab == ShopRewardsTab.all)
              ..._buildGroupedSlivers(items)
            else if (_isVisualTab(_tab))
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _VisualShopCard(item: items[i]),
                    childCount: items.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ShopListTile(item: items[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedSlivers(List<ShopItem> items) {
    final groups = <(String, List<ShopItem>)>[
      ('shopMenuPremium', items.where((i) => i.category == ShopItemCategory.premium).toList()),
      ('shopMenuFeatures', items.where((i) => i.category == ShopItemCategory.features).toList()),
      ('shopMenuThemes', items.where((i) => i.category == ShopItemCategory.themes).toList()),
      ('shopMenuCards', items.where((i) => i.category == ShopItemCategory.backgrounds).toList()),
      ('shopMenuSkins', items.where((i) => i.category == ShopItemCategory.skins).toList()),
    ];

    final slivers = <Widget>[];
    for (final (key, group) in groups) {
      if (group.isEmpty) continue;
      final visual = key == 'shopMenuThemes' || key == 'shopMenuCards' || key == 'shopMenuSkins';
      slivers.add(SliverToBoxAdapter(child: _GroupHeader(labelKey: key)));
      if (visual) {
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _VisualShopCard(item: group[i]),
                childCount: group.length,
              ),
            ),
          ),
        );
      } else {
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            sliver: SliverList.separated(
              itemCount: group.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ShopListTile(item: group[i]),
            ),
          ),
        );
      }
    }
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 130)));
    return slivers;
  }
}

// ─── Wallet hero ───────────────────────────────────────────────────────────────

class _WalletHero extends StatelessWidget {
  final ShopProvider shop;
  final bool embedded;

  const _WalletHero({required this.shop, required this.embedded});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, embedded ? 12 : 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: shop.activeTheme.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.t(context, 'shopTitle'),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.coin, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${shop.coins}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.t(context, 'shopSubtitle'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroAction(
                  icon: Icons.wb_sunny_rounded,
                  label: AppStrings.t(context, 'earnCoins'),
                  onTap: () async {
                    final claimed = await shop.claimDailyReward();
                    if (!context.mounted) return;
                    if (!claimed) {
                      AppToast.show(context, title: AppStrings.t(context, 'dailyRewardDone'), icon: Icons.info_outline);
                    }
                  },
                ),
              ),
              if (!shop.isBillingDisabled) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _HeroAction(
                    icon: Icons.shopping_cart_rounded,
                    label: AppStrings.t(context, 'buyCoins'),
                    filled: true,
                    onTap: () => CoinPurchaseSheet.show(context),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _HeroAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? Colors.white : Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? AppColors.primary : Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: filled ? AppColors.primary : Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Earn strip ────────────────────────────────────────────────────────────────

class _EarnStrip extends StatelessWidget {
  final ShopProvider shop;

  const _EarnStrip({required this.shop});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final methods = [
      (Icons.devices_outlined, AppColors.primary, 'earnStepAddDevice', 'earnStepAddDeviceDesc'),
      (Icons.photo_library_outlined, AppColors.success, 'earnStepAddPhoto', 'earnStepAddPhotoDesc'),
      (Icons.calendar_today_outlined, AppColors.expiringSoon, 'earnStepDaily', 'dailyReward'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t(context, 'earnCoinsHint'),
              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              children: methods.map((m) {
                final (icon, color, titleKey, descKey) = m;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.t(context, titleKey),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                        maxLines: 2,
                      ),
                      Text(
                        AppStrings.t(context, descKey),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category bar ──────────────────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  final ShopRewardsTab selected;
  final ValueChanged<ShopRewardsTab> onSelect;

  const _CategoryBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = <(ShopRewardsTab, IconData, String)>[
      (ShopRewardsTab.all, Icons.apps_rounded, 'shopMenuAll'),
      (ShopRewardsTab.features, Icons.bolt_rounded, 'shopMenuFeatures'),
      (ShopRewardsTab.themes, Icons.palette_rounded, 'shopMenuThemes'),
      (ShopRewardsTab.backgrounds, Icons.wallpaper_rounded, 'shopMenuCards'),
      (ShopRewardsTab.skins, Icons.style_rounded, 'shopMenuSkins'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (tab, icon, key) = tabs[i];
            final active = selected == tab;
            return GestureDetector(
              onTap: () => onSelect(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 68,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : (isDark ? AppColors.darkSurface : AppColors.surface),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.12),
                  ),
                  boxShadow: active
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: active ? Colors.white : AppColors.onSurfaceVariant),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.t(context, key),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String labelKey;

  const _GroupHeader({required this.labelKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        AppStrings.t(context, labelKey),
        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ─── Visual card (themes / backgrounds / skins) ────────────────────────────────

class _VisualShopCard extends StatelessWidget {
  final ShopItem item;

  const _VisualShopCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final owned = shop.ownsItem(item.id);
    final isActive = _RewardActions.itemIsActive(shop, item);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: owned ? null : () => _RewardActions.tryPurchase(context, shop, item),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ItemVisual(item: item, large: true),
                      if (owned)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _StatusDot(active: isActive),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(context, item.nameKey),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _RewardActions(item: item, owned: owned, isActive: isActive, dense: true),
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

// ─── List tile (features / premium) ────────────────────────────────────────────

class _ShopListTile extends StatelessWidget {
  final ShopItem item;

  const _ShopListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final owned = shop.ownsItem(item.id);
    final isActive = _RewardActions.itemIsActive(shop, item);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: owned ? null : () => _RewardActions.tryPurchase(context, shop, item),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.primary.withValues(alpha: 0.5) : AppColors.onSurfaceVariant.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 52, height: 52, child: _ItemVisual(item: item)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(context, item.nameKey),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.t(context, item.descKey),
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RewardActions(item: item, owned: owned, isActive: isActive, dense: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;

  const _StatusDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        AppStrings.t(context, active ? 'active' : 'owned'),
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── Item visual preview ─────────────────────────────────────────────────────

class _ItemVisual extends StatelessWidget {
  final ShopItem item;
  final bool large;

  const _ItemVisual({required this.item, this.large = false});

  @override
  Widget build(BuildContext context) {
    if (item.type == ShopItemType.theme) {
      final preset = AppThemePresets.byId[item.id];
      if (preset != null) {
        return DecoratedBox(
          decoration: BoxDecoration(gradient: preset.headerGradient),
          child: Center(child: Icon(Icons.palette_rounded, color: Colors.white.withValues(alpha: 0.9), size: large ? 28 : 22)),
        );
      }
    }
    if (item.type == ShopItemType.background) {
      final bg = DeviceBackground.byId[item.id];
      if (bg != null) {
        return DecoratedBox(
          decoration: BoxDecoration(gradient: bg.gradient),
          child: Center(child: Icon(Icons.layers_rounded, color: Colors.white.withValues(alpha: 0.85), size: large ? 26 : 20)),
        );
      }
    }
    if (item.type == ShopItemType.skin) {
      final skin = DeviceCardSkin.byId[item.id];
      if (skin != null) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(skin.borderRadius * 0.25),
            border: skin.showBorder ? Border.all(color: AppColors.primary.withValues(alpha: 0.35)) : null,
          ),
          child: Center(child: Icon(item.icon, color: AppColors.primary, size: large ? 26 : 20)),
        );
      }
    }

    final tint = switch (item.category) {
      ShopItemCategory.premium => AppColors.accent,
      ShopItemCategory.features => AppColors.primary,
      _ => AppColors.coin,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tint.withValues(alpha: 0.2), tint.withValues(alpha: 0.06)],
        ),
      ),
      child: Center(child: Icon(item.icon, color: tint, size: large ? 26 : 22)),
    );
  }
}

// ─── Purchase actions (unchanged logic) ───────────────────────────────────────

class _RewardActions extends StatelessWidget {
  final ShopItem item;
  final bool owned;
  final bool isActive;
  final bool dense;

  const _RewardActions({
    required this.item,
    required this.owned,
    required this.isActive,
    this.dense = false,
  });

  static bool itemIsActive(ShopProvider shop, ShopItem item) {
    if (item.type == ShopItemType.theme) return shop.activeThemeId == item.id;
    if (item.type == ShopItemType.background) return shop.activeBackgroundId == item.id;
    if (item.type == ShopItemType.skin) return shop.activeSkinId == item.id;
    return shop.ownsItem(item.id);
  }

  static void tryPurchase(BuildContext context, ShopProvider shop, ShopItem item) {
    if (shop.ownsItem(item.id)) return;
    _purchase(context, shop, item);
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    if (owned && item.type == ShopItemType.removeAds && !shop.isBillingDisabled && shop.billing.removeAdsProduct != null) {
      return _OwnedBadge(dense: dense);
    }

    if (!owned && item.type == ShopItemType.removeAds && !shop.isBillingDisabled && shop.billing.removeAdsProduct != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _StarPriceButton(item: item, dense: dense),
          const SizedBox(height: 4),
          _ActionChip(
            label: AppStrings.t(context, 'buyWithGooglePlay'),
            filled: true,
            onTap: () async {
              final ok = await shop.buyRemoveAdsViaBilling();
              if (!context.mounted) return;
              if (ok) {
                AppToast.show(context, title: AppStrings.t(context, 'openingBilling'));
              } else if (shop.lastMessage != null) {
                AppToast.show(context, title: AppStrings.t(context, shop.lastMessage!));
              }
            },
          ),
        ],
      );
    }

    if (owned && item.type == ShopItemType.feature) {
      return _ActionChip(
        label: AppStrings.t(context, 'active'),
        filled: true,
        onTap: null,
      );
    }

    if (owned && item.type == ShopItemType.removeAds) {
      return _ActionChip(
        label: AppStrings.t(context, 'adRemoved'),
        filled: true,
        onTap: null,
      );
    }

    if (owned && (item.type == ShopItemType.theme || item.type == ShopItemType.background || item.type == ShopItemType.skin)) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          if (!isActive)
            _ActionChip(
              label: AppStrings.t(context, 'apply'),
              filled: true,
              onTap: () {
                if (item.type == ShopItemType.theme) {
                  shop.selectTheme(item.id);
                } else if (item.type == ShopItemType.background) {
                  shop.selectBackground(item.id);
                } else {
                  shop.selectSkin(item.id);
                }
                AppToast.show(context, title: AppStrings.t(context, 'applied'));
              },
            ),
          if (isActive)
            _ActionChip(
              label: AppStrings.t(context, 'resetDefault'),
              onTap: () async {
                if (item.type == ShopItemType.theme) {
                  await shop.resetThemeToDefault();
                } else if (item.type == ShopItemType.background) {
                  await shop.resetBackgroundToDefault();
                } else {
                  await shop.resetSkinToDefault();
                }
                AppToast.show(context, title: AppStrings.t(context, 'resetToDefault'));
              },
            ),
        ],
      );
    }

    if (owned) return _OwnedBadge(dense: dense);

    return _StarPriceButton(item: item, dense: dense);
  }

  static void _purchase(BuildContext context, ShopProvider shop, ShopItem item) {
    final result = shop.buyWithCoins(item.id);
    switch (result) {
      case ShopPurchaseResult.success:
        final applied = item.type == ShopItemType.theme ||
            item.type == ShopItemType.background ||
            item.type == ShopItemType.skin;
        AppToast.show(
          context,
          title: AppStrings.t(context, applied ? 'applied' : 'purchaseSuccess'),
          message: applied ? AppStrings.t(context, item.nameKey) : null,
        );
      case ShopPurchaseResult.insufficientCoins:
        AppToast.show(context, title: AppStrings.t(context, 'insufficientCoins'), icon: Icons.warning_amber_rounded, color: AppColors.warning);
        if (!shop.isBillingDisabled) CoinPurchaseSheet.show(context);
      case ShopPurchaseResult.alreadyOwned:
        AppToast.show(context, title: AppStrings.t(context, 'alreadyOwned'));
      case ShopPurchaseResult.notFound:
      case ShopPurchaseResult.error:
        AppToast.show(context, title: AppStrings.t(context, 'purchaseFailed'));
    }
  }
}

class _OwnedBadge extends StatelessWidget {
  final bool dense;

  const _OwnedBadge({this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: AppColors.success, size: dense ? 14 : 16),
        const SizedBox(width: 4),
        Text(
          AppStrings.t(context, 'owned'),
          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: dense ? 10 : 12),
        ),
      ],
    );
  }
}

class _StarPriceButton extends StatelessWidget {
  final ShopItem item;
  final bool dense;

  const _StarPriceButton({required this.item, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();
    final canAfford = shop.coins >= item.price;

    return Material(
      color: canAfford ? AppColors.coin.withValues(alpha: 0.12) : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _RewardActions._purchase(context, shop, item),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 5 : 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: dense ? 12 : 14, color: canAfford ? AppColors.coin : AppColors.onSurfaceVariant),
              const SizedBox(width: 3),
              Text(
                '${item.price}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: dense ? 11 : 13,
                  color: canAfford ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionChip({required this.label, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: filled ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: filled ? Colors.white : AppColors.primary),
      ),
    );

    if (onTap == null) {
      return Material(
        color: filled ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: child,
      );
    }

    return Material(
      color: filled ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}

class _ConfigBanner extends StatelessWidget {
  final IapConfigStatus status;

  const _ConfigBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final text = status == IapConfigStatus.timeout
        ? AppStrings.t(context, 'configTimeout')
        : AppStrings.t(context, 'configNetworkError');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.warning))),
        ],
      ),
    );
  }
}
