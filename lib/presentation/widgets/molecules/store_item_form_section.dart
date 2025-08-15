import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/store/store_controller.dart';

class StoreItemFormSection extends StatelessWidget {
  final StoreController controller;
  const StoreItemFormSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextField(
              controller: controller.itemNameController,
              decoration: InputDecoration(
                labelText: 'Nombre del artículo',
                hintText: 'Ej: Camiseta Nike',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextField(
              controller: controller.itemDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe tu artículo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Price field
            TextField(
              controller: controller.itemPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Precio',
                hintText: '\$0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),

            // Condition selector
            Text(
              'Condición',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              return Wrap(
                spacing: 8,
                children: controller.conditions.map((String condition) {
                  final bool isSelected =
                      controller.selectedItemCondition.value == condition;
                  return ChoiceChip(
                    label: Text(condition),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.updateItemCondition(condition),
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 20),

            // Category selector
            Text(
              'Categoría',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              return Wrap(
                spacing: 8,
                children: controller.itemCategories.map((String category) {
                  final bool isSelected =
                      controller.selectedItemCategory.value == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => controller.updateItemCategory(category),
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 80), // Extra space for button
          ],
        ),
      ),
    );
  }
}
