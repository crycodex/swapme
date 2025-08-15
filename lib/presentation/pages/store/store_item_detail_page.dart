import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/store_item_model.dart';
import '../../../data/models/store_model.dart';
import '../../../controllers/store/store_controller.dart';
import '../../../controllers/chat/chat_controller.dart';
import '../chat/chat_page.dart';

class _StoreArguments {
  final String storeId;
  final String storeName;
  final String? logoUrl;
  const _StoreArguments({
    required this.storeId,
    required this.storeName,
    this.logoUrl,
  });
}

class StoreItemDetailPage extends StatelessWidget {
  const StoreItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final StoreItemModel item = Get.arguments as StoreItemModel;
    final StoreController storeController = Get.put(StoreController());
    final ChatController chatController = Get.put(ChatController());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white, size: 24),
            title: Text(
              'Detalles del producto',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen del artículo
                  Hero(
                    tag: 'store-item-${item.id}',
                    child: Semantics(
                      label: 'Imagen del producto ${item.name}',
                      image: true,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 48,
                            semanticLabel: 'Imagen no disponible',
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradiente superior/inferior para legibilidad
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    item.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chips de categoría y estado
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        context,
                        label: item.category,
                        icon: Icons.category_rounded,
                      ),
                      _buildChip(
                        context,
                        label: item.condition,
                        icon: Icons.check_circle_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  Semantics(
                    label: 'Precio ${item.price.toStringAsFixed(0)} dólares',
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        Text(
                          item.price.toStringAsFixed(0),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tienda
                  const SizedBox(height: 8),
                  _StoreCard(
                    storeId: item.storeId,
                    storeController: storeController,
                    onOpenStore:
                        (String storeId, String storeName, String? logoUrl) {
                          Get.to(
                            () => _StoreItemsPage(
                              args: _StoreArguments(
                                storeId: storeId,
                                storeName: storeName,
                                logoUrl: logoUrl,
                              ),
                            ),
                            transition: Transition.cupertino,
                          );
                        },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.description, style: theme.textTheme.bodyMedium),

                  const SizedBox(height: 20),
                  // Meta información
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(item.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.store_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ID: ${item.id.substring(0, item.id.length > 6 ? 6 : item.id.length)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Semantics(
              button: true,
              label: 'Intercambiar este producto',
              hint: 'Abre el flujo para proponer un intercambio',
              child: FilledButton(
                onPressed: () =>
                    _initiateStoreItemSwap(context, item, chatController),
                child: const Text('Intercambiar'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initiateStoreItemSwap(
    BuildContext context,
    StoreItemModel item,
    ChatController chatController,
  ) async {
    if (chatController.currentUserId == null) {
      Get.snackbar(
        'Error',
        'Debes iniciar sesión para intercambiar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Mostrar diálogo con mensajes preconfigurados
    final String? selectedMessage = await _showPreConfiguredMessagesDialog(
      context,
      item,
    );
    if (selectedMessage == null) return;

    // Mostrar indicador de carga
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Iniciando chat...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Crear o obtener chat existente para item de tienda
      final String? chatId = await chatController.createChatForStoreItem(
        storeItem: item,
        interestedUserId: chatController.currentUserId!,
      );

      Get.back(); // Cerrar diálogo de carga

      if (chatId != null) {
        // Enviar mensaje preconfigurado
        await chatController.sendMessage(
          chatId: chatId,
          content: selectedMessage,
        );

        // Navegar al chat
        Get.to(
          () => ChatPage(chatId: chatId),
          transition: Transition.cupertino,
        );
      } else {
        Get.snackbar(
          'Error',
          'No se pudo crear el chat. Inténtalo de nuevo.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // Cerrar diálogo de carga
      Get.snackbar(
        'Error',
        'Ocurrió un error al crear el chat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> _showPreConfiguredMessagesDialog(
    BuildContext context,
    StoreItemModel item,
  ) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> preConfiguredMessages = [
      {
        'icon': Icons.waving_hand,
        'title': 'Saludo amigable',
        'message':
            '¡Hola! Me interesa mucho tu ${item.name}. ¿Podríamos hablar sobre un posible intercambio?',
      },
      {
        'icon': Icons.swap_horiz,
        'title': 'Propuesta directa',
        'message':
            'Hola, tengo algunos artículos que podrían interesarte para intercambiar por tu ${item.name}. ¿Te gustaría ver qué tengo?',
      },
      {
        'icon': Icons.info_outline,
        'title': 'Consulta sobre condición',
        'message':
            'Me interesa tu ${item.name}. ¿Podrías contarme más sobre su estado y condición actual?',
      },
      {
        'icon': Icons.schedule,
        'title': 'Consulta sobre disponibilidad',
        'message':
            '¡Hola! ¿Tu ${item.name} sigue disponible para intercambio? Me gustaría hacer una propuesta.',
      },
      {
        'icon': Icons.favorite,
        'title': 'Interés genuino',
        'message':
            'Tu ${item.name} es exactamente lo que estaba buscando. ¿Estarías interesado/a en intercambiarlo?',
      },
      {'icon': Icons.edit, 'title': 'Mensaje personalizado', 'message': ''},
    ];

    return await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Iniciar conversación',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Elige cómo quieres comenzar',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de mensajes
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: preConfiguredMessages.length,
                  itemBuilder: (context, index) {
                    final messageData = preConfiguredMessages[index];
                    final bool isCustom = messageData['message'].isEmpty;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            if (isCustom) {
                              final String? customMessage =
                                  await _showCustomMessageDialog(context, item);
                              if (customMessage != null &&
                                  customMessage.trim().isNotEmpty) {
                                Get.back(result: customMessage);
                              }
                            } else {
                              Get.back(result: messageData['message']);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCustom
                                        ? colorScheme.secondaryContainer
                                        : colorScheme.primaryContainer
                                              .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    messageData['icon'],
                                    color: isCustom
                                        ? colorScheme.onSecondaryContainer
                                        : colorScheme.secondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        messageData['title'],
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (!isCustom) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          messageData['message'],
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme.hintColor,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ] else ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Escribe tu propio mensaje',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme.hintColor,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: theme.hintColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Footer info
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: theme.hintColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El chat expirará automáticamente en 7 días',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showCustomMessageDialog(
    BuildContext context,
    StoreItemModel item,
  ) async {
    final TextEditingController messageController = TextEditingController();

    return await Get.dialog<String>(
      AlertDialog(
        title: const Text('Mensaje personalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escribe tu mensaje para iniciar el intercambio de "${item.name}":',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ej: Hola, me interesa mucho tu producto...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final String message = messageController.text.trim();
              if (message.isNotEmpty) {
                Get.back(result: message);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    DateTime d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color.secondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final String storeId;
  final StoreController storeController;
  final void Function(String storeId, String storeName, String? logoUrl)
  onOpenStore;
  const _StoreCard({
    required this.storeId,
    required this.storeController,
    required this.onOpenStore,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    return FutureBuilder<StoreModel?>(
      future: storeController.fetchStoreById(storeId),
      builder: (context, snapshot) {
        final StoreModel? store = snapshot.data;
        final String storeName = store?.name ?? 'Tienda';
        final String? logoUrl = store?.logoUrl;
        return InkWell(
          onTap: () => onOpenStore(storeId, storeName, logoUrl),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.secondary.withValues(alpha: 0.15),
                backgroundImage: logoUrl != null && logoUrl.isNotEmpty
                    ? NetworkImage(logoUrl)
                    : null,
                child: (logoUrl == null || logoUrl.isEmpty)
                    ? Icon(Icons.store, color: color.secondary)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Ver tienda y productos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: theme.hintColor),
            ],
          ),
        );
      },
    );
  }
}

class _StoreItemsPage extends StatelessWidget {
  final _StoreArguments args;
  const _StoreItemsPage({required this.args});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    final StoreController controller = Get.put(StoreController());
    return Scaffold(
      appBar: AppBar(title: Text(args.storeName)),
      body: StreamBuilder<List<StoreItemModel>>(
        stream: controller.getItemsByStore(args.storeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<StoreItemModel> items =
              snapshot.data ?? <StoreItemModel>[];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Esta tienda aún no tiene productos',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.76,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final StoreItemModel item = items[index];
              return GestureDetector(
                onTap: () =>
                    Get.to(() => const StoreItemDetailPage(), arguments: item),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(item.imageUrl, fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 14,
                                    color: color.primary,
                                  ),
                                  Text(
                                    item.price.toStringAsFixed(0),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: color.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
