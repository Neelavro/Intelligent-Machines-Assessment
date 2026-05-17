import 'package:hive_flutter/hive_flutter.dart';
import 'package:intelligent_machines_assessment/data/model/upload_item_model.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';

class CameraLocalDatasource {
  static const _boxName = 'upload_queue';

  Box<UploadItemModel>? _box;

  Future<Box<UploadItemModel>> get _openBox async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<UploadItemModel>(_boxName);
    return _box!;
  }

  Future<List<UploadItemModel>> getQueue() async {
    final box = await _openBox;
    final items = box.keys
        .map((k) => box.get(k)!.copyWith(id: k as int))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<List<UploadItemModel>> getPendingItems() async {
    final box = await _openBox;
    return box.keys
        .map((k) => box.get(k)!.copyWith(id: k as int))
        .where((i) =>
            i.status == UploadStatus.queued ||
            i.status == UploadStatus.retrying)
        .toList();
  }

  Future<int> insertItem(UploadItemModel item) async {
    final box = await _openBox;
    return await box.add(item);
  }

  Future<void> updateStatus(
    int id,
    UploadStatus status, {
    int? retryCount,
  }) async {
    final box = await _openBox;
    final item = box.get(id);
    if (item == null) return;
    await box.put(id, item.copyWith(status: status, retryCount: retryCount));
  }

  Future<void> deleteItem(int id) async {
    final box = await _openBox;
    await box.delete(id);
  }

  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
