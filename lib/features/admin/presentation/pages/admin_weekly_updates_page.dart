import 'dart:io';

import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton;
import 'package:dartz/dartz.dart' show Either, Left;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compress/flutter_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/features/admin/domain/entities/admin_dog_update_status.dart';
import 'package:sponsor_a_dog/features/admin/domain/repositories/admin_repository.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Which dogs are due for their weekly video update, never-sent-first — and
/// the flow for picking a video and broadcasting it to that dog's eligible
/// sponsors.
class AdminWeeklyUpdatesPage extends StatefulWidget {
  const AdminWeeklyUpdatesPage({super.key});

  @override
  State<AdminWeeklyUpdatesPage> createState() => _AdminWeeklyUpdatesPageState();
}

class _AdminWeeklyUpdatesPageState extends State<AdminWeeklyUpdatesPage> {
  late Future<Either<Failure, List<AdminDogUpdateStatus>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Either<Failure, List<AdminDogUpdateStatus>>> _load() =>
      context.read<AdminRepository>().getDogUpdateStatuses();

  void _retry() => setState(() => _future = _load());

  Future<void> _openComposer(AdminDogUpdateStatus status) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WeeklyUpdateComposerSheet(status: status),
    );
    if (sent == true) _retry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Updates')),
      body: FutureBuilder<Either<Failure, List<AdminDogUpdateStatus>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return snapshot.data!.fold(
            (failure) => ErrorStateView(message: failure.message, onRetry: _retry),
            (statuses) => statuses.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: statuses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _DogUpdateTile(
                      status: statuses[index],
                      onTap: () => _openComposer(statuses[index]),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.video, size: 48, color: AppColors.bodyGray),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No dogs yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogUpdateTile extends StatelessWidget {
  const _DogUpdateTile({required this.status, required this.onTap});

  final AdminDogUpdateStatus status;
  final VoidCallback onTap;

  String get _lastSentLabel {
    final d = status.lastWeeklyUpdateSentAt;
    if (d == null) return 'Never sent';
    return 'Last sent ${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final neverSent = status.lastWeeklyUpdateSentAt == null;

    return GestureDetector(
      onTap: onTap,
      child: NeoBox(
        padding: const EdgeInsets.all(AppSpacing.md),
        shadowOffset: Offset.zero,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status.dogName, style: theme.textTheme.titleSmall),
                  Text(
                    '${status.eligibleSponsorCount} eligible sponsor'
                    '${status.eligibleSponsorCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                  ),
                  Text(
                    _lastSentLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: neverSent ? AppColors.ink : AppColors.bodyGray,
                      fontWeight: neverSent ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.bodyGray),
          ],
        ),
      ),
    );
  }
}

class _WeeklyUpdateComposerSheet extends StatefulWidget {
  const _WeeklyUpdateComposerSheet({required this.status});

  final AdminDogUpdateStatus status;

  @override
  State<_WeeklyUpdateComposerSheet> createState() => _WeeklyUpdateComposerSheetState();
}

class _WeeklyUpdateComposerSheetState extends State<_WeeklyUpdateComposerSheet> {
  final _captionController = TextEditingController();
  File? _pickedVideo;
  bool _isSending = false;
  bool _isCompressing = false;

  @override
  void dispose() {
    _captionController.dispose();
    FlutterCompress.instance.clearCache();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isCompressing = true);
    // Raw phone camera exports (4K HEVC at 60+ Mbps) exceed what most
    // Android hardware decoders can play back — transcode to H.264 at a
    // capped resolution before upload so sponsors' video_player doesn't
    // just hang. Falls back to the original file if compression fails
    // rather than blocking the send.
    File? compressed;
    try {
      final result = await FlutterCompress.instance.compress(
        picked.path,
        const VideoCompressConfig(
          quality: CompressQuality.medium,
          codec: VideoCodec.h264,
          maxWidth: 1280,
          maxHeight: 1280,
        ),
      );
      compressed = File(result.outputPath);
    } catch (_) {
      compressed = null;
    }

    if (!mounted) return;
    setState(() {
      _pickedVideo = compressed ?? File(picked.path);
      _isCompressing = false;
    });
  }

  Future<void> _send() async {
    final video = _pickedVideo;
    if (video == null || _isSending || _isCompressing) return;

    setState(() => _isSending = true);
    final adminRepository = context.read<AdminRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final caption = _captionController.text.trim();

    final uploadResult =
        await adminRepository.uploadWeeklyUpdateVideo(dogId: widget.status.dogId, videoFile: video);

    final sentCount = await uploadResult.fold<Future<Either<Failure, int>>>(
      (failure) async => Left(failure),
      (mediaUrl) => adminRepository.sendWeeklyUpdate(
        dogId: widget.status.dogId,
        mediaUrl: mediaUrl,
        caption: caption.isEmpty ? null : caption,
      ),
    );

    if (!mounted) return;

    sentCount.fold(
      (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (count) {
        messenger.showSnackBar(SnackBar(content: Text('Sent to $count sponsor${count == 1 ? '' : 's'}.')));
        navigator.pop(true);
      },
    );

    if (mounted) setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: NeoBox(
          color: AppColors.ground,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Update · ${widget.status.dogName}', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Goes to ${widget.status.eligibleSponsorCount} eligible sponsor'
                '${widget.status.eligibleSponsorCount == 1 ? '' : 's'} (\$10+/mo).',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: NeoButton(
                  onPressed: _isSending || _isCompressing ? null : _pickVideo,
                  child: _isCompressing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CupertinoActivityIndicator(),
                        )
                      : Text(_pickedVideo == null ? 'Pick a video' : 'Change video'),
                ),
              ),
              if (_pickedVideo != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _pickedVideo!.path.split('/').last,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _captionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Caption (optional)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: NeoButton(
                  onPressed: _pickedVideo == null || _isSending || _isCompressing ? null : _send,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CupertinoActivityIndicator(),
                        )
                      : Text('Send to ${widget.status.eligibleSponsorCount} sponsor'
                          '${widget.status.eligibleSponsorCount == 1 ? '' : 's'}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
