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
  Future<void> getActivePurchases();
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

  @override
  Future<void> getActivePurchases() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ No user logged in.');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final prefs = await SharedPreferences.getInstance();

        String? purchaseverificationData =
            doc.data()!['purchaseverificationData'];
        String? paymentPlanId = doc.data()!['paymentPlanId'];
        String? purchaseDateString = doc.data()!['purchaseDate'];

        if (paymentPlanId != null && paymentPlanId.isNotEmpty) {
          if (paymentPlanId.contains('upgrade')) {
            consumeIfExpired(
                purchaseDateString: purchaseDateString!,
                productId: paymentPlanId,
                purchaseToken: purchaseverificationData!,
                userId: userId);
          }

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

              prefs.setString(
                'paymentPlanId',
                '',
              );

              await clearUserPaymentFields(userId);

              await LinkServicesImpl().resetUserLinkPromotion(userId);
            }
          }
        }
      } else {
        return; // Bio not set or document missing
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch purchaseDetails details: $e');
      return;
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
}
