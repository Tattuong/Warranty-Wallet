import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/billing_service.dart';
import '../core/services/iap_config_service.dart';
import '../core/services/storage_service.dart';
import '../models/app_theme_preset.dart';
import '../models/shop_coin_event.dart';
import '../models/shop_item.dart';

enum ShopPurchaseResult {
  success,
  insufficientCoins,
  alreadyOwned,
  notFound,
  error,
}

class ShopProvider extends ChangeNotifier {
  static const _coinsKey = 'ww_coins';
  static const _ownedKey = 'ww_owned_items';
  static const _activeThemeKey = 'ww_active_theme';
  static const _activeBgKey = 'ww_active_background';
  static const _activeSkinKey = 'ww_active_skin';
  static const _lastDailyKey = 'ww_last_daily_reward';
  static const _processedPurchasesKey = 'ww_processed_purchases';

  final IapConfigService _configService = IapConfigService();
  final BillingService _billing = BillingService();

  int _coins = 0;
  Set<String> _ownedItems = {};
  String _activeThemeId = ShopCatalog.defaultThemeId;
  String _activeBackgroundId = ShopCatalog.defaultBackgroundId;
  String _activeSkinId = ShopCatalog.defaultSkinId;
  bool _isPurchasing = false;
  bool _isLoading = true;
  String? _lastMessage;
  Set<String> _processedPurchaseIds = {};
  ShopCoinEvent? _lastCoinEvent;

  int get coins => _coins;
  Set<String> get ownedItems => _ownedItems;
  String get activeThemeId => _activeThemeId;
  String get activeBackgroundId => _activeBackgroundId;
  String get activeSkinId => _activeSkinId;
  bool get isPurchasing => _isPurchasing;
  bool get isLoading => _isLoading;
  String? get lastMessage => _lastMessage;
  ShopCoinEvent? get lastCoinEvent => _lastCoinEvent;
  IapConfigService get configService => _configService;
  BillingService get billing => _billing;

  bool get isBillingDisabled => _configService.isBillingDisabled;
  bool get isBillingAvailable =>
      !isBillingDisabled && _billing.isAvailable && _billing.products.isNotEmpty;
  IapConfigStatus get configStatus => _configService.status;

  bool get hasRemoveAds => _ownedItems.contains(ShopCatalog.removeAdsId);
  bool get hasUnlimitedDevices => _ownedItems.contains('feat_unlimited_devices');
  bool get hasAdvancedFilters => _ownedItems.contains('feat_advanced_filters');
  bool get hasStatsPro => _ownedItems.contains('feat_stats_pro');
  bool get hasExportData => _ownedItems.contains('feat_export_data');
  bool get hasWarrantyAlert => _ownedItems.contains('feat_warranty_alert');
  bool get hasCustomTags => _ownedItems.contains('feat_custom_tags');
  bool get hasMultiPhotos => _ownedItems.contains('feat_multi_photos');

  AppThemePreset get activeTheme => AppThemePresets.get(_activeThemeId);
  DeviceBackground get activeBackground => DeviceBackground.get(_activeBackgroundId);
  DeviceCardSkin get activeSkin => DeviceCardSkin.get(_activeSkinId);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadLocal();
    await _configService.fetch();

