import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/chat_provider.dart';
import '../../../core/models/chat_models.dart';
import '../../../constants/colors.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.currentUser == null && !provider.isLoading) {
            return _buildNotLoggedIn();
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<Conversation>>(
            stream: provider.conversationsStream(),
            builder: (context, snapshot) {
              final conversations = snapshot.data ?? provider.conversations;

              if (conversations.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => provider.loadConversations(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 80,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, index) {
                    return _buildConversationTile(
                      conversations[index],
                      provider.currentUser!.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation, String currentUserId) {
    final isMe = conversation.lastMessage != null;
    final timeStr = _formatTime(conversation.lastMessageAt);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: conversation.propertyImage != null
            ? Image.network(
                conversation.propertyImage!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImageFallback(),
              )
            : _buildImageFallback(),
      ),
      title: Text(
        conversation.propertyTitle,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          conversation.lastMessage ?? 'No messages yet',
          style: TextStyle(
            fontSize: 13,
            color: isMe ? AppColors.textSecondary : AppColors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Text(
        timeStr,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.grey,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversation: conversation,
              currentUserId: currentUserId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Icon(Iconsax.home, color: AppColors.primary, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.message,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you message a property owner,\nit will appear here.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.message, size: 48, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text(
            'Login to see your chats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return '${time.day}/${time.month}/${time.year.toString().substring(2)}';
  }
}