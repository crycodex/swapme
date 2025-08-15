import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/swap/swap_controller.dart';
import '../atoms/condition_chip.dart';

class SwapFormSection extends StatelessWidget {
  final SwapController controller;

  const SwapFormSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              'Detalles del artículo',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            _buildTextField(
              context: context,
              controller: controller.nameController,
              label: 'Nombre',
              hint: 'Ej: Camiseta Nike',
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 16),

            // Description field
            _buildTextField(
              context: context,
              controller: controller.descriptionController,
              label: 'Descripción',
              hint: 'Describe tu artículo...',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Category selection
            Text(
              'Categoría',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => _buildCategorySelector(context)),
            const SizedBox(height: 20),

            // Size selection
            Text(
              'Talla',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => _buildSizeSelector(context)),
            const SizedBox(height: 20),

            // Price slider
            Text(
              'Precio estimado',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => _buildPriceSlider(context)),
            const SizedBox(height: 20),

            // Condition selection
            Text(
              'Estado',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => _buildConditionSelector(context)),
            const SizedBox(height: 32),

            // Submit button
            Obx(() => _buildSubmitButton(context)),

            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: colorScheme.primary),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return DropdownButtonFormField<String>(
      value: controller.selectedSize.value,
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ),
      items: controller.sizes.map((String size) {
        return DropdownMenuItem<String>(value: size, child: Text(size));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.updateSize(newValue);
        }
      },
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<String> categories = controller.categories
        .where((String c) => c != 'Todos')
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((String cat) {
        final bool selected = controller.selectedCategory.value == cat;
        return GestureDetector(
          onTap: () => controller.updateCategory(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? colorScheme.secondary : colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? colorScheme.secondary
                    : colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              cat,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? colorScheme.onSecondary
                    : colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSlider(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${controller.estimatedPrice.value.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '\$100',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.2),
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: controller.estimatedPrice.value,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (double value) {
              controller.updatePrice(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.conditions.map((String condition) {
        return ConditionChip(
          label: condition,
          isSelected: controller.selectedCondition.value == condition,
          onTap: () => controller.updateCondition(condition),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.createSwapItem(),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: controller.isLoading.value
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Crear Swap',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
