import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/image_storage_service.dart';
import '../core/services/storage_service.dart';
import '../models/warranty_device.dart';
import 'shop_provider.dart';

class DevicesProvider extends ChangeNotifier {
  static const _devicesKey = 'ww_devices';
  static const _actionRewardsKey = 'ww_action_rewards_date';
  static const _actionRewardsCountKey = 'ww_action_rewards_count';

  final List<WarrantyDevice> _devices = [];
  bool _loaded = false;
  String _searchQuery = '';
  String _filter = 'all';
  String? _categoryFilter;

  List<WarrantyDevice> get devices => List.unmodifiable(_devices);
  bool get isLoaded => _loaded;
  String get searchQuery => _searchQuery;
  String get filter => _filter;
  String? get categoryFilter => _categoryFilter;

  int get totalCount => _devices.length;

  List<WarrantyDevice> get expiredDevices =>
      _devices.where((d) => d.warrantyStatus == WarrantyStatus.expired).toList()
        ..sort((a, b) => b.warrantyExpiryDate.compareTo(a.warrantyExpiryDate));

  List<WarrantyDevice> get expiringSoonDevices =>
      _devices.where((d) => d.warrantyStatus == WarrantyStatus.expiringSoon).toList()
        ..sort((a, b) => a.warrantyExpiryDate.compareTo(b.warrantyExpiryDate));

  List<WarrantyDevice> get activeDevices =>
      _devices.where((d) => d.warrantyStatus == WarrantyStatus.active).toList()
        ..sort((a, b) => a.warrantyExpiryDate.compareTo(b.warrantyExpiryDate));

