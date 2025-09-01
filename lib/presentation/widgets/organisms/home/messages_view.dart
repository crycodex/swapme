import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/chat/chat_controller.dart';
import '../../../../data/models/chat_model.dart';
import '../../../pages/chat/chat_page.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final TextEditingController _searchController = TextEditingController();
  final ChatController _chatController = Get.put(ChatController());
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar chats...',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                    onChanged: (query) {
                      _chatController.searchChats(query);
                    },
                  )
                : Row(
                    children: [
                      const Text('Mensajes'),
                      const SizedBox(width: 8),
                      Obx(() {
                        final int unreadCount = _chatController
                            .getUnreadChatsCount();
                        _chatController.getExpiredChatsStats();
                        final int expiringSoonCount = _chatController.chats
                            .where(
                              (chat) =>
                                  !chat.isExpired &&
                                  chat.expiresAt
                                          .difference(DateTime.now())
                                          .inHours <
                                      24,
                            )
                            .length;
                        final int expiredCount = _chatController.chats
                            .where((chat) => chat.isExpired)
                            .length;

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (unreadCount > 0) ...[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: colorScheme.onPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      unreadCount.toString(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (expiringSoonCount > 0) ...[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$expiringSoonCount',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (expiredCount > 0) ...[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.error.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$expiredCount',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
            actions: [
              if (_isSearching) ...[
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _chatController.clearSearch();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ] else ...[
                Obx(
                  () => IconButton(
                    onPressed: _chatController.isLoading.value
                        ? null
                        : () => _chatController.forceCleanupExpiredChats(),
                    icon: _chatController.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cleaning_services_outlined),
                    tooltip: 'Limpiar chats expirados ahora',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ],
          ),
          Obx(() {
            if (_chatController.isLoading.value) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (_chatController.error.value.isNotEmpty) {
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
                        _chatController.error.value,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => _chatController.loadUserChats(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final List<ChatModel> chats = _chatController.displayedChats;

            if (chats.isEmpty) {
              final bool isSearching =
                  _chatController.searchQuery.value.isNotEmpty;

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSearching
                            ? Icons.search_off
                            : Icons.chat_bubble_outline_rounded,
                        size: 80,
                        color: theme.hintColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSearching
                            ? 'No se encontraron resultados'
                            : 'No tienes mensajes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSearching
                            ? 'Intenta con otros términos de búsqueda'
                            : 'Cuando intercambies artículos o contactes\ncon otras tiendas, verás tus conversaciones aquí.\n\nLos chats expiran en 7 días y se eliminan automáticamente.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (isSearching)
                        FilledButton.tonal(
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                              _chatController.clearSearch();
                            });
                          },
                          child: const Text('Limpiar búsqueda'),
                        )
                      else
                        FilledButton.tonal(
                          onPressed: () {
                            // Navegar al tab de swaps
                            Get.back();
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
                  searchQuery: _chatController.searchQuery.value,
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
  final String searchQuery;

  const _ChatListItem({
    required this.chat,
    required this.onTap,
    this.searchQuery = '',
  });

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isUnread
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
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
              child: _buildHighlightedText(
                chat.swapItemName,
                searchQuery,
                theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: isExpired ? theme.hintColor : null,
                    ) ??
                    const TextStyle(),
                colorScheme.primary,
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
              _buildHighlightedText(
                chat.lastMessage!,
                searchQuery,
                theme.textTheme.bodyMedium?.copyWith(
                      color: isExpired
                          ? theme.hintColor
                          : theme.textTheme.bodyMedium?.color,
                      fontWeight: isUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ) ??
                    const TextStyle(),
                colorScheme.primary,
                maxLines: 2,
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Nuevo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
            const SizedBox(height: 4),
            Icon(Icons.chevron_right, color: theme.hintColor, size: 16),
          ],
        ),
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

  Widget _buildHighlightedText(
    String text,
    String searchQuery,
    TextStyle baseStyle,
    Color highlightColor, {
    int? maxLines,
  }) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Agregar texto antes del match
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }

      // Agregar texto resaltado
      spans.add(
        TextSpan(
          text: text.substring(index, index + searchQuery.length),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor.withValues(alpha: 0.3),
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      start = index + searchQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Agregar texto restante
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}
