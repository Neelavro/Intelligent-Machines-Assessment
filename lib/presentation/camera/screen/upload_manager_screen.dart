import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_bloc.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_event.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_state.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/batch_sync_progress.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/status_pill.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/upload_card.dart';

class UploadManagerScreen extends StatefulWidget {
  const UploadManagerScreen({super.key});

  @override
  State<UploadManagerScreen> createState() => _UploadManagerScreenState();
}

class _UploadManagerScreenState extends State<UploadManagerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CameraBloc>().add(const CameraLoadQueueEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        final queue =
            state is CameraReady ? state.uploadQueue : <UploadItemEntity>[];
        final isConnected = state is CameraReady ? state.isConnected : true;

        final synced = queue.where((i) => i.status == UploadStatus.synced).length;
        final total = queue.length;
        final progress = total == 0 ? 0.0 : synced / total;

        final totalBytes = queue.fold<int>(0, (sum, i) => sum + i.fileSizeBytes);
        final syncedBytes = queue
            .where((i) => i.status == UploadStatus.synced)
            .fold<int>(0, (sum, i) => sum + i.fileSizeBytes);

        return Scaffold(
          backgroundColor: const Color(0xFF0B1220),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Upload Manager',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          StatusPill(
                            label: isConnected ? 'STABLE LINK' : 'NO CONNECTION',
                            color: isConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      BatchSyncProgress(
                        progress: progress,
                        uploadedLabel: _formatBytes(syncedBytes),
                        totalLabel: _formatBytes(totalBytes),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PENDING UPLOADS ($total)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: queue.isEmpty
                      ? Center(
                          child: Text(
                            'No pending uploads',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: queue.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => UploadCard(item: queue[i]),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'START NEW UPLOAD BATCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
