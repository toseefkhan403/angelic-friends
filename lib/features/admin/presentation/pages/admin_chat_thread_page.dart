import 'package:brutalist_ui/brutalist_ui.dart' show NeoIconButton, NeoButtonSize;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/features/admin/domain/entities/admin_sponsorship_overview.dart';
import 'package:sponsor_a_dog/features/admin/domain/repositories/admin_repository.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:video_player/video_player.dart';

/// One sponsor's thread, from the admin's side. Low-volume solo-admin
/// tooling, not a live support desk — messages are fetched once and new
/// replies are appended optimistically, no realtime stream, no bloc.
class AdminChatThreadPage extends StatefulWidget {
  const AdminChatThreadPage({required this.overview, super.key});

  final AdminSponsorshipOverview overview;

  @override
  State<AdminChatThreadPage> createState() => _AdminChatThreadPageState();
}

class _AdminChatThreadPageState extends State<AdminChatThreadPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  late Future<Either<Failure, List<ChatMessage>>> _future;
  List<ChatMessage>? _messages;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _future.then((result) {
      if (!mounted) return;
      result.fold((_) {}, (messages) => setState(() => _messages = messages));
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<Either<Failure, List<ChatMessage>>> _load() =>
      context.read<AdminRepository>().getMessages(widget.overview.sponsorshipId);

  void _retry() => setState(() {
        _messages = null;
        _future = _load();
      });

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

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);
    final result = await context.read<AdminRepository>().sendHandlerReply(
          sponsorshipId: widget.overview.sponsorshipId,
          text: text,
        );

    if (!mounted) return;
    result.fold(
      (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (message) {
        _textController.clear();
        setState(() => _messages = [...?_messages, message]);
        _scrollToBottom();
      },
    );
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.overview.angelName, style: theme.textTheme.titleMedium),
            Text(
              widget.overview.dogName,
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.bodyGray),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  final messages = _messages;
                  if (messages == null) {
                    return FutureBuilder<Either<Failure, List<ChatMessage>>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CupertinoActivityIndicator());
                        }
                        return snapshot.data!.fold(
                          (failure) => ErrorStateView(message: failure.message, onRetry: _retry),
                          (_) => const Center(child: CupertinoActivityIndicator()),
                        );
                      },
                    );
                  }
                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => _AdminMessageBubble(message: messages[index]),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ground,
                border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Reply as the handler'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  NeoIconButton(
                    onPressed: _isSending ? null : _send,
                    semanticLabel: 'Send',
                    size: NeoButtonSize.small,
                    icon: const Icon(LucideIcons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMessageBubble extends StatelessWidget {
  const _AdminMessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Inverted from the sponsor-facing chat: the admin's own replies are the
    // 'handler' messages, so those are "mine" here.
    final isMine = message.senderType == MessageSenderType.handler;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: isMine ? AppColors.mustard : AppColors.neutralFill,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              padding: message.mediaType == MessageMediaType.video
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: message.mediaType == MessageMediaType.video
                  ? _VideoBubbleContent(message: message)
                  : Text(message.text ?? '', style: theme.textTheme.bodyMedium),
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
                if (message.mediaThumbnailUrl != null)
                  CachedNetworkImage(imageUrl: message.mediaThumbnailUrl!, fit: BoxFit.cover)
                else
                  Container(color: AppColors.neutralFill),
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
