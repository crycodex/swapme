import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/store_item_model.dart';
import '../../../data/models/store_model.dart';
import '../../../controllers/store/store_controller.dart';
import '../../../controllers/chat/chat_controller.dart';
import '../chat/chat_page.dart';
import '../../widgets/molecules/start_conversation_dialog.dart';

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
              child: Obx(() {
                if (chatController.currentUserId == null) {
                  return FilledButton(
                    onPressed: null,
                    child: const Text('Intercambiar'),
                  );
                }

                // Verificar si ya existe un chat activo
                final existingChat = chatController.chats.firstWhereOrNull((
                  chat,
                ) {
                  final Map<String, dynamic> chatData = chat.toFirestore();
                  return chatData['storeItemId'] == item.id &&
                      chatData['interestedUserId'] ==
                          chatController.currentUserId! &&
                      !chat.isExpired;
                });

                final bool hasActiveChat = existingChat != null;

                return FilledButton(
                  onPressed: () =>
                      _initiateStoreItemSwap(context, item, chatController),
                  child: Text(
                    hasActiveChat ? 'Continuar al chat' : 'Intercambiar',
                  ),
                );
              }),
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

    // Verificar si ya existe un chat activo para este producto de tienda
    final String currentUserId = chatController.currentUserId!;
    final existingChat = chatController.chats.firstWhereOrNull((chat) {
      // Para store items, verificamos storeItemId y storeOwnerId
      final Map<String, dynamic> chatData = chat.toFirestore();
      return chatData['storeItemId'] == item.id &&
          chatData['interestedUserId'] == currentUserId &&
          !chat.isExpired;
    });

    if (existingChat != null) {
      // Ya existe un chat, ir directamente al chat
      Get.to(
        () => ChatPage(chatId: existingChat.id),
        transition: Transition.cupertino,
      );
      return;
    }

    final String? selectedMessage = await Get.bottomSheet<String>(
      StartConversationDialog(
        storeItem: item,
        showCustomMessageDialog: (context, item) =>
            _showCustomMessageDialog(context, item),
      ),
      isScrollControlled:
          true, // Permite que el bottom sheet ocupe la altura necesaria
      shape: RoundedRectangleBorder(
        // Redondea las esquinas superiores del bottom sheet
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip
          .antiAlias, // Asegura que el contenido se recorte según el borde redondeado
    );

    if (selectedMessage == null) return;

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
      final String? chatId = await chatController.createChatForStoreItem(
        storeItem: item,
        interestedUserId: chatController.currentUserId!,
      );

      Get.back();

      if (chatId != null) {
        await chatController.sendMessage(
          chatId: chatId,
          content: selectedMessage,
        );

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
      Get.back();
      Get.snackbar(
        'Error',
        'Ocurrió un error al crear el chat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
