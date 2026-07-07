import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/page_background.dart';
import '../widgets/vault_ui.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _pages = const [
    (Icons.folder_special_outlined, 'onboardingTitle1', 'onboardingDesc1', Color(0xFFC2773A)),
    (Icons.schedule_outlined, 'onboardingTitle2', 'onboardingDesc2', Color(0xFF2DD4BF)),
    (Icons.diamond_outlined, 'onboardingTitle3', 'onboardingDesc3', Color(0xFFFB7185)),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ww_onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(onPressed: _finish, child: Text(AppStrings.t(context, 'skip'))),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final (icon, titleKey, descKey, color) = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: VaultCard(
                        accentColor: color,
                        radius: 28,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.08)]),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Icon(icon, size: 44, color: color),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              AppStrings.t(context, titleKey),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              AppStrings.t(context, descKey),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.onSurfaceVariant, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _pageCtrl.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(AppStrings.t(context, _page < _pages.length - 1 ? 'next' : 'getStarted')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
