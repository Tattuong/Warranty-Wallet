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
import 'device_form_sheet.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DevicesProvider>();
    final shop = context.watch<ShopProvider>();
    final device = devices.findById(deviceId);
    final dateFmt = DateFormat.yMMMd();

    if (device == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Device not found')),
      );
    }

    final photoLimit = devices.photoLimit(shop);

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => DeviceFormSheet.show(context, device: device),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, devices),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPhoto(context, devices, shop, photoLimit),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeaderCard(device: device),
          const SizedBox(height: 16),
          _InfoSection(
            title: AppStrings.t(context, 'deviceDetail'),
            rows: [
              _InfoRow(AppStrings.t(context, 'deviceCategory'), AppStrings.t(context, device.deviceCategory.labelKey)),
              _InfoRow(AppStrings.t(context, 'serialNumber'), device.serialNumber.isNotEmpty ? device.serialNumber : AppStrings.t(context, 'noSerial')),
              _InfoRow(AppStrings.t(context, 'invoiceNumber'), device.invoiceNumber.isNotEmpty ? device.invoiceNumber : AppStrings.t(context, 'noInvoice')),
              _InfoRow(AppStrings.t(context, 'storeName'), device.storeName.isNotEmpty ? device.storeName : '—'),
              _InfoRow(AppStrings.t(context, 'purchaseDate'), dateFmt.format(device.purchaseDate)),
              _InfoRow(AppStrings.t(context, 'warrantyExpiry'), dateFmt.format(device.warrantyExpiryDate)),
              _InfoRow(
                AppStrings.t(context, 'warrantyActive'),
                AppStrings.t(context, device.warrantyStatus == WarrantyStatus.expired
                    ? 'warrantyExpired'
                    : device.warrantyStatus == WarrantyStatus.expiringSoon
                        ? 'warrantyExpiringSoon'
                        : 'warrantyActive'),
              ),
            ],
          ),
          if (device.invoicePhotoPath != null) ...[
            const SizedBox(height: 16),
            Text(AppStrings.t(context, 'invoice'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(device.invoicePhotoPath!), height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text(AppStrings.t(context, 'photos'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              Text('${device.photoPaths.length}/$photoLimit', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          if (device.photoPaths.isEmpty)
            Text(AppStrings.t(context, 'noPhotos'), style: const TextStyle(color: AppColors.onSurfaceVariant))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: device.photoPaths.length,
              itemBuilder: (_, i) {
                final path = device.photoPaths[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => devices.removePhoto(deviceId, path),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          if (device.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: AppStrings.t(context, 'notes'),
              rows: [_InfoRow('', device.notes)],
            ),
          ],
          if (device.tags.isNotEmpty && shop.hasCustomTags) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: device.tags
                  .asMap()
                  .entries
                  .map((e) => Chip(label: Text(e.value), backgroundColor: AppColors.tagPalette[e.key % AppColors.tagPalette.length].withValues(alpha: 0.15)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _addPhoto(BuildContext context, DevicesProvider devices, ShopProvider shop, int limit) async {
    final device = devices.findById(deviceId);
    if (device == null) return;
    if (device.photoPaths.length >= limit) {
      AppToast.show(
        context,
        title: AppStrings.t(context, 'photoLimitReached', {'limit': limit.toString()}),
        icon: Icons.lock_outline,
      );
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final path = await ImageStorageService.instance.saveImage(File(file.path));
    await devices.addPhoto(deviceId, path, shop: shop);
  }

  Future<void> _confirmDelete(BuildContext context, DevicesProvider devices) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'deleteDevice')),
        content: Text(AppStrings.t(context, 'deleteDeviceConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t(context, 'delete')),
          ),
        ],
      ),
    );
    if (ok == true) {
      await devices.deleteDevice(deviceId);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final WarrantyDevice device;

  const _HeaderCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: context.watch<ShopProvider>().activeTheme.headerGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(device.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                Text(
                  AppStrings.t(context, device.deviceCategory.labelKey),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _InfoSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          ] else
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
