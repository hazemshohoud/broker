import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/developer.dart';
import '../pages/developers_page.dart';

class DevelopersList extends StatelessWidget {
  const DevelopersList({super.key, required this.developers});

  final List<Developer> developers;

  static const _size = 62.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size + 8,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: developers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) =>
            _DeveloperAvatar(developer: developers[index]),
      ),
    );
  }
}

class _DeveloperAvatar extends StatelessWidget {
  const _DeveloperAvatar({required this.developer});

  final Developer developer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DevelopersPage.open(context, initialDeveloperName: developer.name),
      child: Container(
        width: DevelopersList._size,
        height: DevelopersList._size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: AppNetworkImage(
          url: developer.logoUrl,
          fit: BoxFit.cover,
          placeholder: Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                developer.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
