import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/swap_item_model.dart';
import '../../../controllers/swap/swap_controller.dart';
import '../../../controllers/chat/chat_controller.dart';
import '../../../routes/routes.dart';
import '../chat/chat_page.dart';
import '../../widgets/molecules/start_conversation_dialog.dart';

class SwapDetailPage extends StatelessWidget {
  const SwapDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Verificar que los argumentos no sean null
    final dynamic arguments = Get.arguments;
    if (arguments == null || arguments is! SwapItemModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: No se pudo cargar la información del producto'),
              SizedBox(height: 8),
              Text('Por favor, regresa e intenta de nuevo.'),
            ],
          ),
        ),
      );
    }

    final SwapItemModel item = arguments;
    final SwapController swapController = Get.put(SwapController());
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
              'Detalles',
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
                    tag: 'swap-${item.id}',
                    child: Semantics(
                      label: 'Imagen del artículo ${item.name}',
                      image: true,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 40,
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

                  // Chips de categoría, talla y estado
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
                        label: item.size,
                        icon: Icons.straighten_rounded,
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
                    label:
                        'Precio estimado ${item.estimatedPrice.toStringAsFixed(0)} dólares',
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        Text(
                          item.estimatedPrice.toStringAsFixed(0),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vendedor
                  const SizedBox(height: 8),
                  _SellerCard(
                    userId: item.userId,
                    swapController: swapController,
                    onOpenSeller:
                        (String userId, String userName, String? photo) {
                          Get.toNamed(
                            Routes.sellerProfile,
                            arguments: {
                              'userId': userId,
                              'userName': userName,
                              'photoUrl': photo,
                            },
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
                        Icons.sync_alt_rounded,
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
              label: 'Intercambiar este artículo',
              hint: 'Abre el flujo para proponer un intercambio',
              child: Obx(() {
                if (chatController.currentUserId.value == item.userId) {
                  return FilledButton(
                    onPressed: null,
                    child: const Text('Tu artículo'),
                  );
                }

                if (chatController.currentUserId.value == null) {
                  return FilledButton(
                    onPressed: null,
                    child: const Text('Intercambiar'),
                  );
                }

                // Verificar si ya existe un chat activo
                final existingChat = chatController.chats.firstWhereOrNull(
                  (chat) =>
                      chat.swapItemId == item.id &&
                      chat.interestedUserId ==
                          chatController.currentUserId.value! &&
                      chat.swapItemOwnerId == item.userId &&
                      !chat.isExpired,
                );

                final bool hasActiveChat = existingChat != null;

                return FilledButton(
                  onPressed: () => _initiateSwap(context, item, chatController),
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

  Future<void> _initiateSwap(
    BuildContext context,
    SwapItemModel item,
    ChatController chatController,
  ) async {
    if (chatController.currentUserId.value == null) {
      Get.snackbar(
        'Error',
        'Debes iniciar sesión para intercambiar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Verificar si ya existe un chat activo para este artículo
    final String? currentUserId = chatController.currentUserId.value;
    final existingChat = chatController.chats.firstWhereOrNull(
      (chat) =>
          chat.swapItemId == item.id &&
          chat.interestedUserId == currentUserId &&
          chat.swapItemOwnerId == item.userId &&
          !chat.isExpired,
    );

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
        swapItem: item,
        showCustomMessageDialog: (context, item) =>
            _showCustomMessageDialog(context, item),
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
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
      final String? chatId = await chatController.createChat(
        swapItem: item,
        interestedUserId: chatController.currentUserId.value!,
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
    SwapItemModel item,
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
                hintText: 'Ej: Hola, me interesa mucho tu artículo...',
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

class _SellerCard extends StatelessWidget {
  final String userId;
  final SwapController swapController;
  final void Function(String userId, String userName, String? photoUrl)
  onOpenSeller;
  const _SellerCard({
    required this.userId,
    required this.swapController,
    required this.onOpenSeller,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    return FutureBuilder<Map<String, dynamic>?>(
      future: swapController.fetchUserProfile(userId),
      builder: (context, snapshot) {
        final Map<String, dynamic>? data = snapshot.data;
        final String userName = (data?['name'] ?? 'usuario') as String;
        final String? photoUrl = data?['photoUrl'] as String?;
        return InkWell(
          onTap: () => onOpenSeller(userId, userName, photoUrl),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.secondary.withValues(alpha: 0.15),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Icon(Icons.person, color: color.secondary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        // Stars rating
                        _buildStarRating(
                          4.5,
                          14,
                        ), // TODO: Obtener rating real del usuario
                        const SizedBox(width: 4),
                        Text(
                          '4.5', // TODO: Mostrar rating real
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• Ver perfil',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.hintColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStarRating(double rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating.ceil() && rating % 1 != 0)
              ? Icons.star_half
              : Icons.star_border,
          size: size,
          color: Colors.amber[600],
        );
      }),
    );
  }
}
