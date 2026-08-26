import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}

/// The user dismissed a native sign-in sheet (Google account picker, Apple
/// ID prompt) themselves — not a real error, so callers should quietly
/// reset rather than show an error message.
class AuthCancelledFailure extends Failure {
  const AuthCancelledFailure() : super('Sign-in was cancelled.');
}