    if (!isBillingDisabled && (Platform.isAndroid || Platform.isIOS)) {
      await _billing.init(
        onPurchase: _handlePurchase,
        onError: () {
          _isPurchasing = false;
          _lastMessage = 'purchaseFailed';
          notifyListeners();
        },
        onCanceled: endPurchaseUi,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshConfig() async {
    await _configService.fetch(forceRefresh: true);
    notifyListeners();
  }

  Future<void> _loadLocal() async {
    _coins = await StorageService.instance.getInt(_coinsKey) ?? 0;
    final owned = await StorageService.instance.getStringList(_ownedKey);
    _ownedItems = owned?.toSet() ?? {};
    _activeThemeId =
        await StorageService.instance.getString(_activeThemeKey) ?? ShopCatalog.defaultThemeId;
    _activeBackgroundId =
        await StorageService.instance.getString(_activeBgKey) ?? ShopCatalog.defaultBackgroundId;
    _activeSkinId =
        await StorageService.instance.getString(_activeSkinKey) ?? ShopCatalog.defaultSkinId;
    final processed = await StorageService.instance.getStringList(_processedPurchasesKey);
    _processedPurchaseIds = processed?.toSet() ?? {};
  }

  Future<void> _saveLocal() async {
    await StorageService.instance.saveInt(_coinsKey, _coins);
    await StorageService.instance.saveStringList(_ownedKey, _ownedItems.toList());
    await StorageService.instance.saveString(_activeThemeKey, _activeThemeId);
    await StorageService.instance.saveString(_activeBgKey, _activeBackgroundId);
    await StorageService.instance.saveString(_activeSkinKey, _activeSkinId);
    await StorageService.instance.saveStringList(_processedPurchasesKey, _processedPurchaseIds.toList());
  }

  bool ownsItem(String id) => _ownedItems.contains(id);

  ShopPurchaseResult buyWithCoins(String itemId) {
    final item = ShopCatalog.find(itemId);
    if (item == null) return ShopPurchaseResult.notFound;
    if (item.oneTime && _ownedItems.contains(itemId)) {
      return ShopPurchaseResult.alreadyOwned;
    }
    if (_coins < item.price) return ShopPurchaseResult.insufficientCoins;

    _coins -= item.price;
    _ownedItems.add(itemId);
    _applyItem(item);
    _lastMessage = 'purchaseSuccess';
    _saveLocal();
    notifyListeners();
    return ShopPurchaseResult.success;
  }

  void _applyItem(ShopItem item) {
    switch (item.type) {
      case ShopItemType.theme:
        _activeThemeId = item.id;
      case ShopItemType.background:
        _activeBackgroundId = item.id;
      case ShopItemType.skin:
        _activeSkinId = item.id;
      case ShopItemType.removeAds:
      case ShopItemType.feature:
        break;
    }
  }

  Future<bool> buyCoinPack(ProductDetails product) async {
    if (isBillingDisabled || !_billing.isAvailable) return false;
    _isPurchasing = true;
    _lastMessage = null;
    notifyListeners();
    final ok = await _billing.buyCoinPack(product);
    if (!ok) {
      _isPurchasing = false;
      _lastMessage = 'purchaseFailed';
      notifyListeners();
    }
    return ok;
  }

  Future<bool> buyRemoveAdsViaBilling() async {
    if (isBillingDisabled || !_billing.isAvailable) return false;
    if (hasRemoveAds) return false;
    _isPurchasing = true;
    _lastMessage = null;
    notifyListeners();
    final ok = await _billing.buyRemoveAds();
    if (!ok) {
      _isPurchasing = false;
      _lastMessage = 'purchaseFailed';
      notifyListeners();
    }
    return ok;
  }

  Future<void> restorePurchases() async {
    if (isBillingDisabled || !_billing.isAvailable) {
      _lastMessage = 'billingUnavailable';
      notifyListeners();
      return;
    }
    _isPurchasing = true;
    _lastMessage = 'restoringPurchases';
    notifyListeners();
    await _billing.restorePurchases();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    _isPurchasing = false;
    _lastMessage = 'restoreComplete';
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final purchaseId = purchase.purchaseID ?? '${purchase.productID}_${purchase.transactionDate}';
    if (_processedPurchaseIds.contains(purchaseId)) {
      _isPurchasing = false;
      notifyListeners();
      return;
    }

    if (IapConstants.isRemoveAdsProduct(purchase.productID)) {
      _ownedItems.add(ShopCatalog.removeAdsId);
      _processedPurchaseIds.add(purchaseId);
      _lastMessage = 'purchaseSuccess';
      _isPurchasing = false;
      await _saveLocal();
      notifyListeners();
      return;
    }

    final coins = IapConstants.coinsForProduct(purchase.productID);
    if (coins > 0) {
      _coins += coins;
      _processedPurchaseIds.add(purchaseId);
      _lastMessage = 'coinsAdded';
      _emitCoinEarned(coins, 'coinsAdded');
    }

    _isPurchasing = false;
    await _saveLocal();
    notifyListeners();
  }

  Future<bool> claimDailyReward() async {
    final today = _dateKey(DateTime.now());
    final last = await StorageService.instance.getString(_lastDailyKey);
    if (last == today) return false;

    const amount = IapConstants.dailyLoginReward;
    _coins += amount;
    await StorageService.instance.saveString(_lastDailyKey, today);
    _lastMessage = 'dailyRewardClaimed';
    _emitCoinEarned(amount, 'dailyRewardClaimed');
    await _saveLocal();
    notifyListeners();
    return true;
  }

  Future<bool> hasClaimedDailyToday() async {
    final today = _dateKey(DateTime.now());
    final last = await StorageService.instance.getString(_lastDailyKey);
    return last == today;
  }

  Future<void> addCoins(int amount, String messageKey) async {
    if (amount <= 0) return;
    _coins += amount;
    _emitCoinEarned(amount, messageKey);
    await _saveLocal();
    notifyListeners();
  }

  Future<void> selectTheme(String themeId) async {
    if (themeId != ShopCatalog.defaultThemeId && !_ownedItems.contains(themeId)) return;
    _activeThemeId = themeId;
    await _saveLocal();
    notifyListeners();
  }

  Future<void> selectBackground(String bgId) async {
    if (bgId != ShopCatalog.defaultBackgroundId && !_ownedItems.contains(bgId)) return;
    _activeBackgroundId = bgId;
    await _saveLocal();
    notifyListeners();
  }

  Future<void> selectSkin(String skinId) async {
    if (skinId != ShopCatalog.defaultSkinId && !_ownedItems.contains(skinId)) return;
    _activeSkinId = skinId;
    await _saveLocal();
    notifyListeners();
  }

  Future<void> resetThemeToDefault() => selectTheme(ShopCatalog.defaultThemeId);
  Future<void> resetBackgroundToDefault() => selectBackground(ShopCatalog.defaultBackgroundId);
  Future<void> resetSkinToDefault() => selectSkin(ShopCatalog.defaultSkinId);

  void clearLastMessage() => _lastMessage = null;
  void clearCoinEvent() => _lastCoinEvent = null;

  void endPurchaseUi() {
    if (!_isPurchasing) return;
    _isPurchasing = false;
    notifyListeners();
  }

  void _emitCoinEarned(int amount, String messageKey) {
    if (amount <= 0) return;
    _lastCoinEvent = ShopCoinEvent(amount: amount, messageKey: messageKey);
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  @override
  void dispose() {
    _billing.dispose();
    super.dispose();
  }
}
