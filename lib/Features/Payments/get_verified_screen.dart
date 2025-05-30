import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';

class GetVerified extends StatefulWidget {
  const GetVerified({super.key});

  @override
  State<GetVerified> createState() => _GetVerifiedState();
}

class _GetVerifiedState extends State<GetVerified> {
  final ValueNotifier<int> _planNotifier = ValueNotifier<int>(0);

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
                  onTap: () {
                    _planNotifier.value = 0;
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
                  onTap: () {
                    _planNotifier.value = 1;
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
        ],
      ),
    );
  }
}
