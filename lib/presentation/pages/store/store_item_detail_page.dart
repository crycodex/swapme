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
          // AppBar expandible con imagen del producto
          SliverAppBar(
            pinned: true,
            expandedHeight: 400,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white, size: 24),
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
                  // Imagen del artículo con Hero animation
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
                            size: 64,
                            semanticLabel: 'Imagen no disponible',
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradiente para legibilidad
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Información del producto
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del producto
                  Text(
                    item.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Precio destacado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                        Text(
                          item.price.toStringAsFixed(0),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chips de categoría y estado
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildChip(
                        context,
                        label: item.category,
                        icon: Icons.category_rounded,
                        color: colorScheme.secondary,
                      ),
                      _buildChip(
                        context,
                        label: item.condition,
                        icon: Icons.check_circle_rounded,
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Descripción
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Información de la tienda
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
                  const SizedBox(height: 20),

                  // Meta información
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(item.createdAt),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.store_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ID: ${item.id.substring(0, item.id.length > 6 ? 6 : item.id.length)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Semantics(
              button: true,
              label: 'Intercambiar este producto',
              hint: 'Abre el flujo para proponer un intercambio',
              child: Obx(() {
                if (chatController.currentUserId.value == null) {
                  return FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Inicia sesión para intercambiar'),
                  );
                }

                // Verificar si ya existe un chat activo
                final existingChat = chatController.chats.firstWhereOrNull((
                  chat,
                ) {
                  final Map<String, dynamic> chatData = chat.toFirestore();
                  return chatData['storeItemId'] == item.id &&
                      chatData['interestedUserId'] ==
                          chatController.currentUserId.value! &&
                      !chat.isExpired;
                });

                final bool hasActiveChat = existingChat != null;

                return FilledButton(
                  onPressed: () =>
                      _initiateStoreItemSwap(context, item, chatController),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: hasActiveChat
                        ? colorScheme.secondary
                        : colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasActiveChat ? Icons.chat_bubble : Icons.swap_horiz,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasActiveChat ? 'Continuar al chat' : 'Intercambiar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
    if (chatController.currentUserId.value == null) {
      Get.snackbar(
        'Error',
        'Debes iniciar sesión para intercambiar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Verificar si ya existe un chat activo para este producto de tienda
    final String currentUserId = chatController.currentUserId.value!;
    final existingChat = chatController.chats.firstWhereOrNull((chat) {
      // Para store items, verificamos swapItemId (que ahora contiene storeItemId)
      final Map<String, dynamic> chatData = chat.toFirestore();
      return chatData['swapItemId'] == item.id &&
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

    // Mostrar diálogo para iniciar conversación
    final String? selectedMessage = await Get.bottomSheet<String>(
      StartConversationDialog(
        storeItem: item,
        showCustomMessageDialog: (context, item) =>
            _showCustomMessageDialog(context, item),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
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
      final String? chatId = await chatController.createChatForStoreItem(
        storeItem: item,
        interestedUserId: chatController.currentUserId.value!,
      );

      Get.back(); // Cerrar indicador de carga

      if (chatId != null) {
        try {
          // Enviar mensaje inicial
          await chatController.sendMessage(
            chatId: chatId,
            content: selectedMessage,
          );

          // Navegar al chat
          Get.to(
            () => ChatPage(chatId: chatId),
            transition: Transition.cupertino,
          );

          Get.snackbar(
            'Chat iniciado',
            'Tu mensaje ha sido enviado exitosamente',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (messageError) {
          debugPrint('Error enviando mensaje: $messageError');
          // Aún navegar al chat aunque falle el mensaje
          Get.to(
            () => ChatPage(chatId: chatId),
            transition: Transition.cupertino,
          );

          Get.snackbar(
            'Chat iniciado',
            'El chat se creó pero hubo un problema al enviar el mensaje',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        final String errorMessage = chatController.error.value.isNotEmpty
            ? chatController.error.value
            : 'No se pudo crear el chat. Inténtalo de nuevo.';

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Cerrar indicador de carga
      debugPrint('Error inesperado al crear chat: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado al crear el chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Mensaje personalizado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escribe tu mensaje para iniciar el intercambio de "${item.name}":',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ej: Hola, me interesa mucho tu producto...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
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
    required Color color,
  }) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
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
