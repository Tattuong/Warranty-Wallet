import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/ad_banner_slot.dart';
import 'devices/devices_screen.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';
import 'shop/shop_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;
  final _shopKey = GlobalKey<ShopScreenState>();

  void openShop({ShopRewardsTab tab = ShopRewardsTab.all}) {
    setState(() => _index = 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shopKey.currentState?.selectTab(tab);
    });
  }

  void openDevices({String? filter}) {
    setState(() => _index = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screen = DevicesScreen.of(context);
      if (filter != null) screen?.setFilter(filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = [
      const HomeScreen(),
      const DevicesScreen(),
      ShopScreen(key: _shopKey, embedded: true),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundOf(context),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerSlot(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkSurface : AppColors.surface).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: isDark ? 0.25 : 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _DockItem(
                          icon: Icons.grid_view_rounded,
                          label: AppStrings.t(context, 'navHome'),
                          active: _index == 0,
                          onTap: () => setState(() => _index = 0),
                        ),
                        _DockItem(
                          icon: Icons.inventory_2_outlined,
                          label: AppStrings.t(context, 'navDevices'),
                          active: _index == 1,
                          onTap: () => setState(() => _index = 1),
                        ),
                        _DockItem(
                          icon: Icons.diamond_outlined,
                          label: AppStrings.t(context, 'navShop'),
                          active: _index == 2,
                          onTap: () => setState(() => _index = 2),
                        ),
                        _DockItem(
                          icon: Icons.tune_rounded,
                          label: AppStrings.t(context, 'navSettings'),
                          active: _index == 3,
                          onTap: () => setState(() => _index = 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.95),
                      AppColors.primaryLight.withValues(alpha: 0.85),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: active
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: active ? Colors.white : AppColors.onSurfaceVariant),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
