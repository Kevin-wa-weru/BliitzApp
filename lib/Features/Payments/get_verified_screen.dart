// ignore_for_file: use_build_context_synchronously

import 'package:bliitz/Features/HomeScreen/Explore/cubit/get_feed_links_cubit.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_pofile_details_cubit.dart';
import 'package:bliitz/services/payment_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/check_internet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetVerified extends StatefulWidget {
  const GetVerified({super.key});

  @override
  State<GetVerified> createState() => _GetVerifiedState();
}

class _GetVerifiedState extends State<GetVerified> {
  final ValueNotifier<int> _planNotifier = ValueNotifier<int>(0);
  final InAppPurchase _iap = InAppPurchase.instance;
  late Stream<List<PurchaseDetails>> _subscription;

  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _hasPaid = ValueNotifier<bool>(false);
  final ValueNotifier<Map<String, dynamic>> _selectedPlanDetails =
      ValueNotifier<Map<String, dynamic>>({});

  Future<void> _buy(ProductDetails productDetails, bool isSubsription) async {
    if (isSubsription) {
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails({(productDetails.id)});

      if (response.notFoundIDs.isNotEmpty) {}

      List<ProductDetails> products = response.productDetails;

      final ProductDetails product =
          products.firstWhere((p) => p.id == productDetails.id);
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        // The offer token is only required for subscriptions
        applicationUserName: null,
      );
      await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }

    if (!isSubsription) {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  setInitialPlan() async {
    final DateTime today = DateTime.now();
    final DateTime oneWeekLater = today.add(const Duration(days: 30));
    late Map<String, dynamic>? selectedProduct = {};
    selectedProduct =
        await PaymentServicesImpl().getProductById('verify_monthly');
    _selectedPlanDetails.value = {
      'id': selectedProduct!['id'] ?? '',
      'name': 'Monthly Verification',
      'type': 'Subscription',
      'title': selectedProduct['title'] ?? '',
      'description': selectedProduct['description'] ?? '',
      'price': selectedProduct['price'] ?? '',
      'duration': 'Billed monthly',
      'endDate':
          '${oneWeekLater.year}/${oneWeekLater.month}/${oneWeekLater.day}',
      'rawPrice': selectedProduct['rawPrice'] ?? '',
      'currencyCode': selectedProduct['currencyCode'] ?? '',
      'currencySymbol': selectedProduct['currencySymbol'] ?? '',
    };
  }

  void showPaymentBottomSheet({
    required BuildContext context,
    required String paymentType,
    required String planName,
    required String duration,
    required String expiryDate,
    required String price,
    required VoidCallback onPay,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.black,
      builder: (_) {
        return ValueListenableBuilder<int>(
            valueListenable: _pageNotifier,
            builder: (context, selectedIndex, child) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Subscripion',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      planName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF10CD00),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: $duration',
                      style: const TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white70,
                          fontSize: 14),
                    ),
                    Text(
                      'Next Billing Date: $expiryDate ',
                      style: const TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white70,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: 'Questrial',
                        color: Color(0xFF10CD00),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: onPay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10CD00),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Continue with',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontFamily: 'Questrial',
                                        letterSpacing: 0.3,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Opacity(
                                    opacity: 1,
                                    child: SvgPicture.asset(
                                      'assets/icons/google.svg',
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Pay',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            });
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _safeShowMessage(String message) {
    if (!mounted) return;
    _showMessage(message);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Acknowledge the purchase
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }

        // ✅ Store payment details in Firebase
        try {
          _hasPaid.value = true;
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            _safeShowMessage("User not logged in. Cannot save purchase.");
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          prefs.setString('verficationpaymentPlanId', purchase.productID);

          FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
            'verified': true,
            'verficationpaymentPlanId': purchase.productID,
            'verficationpurchaseDate': DateTime.now().toIso8601String(),
            'verficationpurchaseverificationData':
                purchase.verificationData.serverVerificationData,
          }, SetOptions(merge: true));

          _safeShowMessage("✅ Purchase was successful");
          Navigator.pop(
            context,
          );
          context.read<GetProfileDetailsCubit>().getProfileDetails(true);
        } catch (e) {
          _safeShowMessage("✅ Purchase was successful $e");
        }
      } else if (purchase.status == PurchaseStatus.error) {
        _safeShowMessage("❌ Purchase failed: ${purchase.error?.message}");
      } else if (purchase.status == PurchaseStatus.pending) {
        _safeShowMessage("⏳ Purchase is pending...");
      } else if (purchase.status == PurchaseStatus.canceled) {
        _safeShowMessage("❌ Purchase canceled by user.");
      }
    }
  }

  @override
  void initState() {
    super.initState();

    setInitialPlan();
    _subscription = _iap.purchaseStream;
    _subscription.listen(_listenToPurchaseUpdated, onError: (error) {
      _showMessage("An error occurred during the purchase. Please try again.");
    });
  }

