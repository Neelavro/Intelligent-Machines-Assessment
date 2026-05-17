import 'package:flutter/material.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';

class UploadCard extends StatelessWidget {
  final UploadItemEntity item;

  const UploadCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.status == UploadStatus.retrying
                  ? const Color(0xFF3A2A2A)
                  : const Color(0xFF2A3340),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.image_outlined,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.filename,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.status == UploadStatus.uploading)
                      const Text(
                        'UPLOADING',
                        style: TextStyle(
                          color: Color(0xFF2E6BFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.formattedSize,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                _StatusLine(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final UploadItemEntity item;

  const _StatusLine({required this.item});

  @override
  Widget build(BuildContext context) {
    switch (item.status) {
      case UploadStatus.queued:
        return _statusText('WAITING FOR CONNECTION', const Color(0xFFF59E0B));
      case UploadStatus.retrying:
        return _statusText(
          'RETRYING... (ATTEMPT ${item.retryCount}/${item.maxRetries})',
          const Color(0xFFEF4444),
        );
      case UploadStatus.uploading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusText('UPLOADING...', const Color(0xFF2E6BFF)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2E6BFF)),
              ),
            ),
          ],
        );
      case UploadStatus.synced:
        return const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
            SizedBox(width: 5),
            Text(
              'SYNCED',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        );
      case UploadStatus.failed:
        return _statusText('FAILED — MAX RETRIES REACHED', const Color(0xFFEF4444));
    }
  }

  Widget _statusText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}
