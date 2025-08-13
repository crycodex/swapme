import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/swap_item_model.dart';

class SwapDetailPage extends StatelessWidget {
  const SwapDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SwapItemModel item = Get.arguments as SwapItemModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(item.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.size),
                ),
                const SizedBox(width: 8),
                Text(item.condition, style: theme.textTheme.bodyMedium),
                const Spacer(),
                Icon(Icons.attach_money, color: colorScheme.primary, size: 18),
                Text(
                  item.estimatedPrice.toStringAsFixed(0),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Intercambiar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
