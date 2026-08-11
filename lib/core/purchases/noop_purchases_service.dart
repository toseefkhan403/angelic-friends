import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';

/// Used on platforms `purchases_flutter` doesn't support (web, desktop) so
/// the app never touches the RevenueCat SDK there.
class NoopPurchasesService implements PurchasesService {
  const NoopPurchasesService();

  @override
  Future<void> initialize({String? appUserId}) async {}

  @override
  Future<Either<Failure, Offerings>> getOfferings() async =>
      const Left(ServerFailure('Purchases are not supported on this platform'));

  @override
  Future<Either<Failure, CustomerInfo>> purchasePackage(Package package) async =>
      const Left(ServerFailure('Purchases are not supported on this platform'));

  @override
  Future<Either<Failure, CustomerInfo>> restorePurchases() async =>
      const Left(ServerFailure('Purchases are not supported on this platform'));

  @override
  Future<Either<Failure, CustomerInfo>> getCustomerInfo() async =>
      const Left(ServerFailure('Purchases are not supported on this platform'));
}
