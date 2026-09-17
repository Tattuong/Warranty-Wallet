import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants/ad_constants.dart';
import 'core/navigation/app_navigator.dart';
import 'core/services/ad_service.dart';
import 'core/services/storage_service.dart';
import 'providers/devices_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/coin_reward_listener.dart';

late final ThemeProvider appThemeProvider;

void _useAndroidPhotoPicker() {
  final impl = ImagePickerPlatform.instance;
  if (impl is ImagePickerAndroid) {
    impl.useAndroidPhotoPicker = true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _useAndroidPhotoPicker();
  await initializeDateFormatting('en');
  await StorageService.instance.init();

  appThemeProvider = ThemeProvider();
  await appThemeProvider.init();

  runApp(const WarrantyWalletApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (AdConstants.isConfigured) unawaited(AdService.init());
  });
}

class WarrantyWalletApp extends StatelessWidget {
  const WarrantyWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appThemeProvider),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => DevicesProvider()),
      ],
      child: Consumer2<ThemeProvider, ShopProvider>(
        builder: (context, theme, shop, _) {
          final preset = shop.activeTheme;
          final isDark = theme.isDarkMode;

          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? preset.darkBackground : preset.background,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            title: 'Warranty Wallet',
            debugShowCheckedModeBanner: false,
            theme: preset.lightTheme(),
            darkTheme: preset.darkTheme(),
            themeMode: theme.themeMode,
            builder: (context, child) => CoinRewardListener(child: child ?? const SizedBox.shrink()),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
