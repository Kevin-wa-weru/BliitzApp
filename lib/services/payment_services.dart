import 'dart:convert';

import 'package:bliitz/services/link_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PaymentServices {
  Future<void> initStoreInfo();
  Future<List<Map<String, String>>> loadCachedProducts();
  Future<Map<String, String>?> getProductById(String productId);
  Future<void> buyProduct(ProductDetails productDetails);
  // Future<List<PurchaseDetails>> getActivePurchases();
  Future<void> getActivePurchases(
      {required DocumentSnapshot<Map<String, dynamic>> doc});
  Future<bool> cancelSubscription(String subscriptionId, String purchaseToken);
}

class PaymentServicesImpl implements PaymentServices {
  @override
  Future<void> initStoreInfo() async {
    const Set<String> kProductIds = {
      'upgrade_minimal',
      'upgrade_basic',
      'upgrade_essential',
      'upgrade_premium',
      'subscribe_minimal',
      'subscribe_basic',
      'subscribe_essential',
      'subscribe_premium',
      'verify_monthly',
      'verify_annually',
    };

    final InAppPurchase iap = InAppPurchase.instance;
    List<ProductDetails> products = [];

    final bool available = await iap.isAvailable();
    if (!available) {
      debugPrint('Store not available');
      return;
    }

    final ProductDetailsResponse response =
        await iap.queryProductDetails(kProductIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs.toString()}');
    }

