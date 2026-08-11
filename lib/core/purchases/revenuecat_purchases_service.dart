import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kDebugMode;
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sponsor_a_dog/core/config/revenuecat_config.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';

/// Real RevenueCat-backed implementation. Only ever constructed on
/// Android/iOS — `purchases_flutter` doesn't support other platforms.
class RevenueCatPurchasesService implements PurchasesService {
  @override
  Future<void> initialize({String? appUserId}) async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      final apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? RevenueCatConfig.iosApiKey
          : RevenueCatConfig.androidApiKey;
      final configuration = PurchasesConfiguration(apiKey);
      if (appUserId != null) configuration.appUserID = appUserId;
      await Purchases.configure(configuration);
    } catch (_) {
      // Best-effort — a broken/placeholder API key shouldn't crash startup.
    }
  }

  @override
  Future<Either<Failure, Offerings>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return Right(offerings);
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load sponsorship offerings.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerInfo>> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return Right(result.customerInfo);
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Purchase failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerInfo>> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return Right(customerInfo);
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to restore purchases.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerInfo>> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return Right(customerInfo);
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load purchase info.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
