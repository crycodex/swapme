import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/chat/chat_controller.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/message_model.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatController _chatController = Get.put(ChatController());

  ChatModel? _currentChat;

  @override
  void initState() {
    super.initState();
    _loadChatInfo();
    _markChatAsRead();

    // Marcar como leído cada vez que se recibe un nuevo mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAutoMarkAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatInfo() async {
    final ChatModel? chat = _chatController.chats.firstWhereOrNull(
      (chat) => chat.id == widget.chatId,
    );
    if (chat != null) {
      setState(() {
        _currentChat = chat;
      });
    }
  }

  Future<void> _markChatAsRead() async {
    await _chatController.markChatAsRead(widget.chatId);
  }

  void _setupAutoMarkAsRead() {
    // Marcar como leído cuando hay nuevos mensajes y la app está activa
    _chatController.getChatMessages(widget.chatId).listen((messages) {
      if (mounted) {
        // Pequeño delay para asegurar que la UI se ha actualizado
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _markChatAsRead();
          }
        });
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
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showSwapProposalDialog,
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: const Text('Proponer'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showAgreementDialog,
                          icon: const Icon(Icons.handshake, size: 18),
                          label: const Text('Acuerdo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _MessageInput(
                  controller: _messageController,
                  onSend: _sendMessage,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final String content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final bool success = await _chatController.sendMessage(
      chatId: widget.chatId,
      content: content,
    );

    if (success) {
      _scrollToBottom();
    } else {
      Get.snackbar(
        'Error',
        'No se pudo enviar el mensaje',
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

  void _showSwapProposalDialog() {
    final TextEditingController proposalController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Proponer intercambio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe tu propuesta de intercambio:'),
            const SizedBox(height: 16),
            TextField(
              controller: proposalController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Ej: Te ofrezco mi chaqueta de cuero por tu suéter...',
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
              final String proposal = proposalController.text.trim();
              if (proposal.isNotEmpty) {
                await _chatController.proposeSwap(
                  chatId: widget.chatId,
                  proposalMessage: proposal,
                );
                Get.back();
                _scrollToBottom();
              }
            },
            child: const Text('Enviar propuesta'),
          ),
        ],
      ),
    );
  }

  void _showAgreementDialog() {
    final TextEditingController agreementController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Crear acuerdo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Define los términos del acuerdo:'),
            const SizedBox(height: 16),
            TextField(
              controller: agreementController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Ej: Intercambiamos en el centro comercial el sábado a las 3pm...',
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
              final String agreement = agreementController.text.trim();
              if (agreement.isNotEmpty) {
                await _chatController.createAgreement(
                  chatId: widget.chatId,
                  agreementDetails: agreement,
                );
                Get.back();
                _scrollToBottom();
              }
            },
            child: const Text('Crear acuerdo'),
          ),
        ],
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

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
