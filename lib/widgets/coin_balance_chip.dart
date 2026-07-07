import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/shop_provider.dart';
import 'coin_purchase_sheet.dart';

class CoinBalanceChip extends StatelessWidget {
  final VoidCallback? onTap;

  const CoinBalanceChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => CoinPurchaseSheet.show(context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.coin.withValues(alpha: 0.28),
                AppColors.primary.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.coin.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.coin.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_rounded, color: AppColors.primaryDark, size: 14),
              ),
              const SizedBox(width: 6),
              Text(
                '${shop.coins}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 14),
              ),
              if (!shop.isBillingDisabled) ...[
                const SizedBox(width: 4),
                Icon(Icons.add_rounded, color: AppColors.primary.withValues(alpha: 0.8), size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