  @override
  void dispose() {
    _pageNotifier.dispose();
    _planNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: Adapt.px(80),
                        width: Adapt.px(80),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.08),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100.0),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white60,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Get Verified',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: Color(0xCC01DE27),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Flexible(
            child: Text(
              'Unlock exclusive perks and stand out with a verification badge!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Questrial',
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
                fontSize: 16,
                letterSpacing: 0.5,
                height: 1.5,
                decorationColor: Colors.white.withOpacity(0.75),
              ),
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            'Benefits',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 0.5,
              height: 1.5,
              decorationColor: Colors.white.withOpacity(0.75),
            ),
            overflow: TextOverflow.visible,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Boosted Visibilty',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.5,
              decorationColor: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Credibilty & Trust',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.5,
              decorationColor: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Priority Support',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.5,
              decorationColor: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Verified Badges',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.5,
              decorationColor: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Promortions & Discounts',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.5,
              decorationColor: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          ValueListenableBuilder<int>(
              valueListenable: _planNotifier,
              builder: (context, selectedIndex, child) {
                return GestureDetector(
                  onTap: () async {
                    _planNotifier.value = 0;

                    final DateTime today = DateTime.now();
                    final DateTime oneMonthLater =
                        today.add(const Duration(days: 30));
                    late Map<String, dynamic>? selectedProduct = {};
                    selectedProduct = await PaymentServicesImpl()
                        .getProductById('verify_monthly');

                    print('Ushawals ${selectedProduct}');

                    _selectedPlanDetails.value = {
                      'id': selectedProduct!['id'] ?? '',
                      'name': 'Monthly Verification',
                      'type': 'Subscription',
                      'title': selectedProduct['title'] ?? '',
                      'description': selectedProduct['description'] ?? '',
                      'price': selectedProduct['price'] ?? '',
                      'duration': 'Billed monthly',
                      'endDate':
                          '${oneMonthLater.year}/${oneMonthLater.month}/${oneMonthLater.day}',
                      'rawPrice': selectedProduct['rawPrice'] ?? '',
                      'currencyCode': selectedProduct['currencyCode'] ?? '',
                      'currencySymbol': selectedProduct['currencySymbol'] ?? '',
                    };
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF292929),
                        border: Border.all(
                          color: _planNotifier.value == 0
                              ? const Color(0xFF10CD00)
                              : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Monthly plan',
                                    style: TextStyle(
                                      fontFamily: 'Questrial',
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      letterSpacing: 0.25,
                                      height: 1.5,
                                      decorationColor:
                                          Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                ],
                              ),
                              Text(
                                '\$ 8.99 / month',
                                style: TextStyle(
                                  fontFamily: 'Questrial',
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.25,
                                  height: 1.5,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Text(
                                '\$ 8.99 billed monthtly',
                                style: TextStyle(
                                  fontFamily: 'Questrial',
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  height: 1.5,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: 16,
          ),
          ValueListenableBuilder<int>(
              valueListenable: _planNotifier,
              builder: (context, selectedIndex, child) {
                return GestureDetector(
                  onTap: () async {
                    _planNotifier.value = 1;

                    final DateTime today = DateTime.now();
                    final DateTime oneYearLater =
                        today.add(const Duration(days: 365));
                    late Map<String, dynamic>? selectedProduct = {};
                    selectedProduct = await PaymentServicesImpl()
                        .getProductById('verify_annually');

                    _selectedPlanDetails.value = {
                      'id': selectedProduct!['id'] ?? '',
                      'name': 'Annual Verification',
                      'type': 'Subscription',
                      'title': selectedProduct['title'] ?? '',
                      'description': selectedProduct['description'] ?? '',
                      'price': selectedProduct['price'] ?? '',
                      'duration': 'Billed yearly',
                      'endDate':
                          '${oneYearLater.year}/${oneYearLater.month}/${oneYearLater.day}',
                      'rawPrice': selectedProduct['rawPrice'] ?? '',
                      'currencyCode': selectedProduct['currencyCode'] ?? '',
                      'currencySymbol': selectedProduct['currencySymbol'] ?? '',
                    };
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF292929),
                        border: Border.all(
                          color: _planNotifier.value == 1
                              ? const Color(0xFF10CD00)
                              : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Annual plan',
                                    style: TextStyle(
                                      fontFamily: 'Questrial',
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      letterSpacing: 0.25,
                                      height: 1.5,
                                      decorationColor:
                                          Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10CD00),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          'Save 16%',
                                          style: TextStyle(
                                            fontFamily: 'Questrial',
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            letterSpacing: 0.25,
                                            height: 1.5,
                                            decorationColor:
                                                Colors.white.withOpacity(0.75),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$ 89.99 / year',
                                style: TextStyle(
                                  fontFamily: 'Questrial',
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.25,
                                  height: 1.5,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Text(
                                '\$ 89.99 billed annually',
                                style: TextStyle(
                                  fontFamily: 'Questrial',
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  height: 1.5,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: 24,
          ),
          ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: _selectedPlanDetails,
              builder: (context, selectedPlan, child) {
                return GestureDetector(
                  onTap: () async {
                    bool isConnected = await ConnectivityHelper.isConnected();
                    if (!isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor:
                              const Color(0xE601DE27).withOpacity(.5),
                          content: const Text('No internet connection')));

                      return;
                    }
                    showPaymentBottomSheet(
                        context: context,
                        paymentType: selectedPlan['type'],
                        planName: selectedPlan['name'],
                        duration: selectedPlan['duration'],
                        expiryDate: selectedPlan['endDate'],
                        price: selectedPlan['price'],
                        onPay: () async {
                          Navigator.pop(context);
                          _buy(
                              ProductDetails(
                                  id: selectedPlan['id'],
                                  title: selectedPlan['title'],
                                  description: selectedPlan['description'],
                                  price: selectedPlan['price'],
                                  rawPrice:
                                      double.parse(selectedPlan['rawPrice']),
                                  currencyCode: selectedPlan['currencyCode'],
                                  currencySymbol:
                                      selectedPlan['currencySymbol']),
                              true);
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xCC01DE27),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Questrial',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                        height: 1.2,
                        decorationColor: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
