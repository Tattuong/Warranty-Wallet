import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/iap_constants.dart';
import '../core/services/iap_config_service.dart';
import '../providers/shop_provider.dart';
import 'app_toast.dart';

class CoinPurchaseSheet {
  static Future<void> show(BuildContext context) async {
    final shop = context.read<ShopProvider>();
    if (shop.isBillingDisabled) {
      AppToast.show(
        context,
        title: AppStrings.t(context, 'billingDisabled'),
        icon: Icons.info_outline,
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _CoinPurchaseSheet(),
    );

    shop.endPurchaseUi();
  }
}

class _CoinPurchaseSheet extends StatelessWidget {
  const _CoinPurchaseSheet();

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final products = shop.billing.products;
    final listMaxHeight = MediaQuery.sizeOf(context).height * 0.42;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.t(context, 'buyCoins'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(
            AppStrings.t(context, 'buyCoinsDesc'),
            style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 6),
              Text(
                AppStrings.t(context, 'yourCoins', {'count': shop.coins.toString()}),
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (shop.configStatus == IapConfigStatus.networkError ||
              shop.configStatus == IapConfigStatus.timeout) ...[
            const SizedBox(height: 12),
            _StatusBanner(
              icon: Icons.wifi_off_outlined,
              text: AppStrings.t(context, 'configNetworkError'),
              color: AppColors.warning,
            ),
          ],
          if (shop.isPurchasing) ...[
            const SizedBox(height: 12),
            _ProcessingBanner(text: AppStrings.t(context, 'processingPurchase')),
          ],
          if (!shop.billing.isAvailable) ...[
            const SizedBox(height: 16),
            _StatusBanner(
              icon: Icons.storefront_outlined,
              text: AppStrings.t(context, 'billingUnavailable'),
              color: AppColors.onSurfaceVariant,
            ),
          ] else if (products.isEmpty) ...[
            const SizedBox(height: 16),
            _StatusBanner(
              icon: Icons.inventory_2_outlined,
              text: AppStrings.t(context, 'productsNotFound'),
              color: AppColors.onSurfaceVariant,
            ),
          ] else ...[
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxHeight),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _PackTile(product: products[i]),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            AppStrings.t(context, 'earnCoinsHint'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ProcessingBanner extends StatelessWidget {
  final String text;

  const _ProcessingBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  final ProductDetails product;

  const _PackTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final coins = IapConstants.coinsForProduct(product.id);
    final packNum = IapConstants.coinPackIds.indexOf(product.id) + 1;
    final busy = shop.isPurchasing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: busy ? 0.55 : 1,
      child: Material(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: busy ? null : () => _buy(context, shop),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star_rounded, color: AppColors.warning),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(context, 'coinPack', {'num': packNum.toString()}),
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        AppStrings.t(context, 'coinAmount', {'count': coins.toString()}),
                        style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: busy ? null : () => _buy(context, shop),
                  child: Text(product.price),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _buy(BuildContext context, ShopProvider shop) async {
    final ok = await shop.buyCoinPack(product);
    if (!context.mounted) return;
    if (ok) {
      AppToast.show(context, title: AppStrings.t(context, 'openingBilling'));
    } else if (shop.lastMessage != null) {
      AppToast.show(context, title: AppStrings.t(context, shop.lastMessage!));
    }
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusBanner({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}
