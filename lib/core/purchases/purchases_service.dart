import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';

/// Thin wrapper around the RevenueCat SDK (`purchases_flutter`) so the rest
/// of the app depends on this interface rather than `Purchases.*` directly.
///
/// Every method must fail gracefully: purchases can't actually complete
/// until real RevenueCat API keys and store products exist, and this must
/// never crash the app in the meantime.
abstract class PurchasesService {
  /// Best-effort SDK init; failures are swallowed (logged only) so a
  /// misconfigured paywall never blocks app startup.
  Future<void> initialize({String? appUserId});

  Future<Either<Failure, Offerings>> getOfferings();
  Future<Either<Failure, CustomerInfo>> purchasePackage(Package package);
  Future<Either<Failure, CustomerInfo>> restorePurchases();
  Future<Either<Failure, CustomerInfo>> getCustomerInfo();
}
