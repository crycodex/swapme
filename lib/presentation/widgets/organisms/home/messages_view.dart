import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/chat/chat_controller.dart';
import '../../../../data/models/chat_model.dart';
import '../../../pages/chat/chat_page.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final ChatController chatController = Get.put(ChatController());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface,
            title: Row(
              children: [
                const Text('Mensajes'),
                const SizedBox(width: 8),
                Obx(() {
                  final int unreadCount = chatController.getUnreadChatsCount();
                  if (unreadCount == 0) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Implementar búsqueda de mensajes
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          Obx(() {
            if (chatController.isLoading.value) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (chatController.error.value.isNotEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error cargando mensajes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chatController.error.value,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => chatController.loadUserChats(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final List<ChatModel> chats = chatController.chats;

            if (chats.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 80,
                        color: theme.hintColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes mensajes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuando intercambies artículos o contactes\ncon otras tiendas, verás tus conversaciones aquí',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.tonal(
                        onPressed: () {
                          // Navegar al tab de swaps
                          Get.back();
                          // TODO: Cambiar al tab de swaps
                        },
                        child: const Text('Explorar intercambios'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final ChatModel chat = chats[index];
                return _ChatListItem(
                  chat: chat,
                  onTap: () => _openChat(context, chat),
                );
              }, childCount: chats.length),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, ChatModel chat) {
    Get.to(() => ChatPage(chatId: chat.id), transition: Transition.cupertino);
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const _ChatListItem({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final ChatController chatController = Get.put(ChatController());
    final String? currentUserId = chatController.currentUserId;

    if (currentUserId == null) return const SizedBox.shrink();

    final bool isUnread =
        chat.hasUnreadMessages && (chat.readBy[currentUserId] != true);
    final bool isExpired = chat.isExpired;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: isExpired ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Hero(
              tag: 'chat-image-${chat.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  chat.swapItemImageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            if (isExpired)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.swapItemName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                  color: isExpired ? theme.hintColor : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Expirado',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (chat.lastMessage != null)
              Text(
                chat.lastMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isExpired
                      ? theme.hintColor
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 12, color: theme.hintColor),
                const SizedBox(width: 4),
                Text(
                  _formatChatTime(chat.lastMessageAt ?? chat.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const Spacer(),
                if (!isExpired)
                  Text(
                    _formatTimeRemaining(chat.expiresAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTimeRemainingColor(
                        chat.expiresAt,
                        colorScheme,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  String _formatChatTime(DateTime dateTime) {
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

  String _formatTimeRemaining(DateTime expiresAt) {
    final DateTime now = DateTime.now();
    final Duration remaining = expiresAt.difference(now);

    if (remaining.isNegative) return 'Expirado';

    if (remaining.inDays > 0) {
      return '${remaining.inDays}d restantes';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h restantes';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m restantes';
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
