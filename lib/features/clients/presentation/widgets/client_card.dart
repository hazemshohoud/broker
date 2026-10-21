import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/launcher.dart';
import '../../domain/entities/broker_client.dart';

/// كارت عميل: الاسم، الرقم، اهتمامه، وأزرار اتصال/واتساب/حذف.
class ClientCard extends StatelessWidget {
  const ClientCard({required this.client, required this.onDelete, super.key});

  final BrokerClient client;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.brand.withValues(alpha: 0.12),
                child: Text(
                  client.name.isEmpty ? '؟' : client.name.characters.first,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          IconsaxPlusLinear.call,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          client.phone,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  IconsaxPlusLinear.heart,
                  size: 14,
                  color: AppColors.brandDark,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'مهتم بـ ${client.interest}',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.brandDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (client.note != null && client.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  IconsaxPlusLinear.note,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    client.note!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                Formatters.date(client.createdAt),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              _CardAction(
                icon: IconsaxPlusLinear.call,
                color: AppColors.brandDark,
                label: 'اتصال',
                onTap: () => Launcher.call(client.phone),
              ),
              const SizedBox(width: 8),
              _CardAction(
                icon: IconsaxPlusLinear.message,
                color: AppColors.whatsapp,
                label: 'واتساب',
                onTap: () => Launcher.whatsapp(client.phone),
              ),
              const SizedBox(width: 8),
              _CardAction(
                icon: IconsaxPlusLinear.trash,
                color: AppColors.favorite,
                label: 'حذف',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
