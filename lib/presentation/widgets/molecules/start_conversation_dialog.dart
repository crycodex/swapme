import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/store_item_model.dart';
import '../../../data/models/swap_item_model.dart';

class StartConversationDialog extends StatelessWidget {
  final StoreItemModel? storeItem;
  final SwapItemModel? swapItem;
  final Future<String?> Function(BuildContext context, dynamic item)
  showCustomMessageDialog;

  const StartConversationDialog({
    super.key,
    this.storeItem,
    this.swapItem,
    required this.showCustomMessageDialog,
  }) : assert(
         storeItem != null || swapItem != null,
         'Debe proporcionar un storeItem o un swapItem.',
       );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String itemName = storeItem?.name ?? swapItem!.name;

    final List<Map<String, dynamic>> preConfiguredMessages = [
      {
        'icon': Icons.waving_hand,
        'title': 'Saludo amigable',
        'message':
            '¡Hola! Me interesa mucho tu $itemName. ¿Podríamos hablar sobre un posible intercambio?',
      },
      {
        'icon': Icons.swap_horiz,
        'title': 'Propuesta directa',
        'message':
            'Hola, tengo algunos artículos que podrían interesarte para intercambiar por tu $itemName. ¿Te gustaría ver qué tengo?',
      },
      {
        'icon': Icons.info_outline,
        'title': 'Consulta sobre el artículo',
        'message': storeItem != null
            ? 'Me interesa tu $itemName. ¿Podrías contarme más sobre su estado, condición y precio actual?'
            : 'Me interesa tu $itemName. ¿Podrías contarme más sobre su estado, condición y precio estimado actual?',
      },
      {'icon': Icons.edit, 'title': 'Mensaje personalizado', 'message': ''},
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Iniciar Conversación',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Elige una opción para empezar a chatear',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: preConfiguredMessages.length,
              itemBuilder: (context, index) {
                final messageData = preConfiguredMessages[index];
                final bool isCustom = messageData['message'].isEmpty;

                return GestureDetector(
                  onTap: () async {
                    if (isCustom) {
                      final String? customMessage =
                          await showCustomMessageDialog(
                            context,
                            storeItem ?? swapItem,
                          );
                      if (customMessage != null &&
                          customMessage.trim().isNotEmpty) {
                        Get.back(result: customMessage);
                      }
                    } else {
                      Get.back(result: messageData['message']);
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isCustom
                                  ? colorScheme.secondary
                                  : colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              messageData['icon'],
                              color: isCustom
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.surface,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messageData['title'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (!isCustom) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    messageData['message'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ] else ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Escribe tu propio mensaje',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: theme.hintColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: theme.hintColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'El chat expirará automáticamente en 7 días.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
