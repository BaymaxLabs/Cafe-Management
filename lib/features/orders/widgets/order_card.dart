import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.onAssign});

  final Order order;
  final VoidCallback? onAssign;

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.breached:
        return const Color(0xFFE53935);
      case OrderStatus.urgent:
        return const Color(0xFFFF6F00);
      case OrderStatus.onTrack:
        return const Color(0xFF43A047);
      case OrderStatus.unassigned:
        return AppColors.textMuted;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.breached:
        return 'Breached';
      case OrderStatus.urgent:
        return 'Urgent';
      case OrderStatus.onTrack:
        return 'On Track';
      case OrderStatus.unassigned:
        return 'Unassigned';
    }
  }

  String get _slaText {
    final remaining = order.slaRemainingMinutes;
    if (remaining < 0) return '+${(-remaining)}m over SLA';
    return '${remaining}m remaining';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _statusColor, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + status badge
            Row(
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _StatusBadge(label: _statusLabel, color: _statusColor),
              ],
            ),
            const SizedBox(height: 4),
            // Table + items
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.table,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    order.itemsLabel,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              order.typeLabel,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            // SLA progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: order.slaProgress,
                minHeight: 3,
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              ),
            ),
            const SizedBox(height: 6),
            // Elapsed + SLA text
            Row(
              children: [
                Text(
                  '${order.elapsedMinutes}m elapsed',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _slaText,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Staff row
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3A3A3A)),
                  ),
                  child: Center(
                    child: Text(
                      order.assignedStaff != null
                          ? order.assignedStaff![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.assignedStaff ?? 'Unassigned',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (order.assignedStaff == null)
                  GestureDetector(
                    onTap: onAssign,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF3A3A3A)),
                      ),
                      child: const Text(
                        'Assign',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
