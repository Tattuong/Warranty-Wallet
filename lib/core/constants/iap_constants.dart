class IapConstants {
  IapConstants._();

  static const String productPrefix = 'ww';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/R225.json';

  static const Duration configTimeout = Duration(seconds: 10);

  static const String removeAdsId = 'ww_remove_ads';

  static const List<String> coinPackIds = [
    'ww_pack_1',
    'ww_pack_2',
    'ww_pack_3',
    'ww_pack_4',
    'ww_pack_5',
    'ww_pack_6',
    'ww_pack_7',
    'ww_pack_8',
    'ww_pack_9',
    'ww_pack_10',
  ];

  static List<String> get allProductIds => [...coinPackIds, removeAdsId];

  static const List<int> coinPackAmounts = [
    50,
    100,
    200,
    350,
    500,
    750,
    1000,
    1500,
    2200,
    3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static bool isRemoveAdsProduct(String productId) => productId == removeAdsId;

  static const int freeDeviceLimit = 5;
  static const int freePhotoLimit = 3;
  static const int dailyLoginReward = 15;
  static const int addDeviceReward = 10;
  static const int addPhotoReward = 5;
  static const int warrantyReviewReward = 10;
  static const int maxActionRewardsPerDay = 20;
}
