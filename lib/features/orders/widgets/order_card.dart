import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onAssign,
    this.isGridTile = false,
  });

  final Order order;
  final VoidCallback? onAssign;
  final bool isGridTile;

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

  String get _gridSlaText {
    final remaining = order.slaRemainingMinutes;
    if (remaining < 0) return '+${(-remaining)}m';
    return '${remaining}m left';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: isGridTile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        // The status accent belongs on the card's top edge in every layout.
        border: Border(top: BorderSide(color: _statusColor, width: 3)),
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
            // Grid cards give the item list its own line to keep the layout
            // balanced; the compact list preserves its denser side-by-side view.
            if (isGridTile)
              Text(
                order.table,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              )
            else
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
            if (isGridTile) ...[
              const SizedBox(height: 20),
              Text(
                order.itemsLabel,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
            ],
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
                  isGridTile
                      ? '${order.elapsedMinutes}m'
                      : '${order.elapsedMinutes}m elapsed',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  isGridTile ? _gridSlaText : _slaText,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (isGridTile) ...[
              const Spacer(),
              const Divider(color: Color(0xFF2A2A2A), height: 21),
            ] else
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
                      child: Text(
                        'Assign',
                        style: TextStyle(
                          color: isGridTile ? AppColors.gold : AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else if (isGridTile)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF173321),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Complete',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
