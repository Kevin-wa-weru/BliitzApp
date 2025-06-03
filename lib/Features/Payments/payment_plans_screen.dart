// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:bliitz/Features/HomeScreen/Explore/cubit/get_feed_links_cubit.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/services/payment_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/check_internet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoteScreen extends StatefulWidget {
  const PromoteScreen(
      {super.key, this.linkId, required this.fromPage, this.currentPlanId});
  final String? linkId;
  final String fromPage;
  final String? currentPlanId;
  @override
  State<PromoteScreen> createState() => _PromoteScreenState();
}

class _PromoteScreenState extends State<PromoteScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late Stream<List<PurchaseDetails>> _subscription;

  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _hasPaid = ValueNotifier<bool>(false);
  final ValueNotifier<int> _planNotifier = ValueNotifier<int>(0);
  final ValueNotifier<Map<String, dynamic>> _selectedPlanDetails =
      ValueNotifier<Map<String, dynamic>>({});
  final ValueNotifier<bool> _isTitleVisible = ValueNotifier<bool>(true);
  final ScrollController _scrollController = ScrollController();

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
    final DateTime oneWeekLater = today.add(const Duration(days: 7));
    late Map<String, dynamic>? selectedProduct = {};
    selectedProduct =
        await PaymentServicesImpl().getProductById('upgrade_minimal');

    _selectedPlanDetails.value = {
      'id': selectedProduct!['id'] ?? '',
      'name': 'Minimal Plan',
      'type': 'One-Time Payment',
      'title': selectedProduct['title'] ?? '',
      'description': selectedProduct['description'] ?? '',
      'price': selectedProduct['price'] ?? '',
      'duration': '1 Week',
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
                    Text(
                      selectedIndex == 0 ? 'One-Time Payment' : 'Subscripion',
                      style: const TextStyle(
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
                      selectedIndex == 0
                          ? 'Duration: $duration'
                          : 'Duration: Billed Weekly',
                      style: const TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white70,
                          fontSize: 14),
                    ),
                    Text(
                      selectedIndex == 0
                          ? 'Will be active until: $expiryDate'
                          : 'Next Billing Date: $expiryDate ',
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
          prefs.setString('paymentPlanId', purchase.productID);

          FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
            'paymentPlanId': purchase.productID,
            'purchaseDate': DateTime.now().toIso8601String(),
            'purchaseverificationData':
                purchase.verificationData.serverVerificationData,
          }, SetOptions(merge: true));

          _safeShowMessage("✅ Purchase was successful");

          final paymentDoc = {
            'userId': user.uid,
            'productId': purchase.productID,
            'purchaseId': purchase.purchaseID,
            'transactionDate': DateTime.now().toIso8601String(),
            'status': purchase.status.toString(),
            'isAcknowledged': purchase.pendingCompletePurchase,
            'purchaseverificationData':
                purchase.verificationData.serverVerificationData,
          };

          await FirebaseFirestore.instance
              .collection('Payments')
              .add(paymentDoc);

          if (widget.linkId != null) {
            FirebaseFirestore.instance
                .collection('Links')
                .doc(widget.linkId)
                .update({'promoted': true});

            context.read<GetOwnersLinksCubit>().getLinks();
            context.read<GetLinksCubit>().getLinks('Explore', false);
          }
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
    _pageNotifier.addListener(() {
      _pageController.jumpToPage(_pageNotifier.value);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // Scrolling up
        if (_isTitleVisible.value) {
          _isTitleVisible.value = false;
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // Scrolling down
        if (!_isTitleVisible.value) {
          _isTitleVisible.value = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    _planNotifier.dispose();
    _scrollController.dispose();
    _isTitleVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    ValueListenableBuilder<bool>(
                        valueListenable: _hasPaid,
                        builder: (context, paid, child) {
                          return GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              var paymentPlanId =
                                  prefs.getString('paymentPlanId');
                              if (widget.fromPage == 'LinkDetailsPage') {
                                Navigator.pop(
                                  context,
                                  {
                                    'hasPaid': paid,
                                  },
                                );
                              }
                              if (widget.fromPage == 'AccountsPage') {
                                Navigator.pop(
                                  context,
                                  {
                                    'hasPaid': paid,
                                    'planId': paymentPlanId,
                                  },
                                );
                              } else {
                                Navigator.pop(context);
                              }
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
                          );
                        }),
                    const SizedBox(
                      width: 16,
                    ),
                    SizedBox(
                      height: Adapt.px(80),
                      child: Opacity(
                        opacity: .9,
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          height: 24,
                          width: 24,
                          color: const Color(0xCC01DE27),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Available plans',
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
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Unlock your group potentials with plans',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Questrial',
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        height: 1.5,
                        decorationColor: Colors.white.withOpacity(0.75),
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<bool>(
                  valueListenable: _isTitleVisible,
                  builder: (context, isVisible, child) {
                    return AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isVisible
                          ? Column(
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ValueListenableBuilder<int>(
                                        valueListenable: _pageNotifier,
                                        builder:
                                            (context, selectedIndex, child) {
                                          return GestureDetector(
                                            onTap: () {
                                              _pageNotifier.value = 0;
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                              decoration: BoxDecoration(
                                                color: selectedIndex == 0
                                                    ? const Color(0xCC01DE27)
                                                    : const Color(0xFF292929),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              child: Text(
                                                'One time payment',
                                                style: TextStyle(
                                                  color: selectedIndex == 0
                                                      ? Colors.black
                                                      : Colors.white
                                                          .withOpacity(0.75),
                                                  fontFamily: 'Questrial',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
                                                  height: 1.2,
                                                  decorationColor: Colors.white
                                                      .withOpacity(0.75),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    ValueListenableBuilder<int>(
                                        valueListenable: _pageNotifier,
                                        builder:
                                            (context, selectedIndex, child) {
                                          return GestureDetector(
                                            onTap: () {
                                              _pageNotifier.value = 1;
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                              decoration: BoxDecoration(
                                                color: selectedIndex == 1
                                                    ? const Color(0xCC01DE27)
                                                    : const Color(0xFF292929),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              child: Text(
                                                'Subscription',
                                                style: TextStyle(
                                                  color: selectedIndex == 1
                                                      ? Colors.black
                                                      : Colors.white
                                                          .withOpacity(0.75),
                                                  fontFamily: 'Questrial',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
                                                  height: 1.2,
                                                  decorationColor: Colors.white
                                                      .withOpacity(0.75),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 8,
                            ),
                    );
                  }),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    _pageNotifier.value = index;
                  },
                  controller: _pageController,
                  children: [
                    PayPlans(
                      planNotifier: _planNotifier,
                      scrollController: _scrollController,
                      isOneTime: true,
                      selectedPlanDetailsNotifier: _selectedPlanDetails,
                      currentPlanId: widget.currentPlanId,
                    ),
                    PayPlans(
                      planNotifier: _planNotifier,
                      scrollController: _scrollController,
                      isOneTime: false,
                      selectedPlanDetailsNotifier: _selectedPlanDetails,
                      currentPlanId: widget.currentPlanId,
                    ),
                  ],
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              width: Adapt.screenW(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.8),
                    Colors.black,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<int>(
                        valueListenable: _pageNotifier,
                        builder: (context, selectedIndex, child) {
                          return ValueListenableBuilder<Map<String, dynamic>>(
                              valueListenable: _selectedPlanDetails,
                              builder: (context, selectedPlan, child) {
                                return GestureDetector(
                                  onTap: () async {
                                    bool isConnected =
                                        await ConnectivityHelper.isConnected();
                                    if (!isConnected) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor:
                                                  const Color(0xE601DE27)
                                                      .withOpacity(.5),
                                              content: const Text(
                                                  'No internet connection')));

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
                                                  description: selectedPlan[
                                                      'description'],
                                                  price: selectedPlan['price'],
                                                  rawPrice: double.parse(
                                                      selectedPlan['rawPrice']),
                                                  currencyCode: selectedPlan[
                                                      'currencyCode'],
                                                  currencySymbol: selectedPlan[
                                                      'currencySymbol']),
                                              selectedIndex == 1
                                                  ? true
                                                  : false);
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
                                        decorationColor:
                                            Colors.white.withOpacity(0.75),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PayPlans extends StatelessWidget {
  const PayPlans({
    super.key,
    required ValueNotifier<int> planNotifier,
    required ValueNotifier<Map<String, dynamic>> selectedPlanDetailsNotifier,
    required ScrollController scrollController,
    required this.isOneTime,
    this.currentPlanId,
  })  : _planNotifier = planNotifier,
        _selectedPlanDetailsNotifier = selectedPlanDetailsNotifier,
        _scrollController = scrollController;

  final ValueNotifier<int> _planNotifier;
  final ValueNotifier<Map<String, dynamic>> _selectedPlanDetailsNotifier;
  final ScrollController _scrollController;
  final bool isOneTime;
  final String? currentPlanId;

  bool resolveToDisPlayPlan(
    String? planId,
  ) {
    if (currentPlanId == null) {
      return true;
    }
    if (currentPlanId == planId) {
      // return false;
      return true;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          !resolveToDisPlayPlan(
                  isOneTime ? 'upgrade_minimal' : 'subscribe_minimal')
              ? const SizedBox.shrink()
              : MinimalPlan(
                  planNotifier: _planNotifier,
                  isOneTime: isOneTime,
                  selectedPlanDetailsNotifier: _selectedPlanDetailsNotifier),
          const SizedBox(
            height: 24,
          ),
          !resolveToDisPlayPlan(isOneTime ? 'upgrade_basic' : 'subscribe_basic')
              ? const SizedBox.shrink()
              : BasicPlan(
                  planNotifier: _planNotifier,
                  isOneTime: isOneTime,
                  selectedPlanDetailsNotifier: _selectedPlanDetailsNotifier),
          const SizedBox(
            height: 24,
          ),
          !resolveToDisPlayPlan(
                  isOneTime ? 'upgrade_essential' : 'subscribe_essential')
              ? const SizedBox.shrink()
              : EssentialPlan(
                  planNotifier: _planNotifier,
                  isOneTime: isOneTime,
                  selectedPlanDetailsNotifier: _selectedPlanDetailsNotifier),
          !resolveToDisPlayPlan(
                  isOneTime ? 'upgrade_premium' : 'subscribe_premium')
              ? const SizedBox.shrink()
              : PremiumPlan(
                  planNotifier: _planNotifier,
                  isOneTime: isOneTime,
                  selectedPlanDetailsNotifier: _selectedPlanDetailsNotifier),
          const SizedBox(
            height: 96,
          ),
        ],
      ),
    );
  }
}

class PremiumPlan extends StatelessWidget {
  const PremiumPlan({
    super.key,
    required ValueNotifier<int> planNotifier,
    required this.isOneTime,
    required ValueNotifier<Map<String, dynamic>> selectedPlanDetailsNotifier,
  })  : _planNotifier = planNotifier,
        _selectedPlanDetailsNotifier = selectedPlanDetailsNotifier;

  final ValueNotifier<int> _planNotifier;
  final bool isOneTime;
  final ValueNotifier<Map<String, dynamic>> _selectedPlanDetailsNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(
              'Premium Plan',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Up to +4k impressions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Appear in top search results',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Get to suggestions to users',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'More impressions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<int>(
                valueListenable: _planNotifier,
                builder: (context, selectedIndex, child) {
                  return GestureDetector(
                    onTap: () async {
                      _planNotifier.value = 3;

                      final DateTime today = DateTime.now();
                      final DateTime oneWeekLater =
                          today.add(const Duration(days: 7));
                      late Map<String, dynamic>? selectedProduct = {};
                      if (isOneTime) {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('upgrade_premium');
                      } else {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('subscribe_premium');
                      }

                      _selectedPlanDetailsNotifier.value = {
                        'id': selectedProduct!['id'] ?? '',
                        'name': 'Premium Plan',
                        'type': isOneTime ? 'One-Time Payment' : 'Subscription',
                        'title': selectedProduct['title'] ?? '',
                        'description': selectedProduct['description'] ?? '',
                        'price': selectedProduct['price'] ?? '',
                        'duration': '1 Week',
                        'endDate':
                            '${oneWeekLater.year}/${oneWeekLater.month}/${oneWeekLater.day}',
                        'rawPrice': selectedProduct['rawPrice'] ?? '',
                        'currencyCode': selectedProduct['currencyCode'] ?? '',
                        'currencySymbol':
                            selectedProduct['currencySymbol'] ?? '',
                      };
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF292929),
                        border: Border.all(
                          color: _planNotifier.value == 3
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
                                    'Premium Plan',
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
                                          'Save 30%',
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
                                isOneTime
                                    ? '\$ 16.99 / Week'
                                    : '\$ 16.99 / Weekly',
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
                                isOneTime
                                    ? '\$ 16.99 for + 4k impressions in one week'
                                    : '\$ 16.99 for + 4k impressions in weekly',
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
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class EssentialPlan extends StatelessWidget {
  const EssentialPlan({
    super.key,
    required ValueNotifier<int> planNotifier,
    required this.isOneTime,
    required ValueNotifier<Map<String, dynamic>> selectedPlanDetailsNotifier,
  })  : _planNotifier = planNotifier,
        _selectedPlanDetailsNotifier = selectedPlanDetailsNotifier;

  final ValueNotifier<int> _planNotifier;
  final bool isOneTime;
  final ValueNotifier<Map<String, dynamic>> _selectedPlanDetailsNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(
              'Essential Plan',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Up to +2.5k impressions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Appear in top search results',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Get substantial suggestions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'More impressions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<int>(
                valueListenable: _planNotifier,
                builder: (context, selectedIndex, child) {
                  return GestureDetector(
                    onTap: () async {
                      _planNotifier.value = 2;

                      final DateTime today = DateTime.now();
                      final DateTime oneWeekLater =
                          today.add(const Duration(days: 7));
                      late Map<String, dynamic>? selectedProduct = {};
                      if (isOneTime) {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('upgrade_essential');
                      } else {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('subscribe_essential');
                      }

                      _selectedPlanDetailsNotifier.value = {
                        'id': selectedProduct!['id'] ?? '',
                        'name': 'Essential Plan',
                        'type': isOneTime ? 'One-Time Payment' : 'Subscription',
                        'title': selectedProduct['title'] ?? '',
                        'description': selectedProduct['description'] ?? '',
                        'price': selectedProduct['price'] ?? '',
                        'duration': '1 Week',
                        'endDate':
                            '${oneWeekLater.year}/${oneWeekLater.month}/${oneWeekLater.day}',
                        'rawPrice': selectedProduct['rawPrice'] ?? '',
                        'currencyCode': selectedProduct['currencyCode'] ?? '',
                        'currencySymbol':
                            selectedProduct['currencySymbol'] ?? '',
                      };
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF292929),
                        border: Border.all(
                          color: _planNotifier.value == 2
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
                                    'Essential Plan',
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
                                          'Save 23%',
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
                                isOneTime
                                    ? '\$ 7.99 / Week'
                                    : '\$ 7.99 / Weekly',
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
                                isOneTime
                                    ? '\$ 7.99 for + 2.5k impressions in one week'
                                    : '\$ 7.99 for + 2.5k impressions in weekly',
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
                  );
                }),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class BasicPlan extends StatelessWidget {
  const BasicPlan({
    super.key,
    required ValueNotifier<int> planNotifier,
    required this.isOneTime,
    required ValueNotifier<Map<String, dynamic>> selectedPlanDetailsNotifier,
  })  : _planNotifier = planNotifier,
        _selectedPlanDetailsNotifier = selectedPlanDetailsNotifier;

  final ValueNotifier<int> _planNotifier;
  final bool isOneTime;
  final ValueNotifier<Map<String, dynamic>> _selectedPlanDetailsNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(
              'Basic Plan',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Up to +1k impressions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Appear in top search results',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Get moderate suggestions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<int>(
                valueListenable: _planNotifier,
                builder: (context, selectedIndex, child) {
                  return GestureDetector(
                    onTap: () async {
                      _planNotifier.value = 1;

                      final DateTime today = DateTime.now();
                      final DateTime oneWeekLater =
                          today.add(const Duration(days: 7));
                      late Map<String, dynamic>? selectedProduct = {};
                      if (isOneTime) {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('upgrade_basic');
                      } else {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('subscribe_basic');
                      }

                      _selectedPlanDetailsNotifier.value = {
                        'id': selectedProduct!['id'] ?? '',
                        'name': 'Basic Plan',
                        'type': isOneTime ? 'One-Time Payment' : 'Subscription',
                        'title': selectedProduct['title'] ?? '',
                        'description': selectedProduct['description'] ?? '',
                        'price': selectedProduct['price'] ?? '',
                        'duration': '1 Week',
                        'endDate':
                            '${oneWeekLater.year}/${oneWeekLater.month}/${oneWeekLater.day}',
                        'rawPrice': selectedProduct['rawPrice'] ?? '',
                        'currencyCode': selectedProduct['currencyCode'] ?? '',
                        'currencySymbol':
                            selectedProduct['currencySymbol'] ?? '',
                      };
                    },
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
                                    'Basic Plan',
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
                                isOneTime
                                    ? '\$ 4.99 / Week'
                                    : '\$ 4.99 / Weekly',
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
                                isOneTime
                                    ? '\$ 4.99 for + 1k impressions in one week'
                                    : '\$ 4.99 for + 1k impressions in weekly',
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
                  );
                }),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class MinimalPlan extends StatelessWidget {
  const MinimalPlan({
    super.key,
    required ValueNotifier<int> planNotifier,
    required this.isOneTime,
    required ValueNotifier<Map<String, dynamic>> selectedPlanDetailsNotifier,
  })  : _planNotifier = planNotifier,
        _selectedPlanDetailsNotifier = selectedPlanDetailsNotifier;

  final ValueNotifier<int> _planNotifier;
  final bool isOneTime;
  final ValueNotifier<Map<String, dynamic>> _selectedPlanDetailsNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(
              'Minimal Plan',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Up to +500 Impressions',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Get subtle suggestions to users',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<int>(
                valueListenable: _planNotifier,
                builder: (context, selectedIndex, child) {
                  return GestureDetector(
                    onTap: () async {
                      _planNotifier.value = 0;
                      final DateTime today = DateTime.now();
                      final DateTime oneWeekLater =
                          today.add(const Duration(days: 7));
                      late Map<String, dynamic>? selectedProduct = {};
                      if (isOneTime) {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('upgrade_minimal');
                      } else {
                        selectedProduct = await PaymentServicesImpl()
                            .getProductById('subscribe_minimal');
                      }

                      _selectedPlanDetailsNotifier.value = {
                        'id': selectedProduct!['id'] ?? '',
                        'name': 'Minimal Plan',
                        'type': isOneTime ? 'One-Time Payment' : 'Subscription',
                        'title': selectedProduct['title'] ?? '',
                        'description': selectedProduct['description'] ?? '',
                        'price': selectedProduct['price'] ?? '',
                        'duration': '1 Week',
                        'endDate':
                            '${oneWeekLater.year}/${oneWeekLater.month}/${oneWeekLater.day}',
                        'rawPrice': selectedProduct['rawPrice'] ?? '',
                        'currencyCode': selectedProduct['currencyCode'] ?? '',
                        'currencySymbol':
                            selectedProduct['currencySymbol'] ?? '',
                      };
                    },
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
                              Text(
                                'Minimal Plan',
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
                              Text(
                                isOneTime
                                    ? '\$ 2.99 / Week'
                                    : '\$ 2.99 / Weekly',
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
                                isOneTime
                                    ? '\$ 2.99 for +500 impressions in one week'
                                    : '\$ 2.99 for +500 impressions in weekly',
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
                  );
                }),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
