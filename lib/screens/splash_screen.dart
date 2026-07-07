import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../providers/devices_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/vault_ui.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final shop = context.read<ShopProvider>();
    await shop.init();
    final devices = context.read<DevicesProvider>();
    await devices.load();
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('ww_onboarding_seen') ?? false;

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final next = seenOnboarding ? const MainShell() : const OnboardingScreen();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VaultMeshBackground(
        showOrbs: true,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 32, offset: const Offset(0, 16)),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Warranty Wallet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage warranties, invoices & receipts',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(color: AppColors.primary.withValues(alpha: 0.85), strokeWidth: 2.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
