import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/features/admin/domain/entities/admin_dog_update_status.dart';
import 'package:sponsor_a_dog/features/admin/domain/entities/admin_sponsorship_overview.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';

/// Admin-only access to every sponsor's ("Angel") thread and to broadcasting
/// weekly video updates — gated server-side by the `is_admin()` Postgres
/// function, not by anything in this repository itself.
abstract class AdminRepository {
  Future<Either<Failure, List<AdminSponsorshipOverview>>> getAngelOverviews();

  Future<Either<Failure, List<ChatMessage>>> getMessages(String sponsorshipId);

  Future<Either<Failure, ChatMessage>> sendHandlerReply({
    required String sponsorshipId,
    required String text,
  });

  Future<Either<Failure, List<AdminDogUpdateStatus>>> getDogUpdateStatuses();

  /// Uploads [videoFile] to the `dog-media` bucket and returns its public
  /// URL, ready to pass to [sendWeeklyUpdate].
  Future<Either<Failure, String>> uploadWeeklyUpdateVideo({
    required String dogId,
    required File videoFile,
  });

  /// Broadcasts one video message into every one of [dogId]'s eligible
  /// active sponsors' threads. Returns how many sponsors it reached.
  Future<Either<Failure, int>> sendWeeklyUpdate({
    required String dogId,
    required String mediaUrl,
    String? caption,
  });
}
