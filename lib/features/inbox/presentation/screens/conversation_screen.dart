import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../application/inbox_providers.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../utils/inbox_time_formatter.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/platform_indicator.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(inboxControllerProvider.notifier)
            .markConversationRead(widget.conversationId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(inboxControllerProvider);
    Conversation? conversation;
    for (final item in inbox.conversations) {
      if (item.id == widget.conversationId) {
        conversation = item;
        break;
      }
    }

    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back to inbox',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: const Center(child: Text('Conversation not found')),
      );
    }

    final messages = inbox.messagesFor(conversation.id);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ConversationHeader(conversation: conversation, onBack: _goBack),
            const Divider(height: 1),
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text('No messages yet. Say hello!'))
                  : ListView.builder(
                      key: const Key('conversation-messages'),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) =>
                          _MessageBubble(message: messages[index]),
                    ),
            ),
            _MessageComposer(
              controller: _messageController,
              onSend: () => _send(conversation!.id),
            ),
          ],
        ),
      ),
    );
  }

  void _send(String conversationId) {
    final sent = ref
        .read(inboxControllerProvider.notifier)
        .sendMessage(
          conversationId: conversationId,
          content: _messageController.text,
        );
    if (sent) _messageController.clear();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/inbox');
    }
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.conversation, required this.onBack});

  final Conversation conversation;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 7, 16, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to inbox',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          ContactAvatar(contact: conversation.contact, radius: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                PlatformIndicator(platform: conversation.platform),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final sentByMe = message.isSentByMe;
    final bubbleColor = sentByMe
        ? AppColors.primary
        : AppColors.secondarySurface;

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          key: ValueKey('message-${message.id}'),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(sentByMe ? 18 : 5),
              bottomRight: Radius.circular(sentByMe ? 5 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(message.content),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMessageTime(message.timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: sentByMe
                          ? Colors.white70
                          : AppColors.secondaryText,
                    ),
                  ),
                  if (sentByMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.messageStatus == MessageStatus.read
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const Key('message-composer-field'),
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Write a message…',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              key: const Key('send-message-button'),
              tooltip: 'Send message',
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
