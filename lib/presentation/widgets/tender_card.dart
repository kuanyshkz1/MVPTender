import 'package:flutter/material.dart';

import '../../core/utils/app_formatters.dart';
import '../../domain/entities/tender.dart';

class TenderCard extends StatelessWidget {
  final Tender tender;
  final bool showNumber;
  final bool showTitle;
  final bool showCustomer;
  final bool showPrice;
  final bool showStatus;
  final bool showEndDate;
  final VoidCallback? onTap;

  const TenderCard({
    super.key,
    required this.tender,
    this.showNumber = true,
    this.showTitle = true,
    this.showCustomer = true,
    this.showPrice = true,
    this.showStatus = true,
    this.showEndDate = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(context);
    final hasHeader = showNumber || showStatus;
    final hasContent = showTitle || showCustomer;
    final hasBottom = showPrice || showEndDate;

    return Card(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasHeader)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (showNumber)
                      _Badge(
                        icon: Icons.tag_rounded,
                        label: tender.number,
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    if (showStatus)
                      _StatusBadge(label: tender.status, color: statusColor),
                  ],
                ),
              if (hasHeader && hasContent) const SizedBox(height: 12),
              if (showTitle)
                Text(
                  tender.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              if (showTitle && showCustomer) const SizedBox(height: 12),
              if (showCustomer) _CustomerBlock(tender: tender),
              if (hasContent && hasBottom) ...[
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 14),
              ],
              if (hasBottom)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showPrice)
                      Expanded(child: _PriceBlock(price: tender.price)),
                    if (showPrice && showEndDate) const SizedBox(width: 12),
                    if (showEndDate) _EndDateBadge(endDate: tender.endDate),
                  ],
                ),
              if (onTap != null) ...[
                const SizedBox(height: 14),
                _DetailsHint(colorScheme: colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = tender.status.toLowerCase();

    if (normalized.contains('прием') ||
        normalized.contains('приём') ||
        normalized.contains('актив')) {
      return isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    }
    if (normalized.contains('заверш') || normalized.contains('отмен')) {
      return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

class _CustomerBlock extends StatelessWidget {
  final Tender tender;

  const _CustomerBlock({required this.tender});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.business_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tender.customer,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'БИН ${tender.bin}',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceBlock extends StatelessWidget {
  final double price;

  const _PriceBlock({required this.price});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Бюджет',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            AppFormatters.money(price),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _EndDateBadge extends StatelessWidget {
  final DateTime endDate;

  const _EndDateBadge({required this.endDate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(endDate.year, endDate.month, endDate.day);
    final daysLeft = dueDate.difference(today).inDays;
    final isExpired = endDate.isBefore(now);
    final isUrgent = daysLeft <= 3;
    final accent = isUrgent
        ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
        : colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isExpired ? 'Истекло' : 'До',
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            AppFormatters.dayMonth(endDate),
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            AppFormatters.time(endDate),
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return _Badge(
      icon: Icons.circle,
      label: label,
      color: color,
      backgroundColor: color.withValues(alpha: 0.11),
      smallIcon: true,
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final bool smallIcon;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.smallIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: smallIcon ? 7 : 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsHint extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DetailsHint({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Подробнее',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.arrow_forward_rounded,
            color: colorScheme.primary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
