import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/image_storage_service.dart';
import '../../models/warranty_device.dart';
import '../../providers/devices_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_toast.dart';

class DeviceFormSheet extends StatefulWidget {
  final WarrantyDevice? device;

  const DeviceFormSheet({super.key, this.device});

  static Future<void> show(BuildContext context, {WarrantyDevice? device}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DeviceFormSheet(device: device),
    );
  }

  @override
  State<DeviceFormSheet> createState() => _DeviceFormSheetState();
}

class _DeviceFormSheetState extends State<DeviceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _invoiceCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _category = 'electronics';
  String _emoji = '📦';
  DateTime? _purchaseDate;
  DateTime? _warrantyExpiry;
  List<String> _tags = [];
  String? _invoicePhotoPath;
  bool _saving = false;

  bool get isEditing => widget.device != null;

  @override
  void initState() {
    super.initState();
    final d = widget.device;
    if (d != null) {
      _nameCtrl.text = d.name;
      _serialCtrl.text = d.serialNumber;
      _invoiceCtrl.text = d.invoiceNumber;
      _storeCtrl.text = d.storeName;
      _notesCtrl.text = d.notes;
      _category = d.category;
      _emoji = d.emoji;
      _purchaseDate = d.purchaseDate;
      _warrantyExpiry = d.warrantyExpiryDate;
      _tags = List.from(d.tags);
      _invoicePhotoPath = d.invoicePhotoPath;
    } else {
      _purchaseDate = DateTime.now();
      _warrantyExpiry = DateTime.now().add(const Duration(days: 365));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _serialCtrl.dispose();
    _invoiceCtrl.dispose();
    _storeCtrl.dispose();
    _notesCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool purchase) async {
    final initial = purchase ? (_purchaseDate ?? DateTime.now()) : (_warrantyExpiry ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (purchase) {
        _purchaseDate = picked;
        if (_warrantyExpiry != null && _warrantyExpiry!.isBefore(picked)) {
          _warrantyExpiry = picked.add(const Duration(days: 365));
        }
      } else {
        _warrantyExpiry = picked;
      }
    });
  }

  Future<void> _pickInvoicePhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final path = await ImageStorageService.instance.saveImage(File(file.path));
    setState(() => _invoicePhotoPath = path);
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    final shop = context.read<ShopProvider>();
    if (!shop.hasCustomTags) {
      AppToast.show(context, title: AppStrings.t(context, 'customTagsLocked'), icon: Icons.lock_outline);
      return;
    }
    setState(() {
      _tags.add(tag);
      _tagCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_purchaseDate == null || _warrantyExpiry == null) return;

    setState(() => _saving = true);
    final devices = context.read<DevicesProvider>();
    final shop = context.read<ShopProvider>();

    if (isEditing) {
      final updated = widget.device!.copyWith(
        name: _nameCtrl.text.trim(),
        category: _category,
        serialNumber: _serialCtrl.text.trim(),
        invoiceNumber: _invoiceCtrl.text.trim(),
        storeName: _storeCtrl.text.trim(),
        purchaseDate: _purchaseDate!,
        warrantyExpiryDate: _warrantyExpiry!,
        invoicePhotoPath: _invoicePhotoPath,
        notes: _notesCtrl.text.trim(),
        tags: _tags,
        emoji: _emoji,
      );
      await devices.updateDevice(updated);
    } else {
      await devices.addDevice(
        name: _nameCtrl.text.trim(),
        category: _category,
        serialNumber: _serialCtrl.text.trim(),
        invoiceNumber: _invoiceCtrl.text.trim(),
        storeName: _storeCtrl.text.trim(),
        purchaseDate: _purchaseDate!,
        warrantyExpiryDate: _warrantyExpiry!,
        invoicePhotoPath: _invoicePhotoPath,
        notes: _notesCtrl.text.trim(),
        tags: _tags,
        emoji: _emoji,
        shop: shop,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final dateFmt = DateFormat.yMMMd();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      AppStrings.t(context, isEditing ? 'editDevice' : 'addDevice'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'deviceName')),
                        validator: (v) => v == null || v.trim().isEmpty ? AppStrings.t(context, 'nameRequired') : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'deviceCategory')),
                        items: DeviceCategory.values
                            .map((c) => DropdownMenuItem(value: c.name, child: Text(AppStrings.t(context, c.labelKey))))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _category = v;
                            _emoji = WarrantyDevice.emojiForCategory(v);
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _serialCtrl,
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'serialNumber')),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _invoiceCtrl,
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'invoiceNumber')),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _storeCtrl,
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'storeName')),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppStrings.t(context, 'purchaseDate')),
                        subtitle: Text(_purchaseDate != null ? dateFmt.format(_purchaseDate!) : AppStrings.t(context, 'selectDate')),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: () => _pickDate(true),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppStrings.t(context, 'warrantyExpiry')),
                        subtitle: Text(_warrantyExpiry != null ? dateFmt.format(_warrantyExpiry!) : AppStrings.t(context, 'selectDate')),
                        trailing: const Icon(Icons.event_available_outlined),
                        onTap: () => _pickDate(false),
                      ),
                      const SizedBox(height: 8),
                      Text(AppStrings.t(context, 'invoice'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (_invoicePhotoPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_invoicePhotoPath!), height: 120, width: double.infinity, fit: BoxFit.cover),
                        )
                      else
                        Text(AppStrings.t(context, 'noInvoicePhoto'), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickInvoicePhoto,
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(AppStrings.t(context, 'addInvoice')),
                      ),
                      if (shop.hasCustomTags) ...[
                        const SizedBox(height: 16),
                        Text(AppStrings.t(context, 'tags'), style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagCtrl,
                                decoration: InputDecoration(hintText: AppStrings.t(context, 'addTag')),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            IconButton(onPressed: _addTag, icon: const Icon(Icons.add_circle_outline)),
                          ],
                        ),
                        if (_tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            children: _tags
                                .map((t) => Chip(
                                      label: Text(t),
                                      onDeleted: () => setState(() => _tags.remove(t)),
                                    ))
                                .toList(),
                          ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'notes')),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(AppStrings.t(context, 'save')),
                      ),
                    ],
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
