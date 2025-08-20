import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/swap_item_model.dart';
import '../../../controllers/swap/swap_controller.dart';
import 'proposal_widgets.dart';

class ProductSelector extends StatefulWidget {
  final Function(SwapItemModel product)? onProductSelected;
  final Function(double amount)? onMoneySelected;
  final Function()? onClosePressed;

  const ProductSelector({
    super.key,
    this.onProductSelected,
    this.onMoneySelected,
    this.onClosePressed,
  });

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> {
  final SwapController _swapController = Get.put(SwapController());
  SwapItemModel? selectedProduct;
  double selectedAmount = 10.0;
  String selectedProposalType = 'product'; // 'money' o 'product'

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hacer una propuesta',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (widget.onClosePressed != null)
                  IconButton(
                    onPressed: widget.onClosePressed,
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Selector de tipo de propuesta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ProposalTypeTab(
                    icon: Icons.inventory_2,
                    label: 'Producto',
                    isSelected: selectedProposalType == 'product',
                    onTap: () => setState(() {
                      selectedProposalType = 'product';
                    }),
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProposalTypeTab(
                    icon: Icons.attach_money,
                    label: 'Dinero',
                    isSelected: selectedProposalType == 'money',
                    onTap: () => setState(() {
                      selectedProposalType = 'money';
                      selectedProduct = null;
                    }),
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content based on selection
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: selectedProposalType == 'product'
                ? ProductsList(
                    swapController: _swapController,
                    selectedProduct: selectedProduct,
                    onProductSelected: (product) => setState(() {
                      selectedProduct = product;
                    }),
                    colorScheme: colorScheme,
                    theme: theme,
                  )
                : MoneySelector(
                    selectedAmount: selectedAmount,
                    onAmountChanged: (amount) => setState(() {
                      selectedAmount = amount;
                    }),
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
          ),

          // Action buttons
          if ((selectedProposalType == 'product' && selectedProduct != null) ||
              selectedProposalType == 'money')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedProduct = null;
                          selectedAmount = 10.0;
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (selectedProposalType == 'product') {
                          widget.onProductSelected?.call(selectedProduct!);
                        } else if (selectedProposalType == 'money') {
                          widget.onMoneySelected?.call(selectedAmount);
                        }
                      },
                      child: Text(
                        selectedProposalType == 'product'
                            ? 'Proponer producto'
                            : 'Proponer \$${selectedAmount.toStringAsFixed(0)}',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