  List<WarrantyDevice> get filteredDevices {
    var list = _devices.toList();
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((d) {
        return d.name.toLowerCase().contains(q) ||
            d.serialNumber.toLowerCase().contains(q) ||
            d.invoiceNumber.toLowerCase().contains(q) ||
            d.storeName.toLowerCase().contains(q) ||
            d.notes.toLowerCase().contains(q) ||
            d.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    if (_categoryFilter != null) {
      list = list.where((d) => d.category == _categoryFilter).toList();
    }

    list = switch (_filter) {
      'expired' => list.where((d) => d.warrantyStatus == WarrantyStatus.expired).toList(),
      'expiring' => list.where((d) => d.warrantyStatus == WarrantyStatus.expiringSoon).toList(),
      'active' => list.where((d) => d.warrantyStatus == WarrantyStatus.active).toList(),
      _ => list,
    };

    list.sort((a, b) => a.warrantyExpiryDate.compareTo(b.warrantyExpiryDate));
    return list;
  }

  Map<DeviceCategory, int> get categoryCounts {
    final counts = <DeviceCategory, int>{};
    for (final cat in DeviceCategory.values) {
      counts[cat] = _devices.where((d) => d.category == cat.name).length;
    }
    return counts;
  }

  List<WarrantyDevice> get recentDevices {
    final sorted = List<WarrantyDevice>.from(_devices)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(8).toList();
  }

  Future<void> load() async {
    if (_loaded) return;
    final raw = await StorageService.instance.getString(_devicesKey);
    if (raw != null && raw.isNotEmpty) {
      final list = StorageService.decodeList(raw);
      _devices
        ..clear()
        ..addAll(list.map(WarrantyDevice.fromJson));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final data = _devices.map((d) => d.toJson()).toList();
    await StorageService.instance.saveString(_devicesKey, StorageService.encodeList(data));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  bool canAddDevice(ShopProvider shop) {
    if (shop.hasUnlimitedDevices) return true;
    return _devices.length < IapConstants.freeDeviceLimit;
  }

  int deviceLimit(ShopProvider shop) =>
      shop.hasUnlimitedDevices ? -1 : IapConstants.freeDeviceLimit;

  int photoLimit(ShopProvider shop) =>
      shop.hasMultiPhotos ? 10 : IapConstants.freePhotoLimit;

  Future<WarrantyDevice?> addDevice({
    required String name,
    String category = 'electronics',
    String serialNumber = '',
    String invoiceNumber = '',
    String storeName = '',
    required DateTime purchaseDate,
    required DateTime warrantyExpiryDate,
    List<String> photoPaths = const [],
    String? invoicePhotoPath,
    String notes = '',
    List<String> tags = const [],
    String emoji = '',
    ShopProvider? shop,
  }) async {
    if (name.trim().isEmpty) return null;
    if (shop != null && !canAddDevice(shop)) return null;

    final device = WarrantyDevice.create(
      name: name,
      category: category,
      serialNumber: serialNumber,
      invoiceNumber: invoiceNumber,
      storeName: storeName,
      purchaseDate: purchaseDate,
      warrantyExpiryDate: warrantyExpiryDate,
      photoPaths: photoPaths,
      invoicePhotoPath: invoicePhotoPath,
      notes: notes,
      tags: tags,
      emoji: emoji,
    );
    _devices.insert(0, device);
    await _save();
    notifyListeners();

    if (shop != null) {
      await shop.addCoins(IapConstants.addDeviceReward, 'deviceAddedReward');
      if (invoicePhotoPath != null) {
        await shop.addCoins(IapConstants.addPhotoReward, 'invoiceAddedReward');
      }
    }
    return device;
  }

  Future<void> updateDevice(WarrantyDevice device) async {
    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index < 0) return;
    _devices[index] = device;
    await _save();
    notifyListeners();
  }

  Future<void> deleteDevice(String id) async {
    final device = findById(id);
    if (device == null) return;
    await ImageStorageService.instance.deleteImages(device.photoPaths);
    await ImageStorageService.instance.deleteImage(device.invoicePhotoPath);
    _devices.removeWhere((d) => d.id == id);
    await _save();
    notifyListeners();
  }

  WarrantyDevice? findById(String id) {
    try {
      return _devices.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addPhoto(String deviceId, String path, {ShopProvider? shop}) async {
    final device = findById(deviceId);
    if (device == null) return;
    final limit = shop != null ? photoLimit(shop) : IapConstants.freePhotoLimit;
    if (device.photoPaths.length >= limit) return;

    final updated = device.copyWith(photoPaths: [...device.photoPaths, path]);
    await updateDevice(updated);

    if (shop != null) {
      final reward = await _awardActionReward();
      if (reward > 0) {
        await shop.addCoins(reward, 'photoAddedReward');
      }
    }
  }

  Future<void> removePhoto(String deviceId, String path) async {
    final device = findById(deviceId);
    if (device == null) return;
    await ImageStorageService.instance.deleteImage(path);
    final paths = device.photoPaths.where((p) => p != path).toList();
    await updateDevice(device.copyWith(photoPaths: paths));
  }

  Future<void> setInvoicePhoto(String deviceId, String? path, {ShopProvider? shop}) async {
    final device = findById(deviceId);
    if (device == null) return;
    if (device.invoicePhotoPath != null && device.invoicePhotoPath != path) {
      await ImageStorageService.instance.deleteImage(device.invoicePhotoPath);
    }
    await updateDevice(device.copyWith(invoicePhotoPath: path, clearInvoicePhoto: path == null));

    if (shop != null && path != null) {
      final reward = await _awardActionReward();
      if (reward > 0) {
        await shop.addCoins(reward, 'invoiceAddedReward');
      }
    }
  }

  Future<int> _awardActionReward() async {
    final today = _dateKey(DateTime.now());
    final lastDate = await StorageService.instance.getString(_actionRewardsKey);
    var count = await StorageService.instance.getInt(_actionRewardsCountKey) ?? 0;
    if (lastDate != today) {
      count = 0;
      await StorageService.instance.saveString(_actionRewardsKey, today);
    }
    if (count >= IapConstants.maxActionRewardsPerDay) return 0;

    count++;
    await StorageService.instance.saveInt(_actionRewardsCountKey, count);
    return IapConstants.addPhotoReward;
  }

  Future<String> exportCsv({bool hasExport = false}) async {
    if (!hasExport) return '';
    final buffer = StringBuffer(
      'Device,Category,Serial,Invoice,Store,Purchase Date,Warranty Expiry,Status,Notes\n',
    );
    for (final d in _devices) {
      buffer.writeln([
        _csvEscape(d.name),
        _csvEscape(d.category),
        _csvEscape(d.serialNumber),
        _csvEscape(d.invoiceNumber),
        _csvEscape(d.storeName),
        d.purchaseDate.toIso8601String(),
        d.warrantyExpiryDate.toIso8601String(),
        d.warrantyStatus.name,
        _csvEscape(d.notes),
      ].join(','));
    }
    return buffer.toString();
  }

  Future<void> shareExport({required bool hasExport}) async {
    final csv = await exportCsv(hasExport: hasExport);
    if (csv.isEmpty) return;
    await Share.share(csv, subject: 'Warranty Wallet Export');
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
