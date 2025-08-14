import 'package:flutter/material.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

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
            title: const Text('Mensajes'),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Implementar búsqueda de mensajes
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          SliverToBoxAdapter(
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
                      // TODO: Navegar a explorar tiendas o artículos
                    },
                    child: const Text('Explorar tiendas'),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