    products = response.productDetails;
    debugPrint('Found products ${products.toString()}');
    await cacheProductDetails(products);
  }

  Future<void> cacheProductDetails(List<ProductDetails> products) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cached = products.map((product) {
      return jsonEncode({
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'rawPrice': product.rawPrice.toString(),
        'currencyCode': product.currencyCode,
        'currencySymbol': product.currencySymbol,
      });
    }).toList();
    await prefs.setStringList('cached_products', cached);
  }

  @override
  Future<List<Map<String, String>>> loadCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList('cached_products') ?? [];
    return cached.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  }

  @override
  Future<Map<String, String>?> getProductById(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList('cached_products') ?? [];

    for (var item in cached) {
      final product = Map<String, String>.from(jsonDecode(item));
      if (product['id'] == productId) {
        return product;
      }
    }

    return null; // Product not found
  }

  @override
  Future<void> buyProduct(ProductDetails productDetails) async {
    final InAppPurchase iap = InAppPurchase.instance;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> clearUserPaymentFields(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Users').doc(userId).update({
        'paymentPlanId': '',
        'purchaseDate': '',
        'purchaseverificationData': '',
      });

      debugPrint('User payment fields cleared successfully.');
    } catch (e) {
      debugPrint('Error clearing user payment fields: $e');
    }
  }

  Future<void> clearUserVerificationPaymentFields(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Users').doc(userId).update({
        'verficationpaymentPlanId': '',
        'verficationpurchaseDate': '',
        'verficationpurchaseverificationData': '',
        'verified': false
      });

      debugPrint('User payment fields cleared successfully.');
    } catch (e) {
      debugPrint('Error clearing user payment fields: $e');
    }
  }

  @override
  Future<bool> getActivePurchases(
      {required DocumentSnapshot<Map<String, dynamic>> doc}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ No user logged in.');
        return doc.data()!['verified'];
      }

      if (doc.exists && doc.data() != null) {
        final prefs = await SharedPreferences.getInstance();

        ////// Feature payments //////

        String? purchaseverificationData =
            doc.data()!['purchaseverificationData'];
        String? paymentPlanId = doc.data()!['paymentPlanId'];
        String? purchaseDateString = doc.data()!['purchaseDate'];

        if (paymentPlanId != null && paymentPlanId.isNotEmpty) {
          //
          // One time

          if (paymentPlanId.contains('upgrade')) {
            consumeIfExpired(
                purchaseDateString: purchaseDateString!,
                productId: paymentPlanId,
                purchaseToken: purchaseverificationData!,
                userId: userId);
          }
          //
          // Subscriptions

          if (paymentPlanId.contains('subscribe')) {
            final result = await FirebaseFunctions.instance
                .httpsCallable('checkSubscriptionStatus')
                .call({
              'subscriptionId': paymentPlanId,
              'purchaseToken': purchaseverificationData
            });

            if (result.data['active'] == true) {
              debugPrint(
                  'Subscription is active until ${DateTime.fromMillisecondsSinceEpoch(int.parse(result.data['expiryTimeMillis']))}');
            } else {
              debugPrint('Subscription is not active.');
              final activeUntil = DateTime.fromMillisecondsSinceEpoch(
                  int.parse(result.data['expiryTimeMillis'].toString()));

              if (DateTime.now().isAfter(activeUntil)) {
                prefs.setString(
                  'paymentPlanId',
                  '',
                );

                await clearUserPaymentFields(userId);

                await LinkServicesImpl().resetUserLinkPromotion(userId);
              }
            }
          }
        }

        //////   Verification payments   //////
        String? verficationpaymentPlanId =
            doc.data()!['verficationpaymentPlanId'];
        String? verficationpurchaseverificationData =
            doc.data()!['verficationpurchaseverificationData'];

        if (verficationpaymentPlanId != null &&
            verficationpaymentPlanId.isNotEmpty) {
          prefs.setString(
            'verficationpaymentPlanId',
            verficationpaymentPlanId,
          );

          prefs.setString(
            'verficationpurchaseverificationData',
            verficationpurchaseverificationData!,
          );

          final result = await FirebaseFunctions.instance
              .httpsCallable('checkSubscriptionStatus')
              .call({
            'subscriptionId': verficationpaymentPlanId,
            'purchaseToken': verficationpurchaseverificationData
          });

          final activeUntill = DateTime.fromMillisecondsSinceEpoch(
              int.parse(result.data['expiryTimeMillis'].toString()));

          debugPrint(
              'Subscription verfication reslt from cloud $activeUntill.');

          if (result.data['active'] == true) {
            debugPrint(
                'Subscription verfication is active until ${DateTime.fromMillisecondsSinceEpoch(int.parse(result.data['expiryTimeMillis'].toString()))}');
            return doc.data()!['verified'];
          } else {
            debugPrint('Subscription verfication is not active.');

            if (DateTime.now().isAfter(activeUntill)) {
              prefs.setString(
                'verficationpaymentPlanId',
                '',
              );
              prefs.setString(
                'verficationpurchaseverificationData',
                '',
              );

              await clearUserVerificationPaymentFields(userId);

              return false;
            } else {
              return doc.data()!['verified'];
            }
          }
        } else {
          return doc.data()!['verified'];
        }
      } else {
        return false; // Bio not set or document missing
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch purchaseDetails details: $e');
      return doc.data()!['verified'];
    }
  }

  Future<void> consumeIfExpired({
    required String purchaseDateString,
    required String productId,
    required String purchaseToken,
    required String userId,
  }) async {
    final purchaseDate = DateTime.parse(purchaseDateString);
    final now = DateTime.now();
    final daysSincePurchase = now.difference(purchaseDate).inDays;

    if (daysSincePurchase < 8) {
      debugPrint('Purchase is still within 8-day window. Not consuming.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('consumeOneTimeProduct');
      final result = await callable.call({
        'productId': productId,
        'purchaseToken': purchaseToken,
      });

      if (result.data['success'] == true) {
        debugPrint('Product consumed successfully.');

        prefs.setString(
          'paymentPlanId',
          '',
        );

        await clearUserPaymentFields(userId);

        await LinkServicesImpl().resetUserLinkPromotion(userId);
      } else {
        debugPrint('Failed to consume product: ${result.data}');
      }
    } catch (e) {
      debugPrint('Error consuming product: $e');
    }
  }

  @override
  Future<bool> cancelSubscription(
      String subscriptionId, String purchaseToken) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('cancelSubscription');

    try {
      final result = await callable.call({
        'subscriptionId': subscriptionId,
        'purchaseToken': purchaseToken,
        'packageName': 'com.bliitz.social'
      });

      if (result.data['success']) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
