import 'package:uuid/uuid.dart';

enum DeviceCategory {
  electronics,
  appliance,
  computer,
  phone,
  furniture,
  vehicle,
  other;

  String get labelKey => switch (this) {
        DeviceCategory.electronics => 'catElectronics',
        DeviceCategory.appliance => 'catAppliance',
        DeviceCategory.computer => 'catComputer',
        DeviceCategory.phone => 'catPhone',
        DeviceCategory.furniture => 'catFurniture',
        DeviceCategory.vehicle => 'catVehicle',
        DeviceCategory.other => 'catOther',
      };

  static DeviceCategory fromString(String value) {
    return DeviceCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => DeviceCategory.other,
    );
  }
}

enum WarrantyStatus {
  active,
  expiringSoon,
  expired;

  bool get isExpired => this == WarrantyStatus.expired;
  bool get isExpiringSoon => this == WarrantyStatus.expiringSoon;
}

class WarrantyDevice {
  final String id;
  final String name;
  final String category;
  final String serialNumber;
  final String invoiceNumber;
  final String storeName;
  final DateTime purchaseDate;
  final DateTime warrantyExpiryDate;
  final List<String> photoPaths;
  final String? invoicePhotoPath;
  final String notes;
  final List<String> tags;
  final String emoji;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WarrantyDevice({
    required this.id,
    required this.name,
    this.category = 'electronics',
    this.serialNumber = '',
    this.invoiceNumber = '',
    this.storeName = '',
    required this.purchaseDate,
    required this.warrantyExpiryDate,
    this.photoPaths = const [],
    this.invoicePhotoPath,
    this.notes = '',
    this.tags = const [],
    this.emoji = '📦',
    required this.createdAt,
    required this.updatedAt,
  });

  DeviceCategory get deviceCategory => DeviceCategory.fromString(category);

  WarrantyStatus get warrantyStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(warrantyExpiryDate.year, warrantyExpiryDate.month, warrantyExpiryDate.day);
    if (expiry.isBefore(today)) return WarrantyStatus.expired;
    if (expiry.difference(today).inDays <= 30) return WarrantyStatus.expiringSoon;
    return WarrantyStatus.active;
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(warrantyExpiryDate.year, warrantyExpiryDate.month, warrantyExpiryDate.day);
    return expiry.difference(today).inDays;
  }

  int get warrantyMonths {
    final months = ((warrantyExpiryDate.year - purchaseDate.year) * 12) +
        warrantyExpiryDate.month -
        purchaseDate.month;
    return months.clamp(0, 999);
  }

  factory WarrantyDevice.create({
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
  }) {
    final now = DateTime.now();
    return WarrantyDevice(
      id: const Uuid().v4(),
      name: name.trim(),
      category: category,
      serialNumber: serialNumber.trim(),
      invoiceNumber: invoiceNumber.trim(),
      storeName: storeName.trim(),
      purchaseDate: purchaseDate,
      warrantyExpiryDate: warrantyExpiryDate,
      photoPaths: photoPaths,
      invoicePhotoPath: invoicePhotoPath,
      notes: notes.trim(),
      tags: tags,
      emoji: emoji.isNotEmpty ? emoji : emojiForCategory(category),
      createdAt: now,
      updatedAt: now,
    );
  }

  static String emojiForCategory(String category) => switch (category) {
        'electronics' => '📱',
        'appliance' => '🏠',
        'computer' => '💻',
        'phone' => '📱',
        'furniture' => '🪑',
        'vehicle' => '🚗',
        _ => '📦',
      };

  WarrantyDevice copyWith({
    String? name,
    String? category,
    String? serialNumber,
    String? invoiceNumber,
    String? storeName,
    DateTime? purchaseDate,
    DateTime? warrantyExpiryDate,
    List<String>? photoPaths,
    String? invoicePhotoPath,
    bool clearInvoicePhoto = false,
    String? notes,
    List<String>? tags,
    String? emoji,
  }) {
    return WarrantyDevice(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      serialNumber: serialNumber ?? this.serialNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      storeName: storeName ?? this.storeName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyExpiryDate: warrantyExpiryDate ?? this.warrantyExpiryDate,
      photoPaths: photoPaths ?? this.photoPaths,
      invoicePhotoPath: clearInvoicePhoto ? null : (invoicePhotoPath ?? this.invoicePhotoPath),
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'serialNumber': serialNumber,
        'invoiceNumber': invoiceNumber,
        'storeName': storeName,
        'purchaseDate': purchaseDate.toIso8601String(),
        'warrantyExpiryDate': warrantyExpiryDate.toIso8601String(),
        'photoPaths': photoPaths,
        'invoicePhotoPath': invoicePhotoPath,
        'notes': notes,
        'tags': tags,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WarrantyDevice.fromJson(Map<String, dynamic> json) => WarrantyDevice(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? 'other',
        serialNumber: json['serialNumber'] as String? ?? '',
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        storeName: json['storeName'] as String? ?? '',
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        warrantyExpiryDate: DateTime.parse(json['warrantyExpiryDate'] as String),
        photoPaths: (json['photoPaths'] as List?)?.cast<String>() ?? [],
        invoicePhotoPath: json['invoicePhotoPath'] as String?,
        notes: json['notes'] as String? ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        emoji: json['emoji'] as String? ?? '📦',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
