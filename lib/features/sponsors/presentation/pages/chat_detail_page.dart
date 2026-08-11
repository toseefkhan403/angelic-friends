import 'package:brutalist_ui/brutalist_ui.dart' show NeoIconButton, NeoButtonSize;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/usecases/get_chat_messages.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/usecases/send_chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/bloc/chat_bloc.dart';
import 'package:video_player/video_player.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Per-sponsorship chat thread, reached only from a sponsored dog's card in
/// "My Dogs" — a dog with no active sponsorship never surfaces a way to get
/// here (see docs/PRODUCT_SPEC.md §4.8: chat unlocks with payment).
class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({required this.sponsorship, super.key});

  final Sponsorship sponsorship;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<SponsorshipRepository>();
    return BlocProvider(
      create: (context) => ChatBloc(
        getChatMessages: GetChatMessages(repository),
        sendChatMessage: SendChatMessage(repository),
        sponsorshipRepository: repository,
        sponsorshipId: sponsorship.id,
      )..add(const ChatFetchRequested()),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSent(text));
    _textController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.neutralFill,
                border: Border.fromBorderSide(BorderSide(color: AppColors.ink, width: 2)),
              ),
              child: const Icon(LucideIcons.pawPrint, size: 18, color: AppColors.ink),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sanctuary Team', style: theme.textTheme.titleMedium),
                Text(
                  'Active now',
                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.bodyGray),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Coming soon'))),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) _scrollToBottom();
                },
                builder: (context, state) {
                  return switch (state) {
                    ChatInitial() || ChatLoading() =>
                      const Center(child: CupertinoActivityIndicator()),
                    ChatFailure(:final message) => ErrorStateView(
                        message: message,
                        onRetry: () =>
                            context.read<ChatBloc>().add(const ChatFetchRequested()),
                      ),
                    ChatLoaded(:final messages) =>
                      _MessageList(messages: messages, scrollController: _scrollController),
                  };
                },
              ),
            ),
            _ChatInputBar(controller: _textController, onSend: () => _send(context)),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages, required this.scrollController});

  final List<ChatMessage> messages;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showDivider =
            index == 0 || !_isSameDay(messages[index - 1].createdAt, message.createdAt);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDivider) _DateDivider(date: message.createdAt),
            _MessageBubble(message: message),
          ],
        );
      },
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final label = _isSameDay(date, now)
        ? 'Today'
        : _isSameDay(date, now.subtract(const Duration(days: 1)))
            ? 'Yesterday'
            : '${_months[date.month - 1]} ${date.day}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: const BoxDecoration(
            color: AppColors.neutralFill,
            border: Border.fromBorderSide(BorderSide(color: AppColors.ink, width: 1.5)),
          ),
          child: Text(label, style: theme.textTheme.labelSmall),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.senderType == MessageSenderType.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.mustard : AppColors.neutralFill,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  padding: message.mediaType == MessageMediaType.video
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: message.mediaType == MessageMediaType.video
                      ? _VideoBubbleContent(message: message)
                      : Text(message.text ?? '', style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.checkCheck, size: 12, color: AppColors.bodyGray),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoBubbleContent extends StatelessWidget {
  const _VideoBubbleContent({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: message.mediaUrl == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => _FullScreenVideoPage(videoUrl: message.mediaUrl!)),
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: message.mediaThumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: AppColors.neutralFill),
                ),
                Container(color: Colors.black.withValues(alpha: 0.15)),
                const Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.mustard, shape: BoxShape.circle),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.play, color: AppColors.ink, size: 24),
                    ),
                  ),
                ),
                if (message.mediaDurationLabel != null)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: Colors.black54,
                      child: Text(
                        message.mediaDurationLabel!,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (message.text != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(message.text!, style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _FullScreenVideoPage extends StatefulWidget {
  const _FullScreenVideoPage({required this.videoUrl});

  final String videoUrl;

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _initialized
            ? GestureDetector(
                onTap: () => setState(
                  () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
                ),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),
                      if (!_controller.value.isPlaying)
                        const DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Icon(LucideIcons.play, color: Colors.white, size: 32),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : const CupertinoActivityIndicator(color: Colors.white),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.ground,
        border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Row(
        children: [
          NeoIconButton(
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Coming soon'))),
            semanticLabel: 'Attach',
            size: NeoButtonSize.small,
            icon: const Icon(LucideIcons.plus),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Message Sanctuary Team'),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          NeoIconButton(
            onPressed: onSend,
            semanticLabel: 'Send',
            size: NeoButtonSize.small,
            icon: const Icon(LucideIcons.send),
          ),
        ],
      ),
    );
  }
}
