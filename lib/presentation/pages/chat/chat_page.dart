import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/chat/chat_controller.dart';
import '../../../controllers/swap/swap_history_controller.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/swap_history_model.dart';
import '../../../data/models/swap_item_model.dart';
import '../../widgets/molecules/product_selector.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ChatController _chatController = Get.put(ChatController());

  ChatModel? _currentChat;
  bool _isAppInForeground = true;
  bool _isRatingDialogShown = false;

  @override
  void initState() {
    super.initState();
    // Agregar observer para el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Notificar al controlador que este chat está visible
    _chatController.setCurrentVisibleChat(widget.chatId);
    _chatController.setAppForegroundState(_isAppInForeground);

    _loadChatInfo();
    _markChatAsRead();
    _setupNotificationHandling();

    // Marcar como leído cada vez que se recibe un nuevo mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAutoMarkAsRead();
      _setupChatStatusListener();
    });
  }

  @override
  void dispose() {
    // Remover observer del ciclo de vida de la app
    WidgetsBinding.instance.removeObserver(this);

    // Notificar al controlador que ya no hay chat visible
    _chatController.setCurrentVisibleChat(null);

    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        _chatController.setAppForegroundState(true);
        // Marcar chat como leído cuando regrese a la app
        _markChatAsRead();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isAppInForeground = false;
        _chatController.setAppForegroundState(false);
        break;
    }
  }

  Future<void> _loadChatInfo() async {
    final ChatModel? chat = _chatController.chats.firstWhereOrNull(
      (chat) => chat.id == widget.chatId,
    );
    if (chat != null) {
      final bool wasCompleted = _currentChat?.status == ChatStatus.completed;

      setState(() {
        _currentChat = chat;
      });

      // Si el intercambio se acaba de completar y el usuario es el interesado,
      // mostrar automáticamente el diálogo de calificación
      if (!wasCompleted &&
          chat.status == ChatStatus.completed &&
          chat.interestedUserId == _chatController.currentUserId &&
          !_isRatingDialogShown) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isRatingDialogShown) {
            _showRatingDialog();
          }
        });
      }
    }
  }

  Future<void> _markChatAsRead() async {
    await _chatController.markChatAsRead(widget.chatId);
  }

  void _setupNotificationHandling() {
    // Configurar el manejo de notificaciones específicas para este chat
    // Cuando llegue una notificación de este chat y estemos en la página,
    // marcarla automáticamente como leída

    // Este método podría expandirse para manejar notificaciones específicas
    // cuando se implementen handlers de notificación más avanzados
    debugPrint(
      'Configurando manejo de notificaciones para chat: ${widget.chatId}',
    );
  }

  void _setupAutoMarkAsRead() {
    // Marcar como leído cuando hay nuevos mensajes y la app está activa
    _chatController.getChatMessages(widget.chatId).listen((messages) {
      if (mounted && _isAppInForeground) {
        // Solo marcar como leído si la app está en primer plano
        // Pequeño delay para asegurar que la UI se ha actualizado
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _isAppInForeground) {
            _markChatAsRead();
          }
        });
      }
    });
  }

  void _setupChatStatusListener() {
    // Escuchar cambios en el estado del chat
    _chatController.chats.listen((chats) {
      if (mounted) {
        final ChatModel? updatedChat = chats.firstWhereOrNull(
          (chat) => chat.id == widget.chatId,
        );

        if (updatedChat != null) {
          final bool wasCompleted =
              _currentChat?.status == ChatStatus.completed;
          final bool isNowCompleted =
              updatedChat.status == ChatStatus.completed;
          final String currentUserId = _chatController.currentUserId!;

          // Si el intercambio se acaba de completar y es el usuario interesado
          if (!wasCompleted &&
              isNowCompleted &&
              updatedChat.interestedUserId == currentUserId &&
              !_isRatingDialogShown) {
            setState(() {
              _currentChat = updatedChat;
            });

            // Mostrar diálogo de calificación automáticamente para el usuario interesado
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted && !_isRatingDialogShown) {
                _showRatingDialog();
              }
            });
          } else {
            setState(() {
              _currentChat = updatedChat;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: _currentChat != null
            ? Row(
                children: [
                  Hero(
                    tag: 'chat-image-${widget.chatId}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        _currentChat!.swapItemImageUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 32,
                          height: 32,
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentChat!.swapItemName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!_currentChat!.isExpired)
                          Text(
                            _formatTimeRemaining(_currentChat!.expiresAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getTimeRemainingColor(
                                _currentChat!.expiresAt,
                                colorScheme,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            : const Text('Chat'),
        actions: [
          if (_currentChat != null)
            PopupMenuButton<String>(
              onSelected: (String value) {
                switch (value) {
                  case 'delete':
                    _showDeleteChatDialog();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar chat',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (_currentChat?.isExpired == true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.access_time, color: colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este chat ha expirado. Ya no puedes enviar mensajes.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatController.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<MessageModel> messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Inicia la conversación',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final MessageModel message = messages[index];
                    return _MessageBubble(
                      message: message,
                      isCurrentUser:
                          message.senderId == _chatController.currentUserId,
                      onSwapResponse: (bool accepted) {
                        _respondToSwap(accepted, message);
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_currentChat?.isExpired != true)
            Column(
              children: [
                // Botones de acción rápida
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildActionButton(),
                ),
                _ProductSelectorInput(
                  onProductSelected: _sendProductProposal,
                  onMoneySelected: _sendMoneyProposal,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_currentChat == null) {
      return const SizedBox.shrink();
    }

    final String currentUserId = _chatController.currentUserId!;
    final bool isOwner = _currentChat!.swapItemOwnerId == currentUserId;
    final bool isCompleted = _currentChat!.status == ChatStatus.completed;

    if (isCompleted) {
      // Si el intercambio ya está completado, mostrar botón de calificar
      return FutureBuilder<bool>(
        future: _checkIfUserHasRated(),
        builder: (context, snapshot) {
          final bool hasRated = snapshot.data ?? false;

          if (hasRated) {
            return OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.star, size: 18),
              label: const Text('Ya calificado'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            );
          } else {
            return FilledButton.icon(
              onPressed: () => _showRatingDialog(),
              icon: const Icon(Icons.star, size: 18),
              label: const Text('Calificar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
              ),
            );
          }
        },
      );
    } else if (isOwner) {
      // Si es el dueño del artículo, mostrar botón de confirmar
      return FilledButton.icon(
        onPressed: _showConfirmSwapDialog,
        icon: const Icon(Icons.check_circle, size: 18),
        label: const Text('Confirmar'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      );
    } else {
      // Si es el usuario interesado, mostrar mensaje informativo
      return OutlinedButton.icon(
        onPressed: null, // Deshabilitado
        icon: const Icon(Icons.hourglass_empty, size: 18),
        label: const Text('Esperando confirmación'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      );
    }
  }

  Future<bool> _checkIfUserHasRated() async {
    if (_currentChat == null || _chatController.currentUserId == null) {
      return false;
    }

    try {
      SwapHistoryController historyController;
      try {
        historyController = Get.put(SwapHistoryController());
      } catch (e) {
        historyController = Get.put(SwapHistoryController());
      }

      // Buscar el historial de este chat
      await historyController.loadUserSwapHistory();
      final swapHistory = historyController.swapHistory
          .where((swap) => swap.chatId == widget.chatId)
          .firstOrNull;

      if (swapHistory != null) {
        final String otherUserId = _currentChat!.getOtherUserId(
          _chatController.currentUserId!,
        );
        return await historyController.hasUserRated(
          swapHistory.id,
          otherUserId,
        );
      }

      return false;
    } catch (e) {
      debugPrint('Error verificando si el usuario ya calificó: $e');
      return false;
    }
  }

  Future<void> _sendProductProposal(SwapItemModel product) async {
    final bool success = await _chatController.sendMessage(
      chatId: widget.chatId,
      content: 'Te propongo intercambiar mi "${product.name}" por tu artículo.',
      type: MessageType.productProposal,
      metadata: {
        'productId': product.id,
        'productName': product.name,
        'productImageUrl': product.imageUrl,
        'productPrice': product.estimatedPrice,
        'productSize': product.size,
        'productCondition': product.condition,
        'productDescription': product.description,
      },
    );

    if (success) {
      _scrollToBottom();
      Get.snackbar(
        'Propuesta enviada',
        'Tu propuesta de intercambio ha sido enviada',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'No se pudo enviar la propuesta',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _sendMoneyProposal(double amount) async {
    final bool success = await _chatController.sendMessage(
      chatId: widget.chatId,
      content: 'Te ofrezco \$${amount.toStringAsFixed(0)} por tu artículo.',
      type: MessageType.moneyProposal,
      metadata: {'amount': amount, 'currency': 'USD'},
    );

    if (success) {
      _scrollToBottom();
      Get.snackbar(
        'Propuesta enviada',
        'Tu oferta de dinero ha sido enviada',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'No se pudo enviar la propuesta',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showDeleteChatDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Eliminar chat'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que quieres eliminar este chat?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer. Se eliminarán todos los mensajes.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
            onPressed: () async {
              Get.back(); // Cerrar diálogo

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
                          Text('Eliminando chat...'),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                await _chatController.deleteChat(widget.chatId);
                Get.back(); // Cerrar indicador de carga
                Get.back(); // Volver a la lista de chats

                Get.snackbar(
                  'Chat eliminado',
                  'El chat se ha eliminado correctamente',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: colorScheme.inverseSurface,
                  colorText: colorScheme.onInverseSurface,
                );
              } catch (e) {
                Get.back(); // Cerrar indicador de carga
                Get.snackbar(
                  'Error',
                  'No se pudo eliminar el chat. Inténtalo de nuevo.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: colorScheme.errorContainer,
                  colorText: colorScheme.onErrorContainer,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmSwapDialog() {
    final TextEditingController notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Confirmar intercambio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de que quieres confirmar este intercambio?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Al confirmar, el artículo se marcará como no disponible y se moverá al historial.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Notas adicionales (opcional):'),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ej: Intercambio realizado en el centro comercial...',
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
            onPressed: () async {
              Get.back(); // Cerrar diálogo

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
                          Text('Confirmando intercambio...'),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                final bool success = await _chatController.confirmSwap(
                  chatId: widget.chatId,
                  notes: notesController.text.trim().isNotEmpty
                      ? notesController.text.trim()
                      : null,
                );

                Get.back(); // Cerrar indicador de carga

                if (success) {
                  _scrollToBottom();

                  Get.snackbar(
                    'Intercambio confirmado',
                    'El intercambio se ha registrado exitosamente. Ahora puedes calificar al otro usuario.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 4),
                  );

                  // Recargar la información del chat para actualizar el estado
                  _loadChatInfo();
                } else {
                  final String errorMessage =
                      _chatController.error.value.isNotEmpty
                      ? _chatController.error.value
                      : 'No se pudo confirmar el intercambio. Inténtalo de nuevo.';

                  Get.snackbar(
                    'Error',
                    errorMessage,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 4),
                  );
                }
              } catch (e) {
                Get.back(); // Cerrar indicador de carga
                Get.snackbar(
                  'Error',
                  'Ocurrió un error inesperado. Inténtalo de nuevo.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar intercambio'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() async {
    if (_currentChat == null || _isRatingDialogShown) return;

    // Verificar si el usuario ya ha calificado
    final bool hasRated = await _checkIfUserHasRated();
    if (hasRated) {
      Get.snackbar(
        'Ya calificado',
        'Ya has calificado a este usuario para este intercambio',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    _isRatingDialogShown = true;

    final String otherUserId = _currentChat!.getOtherUserId(
      _chatController.currentUserId!,
    );
    final String otherUserName =
        _currentChat!.swapItemOwnerId == _chatController.currentUserId!
        ? 'el usuario interesado'
        : 'el propietario';

    int selectedRating = 5;
    final TextEditingController commentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Text(
                'Calificar intercambio',
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Cómo fue tu experiencia con $otherUserName?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Calificación con estrellas
            Center(
              child: Column(
                children: [
                  const Text(
                    'Calificación:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 40,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$selectedRating estrella${selectedRating != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Campo de comentario
            const Text(
              'Comentario (opcional):',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Comparte tu experiencia...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.amber, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isRatingDialogShown = false;
              Get.back();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Omitir', style: TextStyle(fontSize: 16)),
          ),
          FilledButton(
            onPressed: () async {
              _isRatingDialogShown = false;
              Get.back();

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
                          Text('Enviando calificación...'),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                // Obtener el historial más reciente para este chat
                SwapHistoryController historyController;
                try {
                  historyController = Get.put(SwapHistoryController());
                } catch (e) {
                  historyController = Get.put(SwapHistoryController());
                }

                // Buscar primero en el historial ya cargado
                SwapHistoryModel? swapHistory = historyController.swapHistory
                    .where((swap) => swap.chatId == widget.chatId)
                    .firstOrNull;

                // Si no se encuentra, cargar el historial
                if (swapHistory == null) {
                  await historyController.loadUserSwapHistory();
                  swapHistory = historyController.swapHistory
                      .where((swap) => swap.chatId == widget.chatId)
                      .firstOrNull;
                }

                if (swapHistory != null) {
                  final bool success = await historyController.rateUser(
                    swapHistoryId: swapHistory.id,
                    ratedUserId: otherUserId,
                    rating: selectedRating,
                    comment: commentController.text.trim().isNotEmpty
                        ? commentController.text.trim()
                        : null,
                  );

                  Get.back(); // Cerrar indicador de carga

                  if (success) {
                    Get.snackbar(
                      'Calificación enviada',
                      'Gracias por tu retroalimentación',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'No se pudo enviar la calificación',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } else {
                  Get.back(); // Cerrar indicador de carga
                  Get.snackbar(
                    'Error',
                    'No se encontró el historial del intercambio',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.back(); // Cerrar indicador de carga
                Get.snackbar(
                  'Error',
                  'Ocurrió un error inesperado: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enviar calificación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _respondToSwap(
    bool accepted,
    MessageModel proposalMessage,
  ) async {
    await _chatController.respondToSwap(
      chatId: widget.chatId,
      accepted: accepted,
    );
    _scrollToBottom();
  }

  String _formatTimeRemaining(DateTime expiresAt) {
    final DateTime now = DateTime.now();
    final Duration remaining = expiresAt.difference(now);

    if (remaining.isNegative) return 'Expirado';

    if (remaining.inDays > 0) {
      return 'Expira en ${remaining.inDays}d';
    } else if (remaining.inHours > 0) {
      return 'Expira en ${remaining.inHours}h';
    } else if (remaining.inMinutes > 0) {
      return 'Expira en ${remaining.inMinutes}m';
    } else {
      return 'Expira pronto';
    }
  }

  Color _getTimeRemainingColor(DateTime expiresAt, ColorScheme colorScheme) {
    final DateTime now = DateTime.now();
    final Duration remaining = expiresAt.difference(now);

    if (remaining.isNegative) return colorScheme.error;
    if (remaining.inHours < 24) return colorScheme.error;
    if (remaining.inDays < 3) return Colors.orange;
    return colorScheme.secondary;
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final Function(bool)? onSwapResponse;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    this.onSwapResponse,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && message.type != MessageType.system) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.15),
              backgroundImage:
                  message.senderPhotoUrl != null &&
                      message.senderPhotoUrl!.isNotEmpty
                  ? NetworkImage(message.senderPhotoUrl!)
                  : null,
              child:
                  (message.senderPhotoUrl == null ||
                      message.senderPhotoUrl!.isEmpty)
                  ? Icon(Icons.person, size: 18, color: colorScheme.secondary)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser && message.type != MessageType.system)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                _buildMessageContent(context, theme, colorScheme),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
              backgroundImage:
                  message.senderPhotoUrl != null &&
                      message.senderPhotoUrl!.isNotEmpty
                  ? NetworkImage(message.senderPhotoUrl!)
                  : null,
              child:
                  (message.senderPhotoUrl == null ||
                      message.senderPhotoUrl!.isEmpty)
                  ? Icon(Icons.person, size: 18, color: colorScheme.primary)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    switch (message.type) {
      case MessageType.system:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );

      case MessageType.swapProposal:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser
                  ? colorScheme.primary
                  : colorScheme.secondary,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: isCurrentUser
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Propuesta de intercambio',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isCurrentUser
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCurrentUser
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                ),
              ),
              if (!isCurrentUser && onSwapResponse != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => onSwapResponse!(false),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rechazar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          backgroundColor: colorScheme.error,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => onSwapResponse!(true),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );

      case MessageType.swapAccepted:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case MessageType.swapRejected:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.error, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.cancel, color: colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case MessageType.agreement:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.handshake, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Acuerdo creado',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        );

      case MessageType.productProposal:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser
                  ? colorScheme.primary
                  : colorScheme.secondary,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: isCurrentUser
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Propuesta de producto',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isCurrentUser
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Product info
              if (message.metadata != null) ...[
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.metadata!['productImageUrl'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.metadata!['productName'] ?? '',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isCurrentUser
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '\$${(message.metadata!['productPrice'] ?? 0.0).toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isCurrentUser
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                message.metadata!['productSize'] ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isCurrentUser
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                message.metadata!['productCondition'] ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isCurrentUser
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCurrentUser
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                ),
              ),
              if (!isCurrentUser && onSwapResponse != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onSwapResponse!(false),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rechazar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => onSwapResponse!(true),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );

      case MessageType.moneyProposal:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser
                  ? colorScheme.primary
                  : colorScheme.secondary,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: isCurrentUser
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Propuesta de dinero',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isCurrentUser
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Money amount display
              if (message.metadata != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        (isCurrentUser
                                ? colorScheme.primary
                                : colorScheme.secondary)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: isCurrentUser
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        size: 32,
                      ),
                      Text(
                        '${(message.metadata!['amount'] ?? 0.0).toStringAsFixed(0)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: isCurrentUser
                              ? colorScheme.primary
                              : colorScheme.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCurrentUser
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                ),
              ),
              if (!isCurrentUser && onSwapResponse != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onSwapResponse!(false),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rechazar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => onSwapResponse!(true),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isCurrentUser
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
            ),
          ),
        );
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}

class _ProductSelectorInput extends StatelessWidget {
  final Function(SwapItemModel) onProductSelected;
  final Function(double) onMoneySelected;

  const _ProductSelectorInput({
    required this.onProductSelected,
    required this.onMoneySelected,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => _showProductSelector(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hacer una propuesta...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_up,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return ProductSelector(
              onProductSelected: (SwapItemModel product) {
                Navigator.of(context).pop();
                onProductSelected(product);
              },
              onMoneySelected: (double amount) {
                Navigator.of(context).pop();
                onMoneySelected(amount);
              },
              onClosePressed: () => Navigator.of(context).pop(),
            );
          },
        );
      },
    );
  }
}
