import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher_string.dart';

enum SubscriptionAlertKind { expiring, ended }

class SubscriptionAlertRow extends StatelessWidget {
  const SubscriptionAlertRow({
    super.key,
    required this.subscription,
    required this.name,
    required this.phone,
    required this.kind,
    this.onTap,
    this.onEndSubscription,
    this.ending = false,
  });

  final Subscription subscription;
  final String name;
  final String phone;
  final SubscriptionAlertKind kind;
  final VoidCallback? onTap;
  final VoidCallback? onEndSubscription;
  final bool ending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final todayKey = DateTime.now();
    final normalizedToday = DateTime(todayKey.year, todayKey.month, todayKey.day);
    final remaining = subscription.remainingDaysFrom(normalizedToday);
    final urgency = kind == SubscriptionAlertKind.ended
        ? AppColors.accentRed
        : AppColors.expiryUrgency(remaining);
    final endDateStr = DateFormat.yMMMd('ar_EG').format(subscription.endDate);
    final hasPhone = phone.isNotEmpty;

    String subtitle;
    if (kind == SubscriptionAlertKind.ended || remaining <= 0) {
      subtitle = l10n.subscriptionExpired;
    } else if (remaining == 1) {
      subtitle = l10n.endsOnOneDayLeft(endDateStr);
    } else {
      subtitle = l10n.endsOnDaysLeft(endDateStr, remaining);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onTap: onTap,
        borderColor: urgency.withValues(alpha: 0.5),
        backgroundColor: urgency.withValues(alpha: 0.08),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: switch (kind) {
                SubscriptionAlertKind.ended when onEndSubscription != null => 72,
                SubscriptionAlertKind.ended => hasPhone ? 56 : 48,
                SubscriptionAlertKind.expiring => hasPhone ? 48 : 40,
              },
              decoration: BoxDecoration(
                color: urgency,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  if (hasPhone) ...[
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: urgency,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (kind == SubscriptionAlertKind.ended && onEndSubscription != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: ending ? null : onEndSubscription,
                      icon: ending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(l10n.endSubscription),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentRed,
                        side: const BorderSide(color: AppColors.accentRed),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (kind == SubscriptionAlertKind.expiring && hasPhone)
              IconButton.filledTonal(
                onPressed: () async {
                  final message = l10n.whatsappReminder(name, endDateStr);
                  await launchUrlString(
                    'https://wa.me/${phone.replaceAll(RegExp(r'\D'), '')}?text=${Uri.encodeComponent(message)}',
                  );
                },
                icon: const Icon(Icons.chat_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
