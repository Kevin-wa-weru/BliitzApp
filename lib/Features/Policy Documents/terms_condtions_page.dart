// ignore_for_file: deprecated_member_use

import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: GestureDetector(
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
                              ),
                            ],
                          ),
                          Center(
                            child: SizedBox(
                              height: Adapt.px(80),
                              child: Opacity(
                                opacity: .9,
                                child: SvgPicture.asset(
                                  'assets/images/logo.svg',
                                  height: 32,
                                  width: 32,
                                  color: const Color(0xCC01DE27),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Bliitz Terms and Conditions",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Effective Date: 9th April 2025",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                _buildSection(
                  "Welcome to Bliitz LLC. By using our app, you agree to the following terms and conditions. If you do not agree, please discontinue use of the app.",
                ),
                _buildTitle("User Eligibility and Account Security"),
                _buildSection(
                  "You must be at least 13 years old to use this app. You are responsible for maintaining the confidentiality of your account credentials and for any activity that occurs under your account. Providing false information or impersonating another person is strictly prohibited and may result in account termination.",
                ),
                _buildTitle("Acceptable Use Policy"),
                _buildSection(
                  "Users are strictly prohibited from uploading, sharing, or promoting pornographic content, including groups, images, or discussions related to explicit material. Additionally, impersonating others, creating fake identities, or misleading users about your identity is not allowed. Any violation of these rules may result in immediate suspension or permanent banning of your account.",
                ),
                _buildTitle("Payments and Refund Policy"),
                _buildSection(
                  "Purchases made through the app include both one-time payments and subscription-based services. One-time payments are non-refundable, while subscriptions can be canceled at any time. Once a subscription is canceled, access will continue until the end of the billing period, and no further charges will be applied.",
                ),
                _buildTitle("User-Generated Content"),
                _buildSection(
                  "Users are responsible for the content they post, including messages, group descriptions, and images. Bliitz LLC reserves the right to remove any content that violates our policies or is deemed harmful, offensive, or inappropriate. We may also restrict or terminate accounts involved in repeated violations.",
                ),
                _buildTitle("Intellectual Property"),
                _buildSection(
                  "All trademarks, logos, and content within the app are owned by Bliitz LLC and cannot be copied, modified, or distributed without prior consent. Any unauthorized use of our intellectual property may result in legal action.",
                ),
                _buildTitle("Privacy and Data Protection"),
                _buildSection(
                  "We collect and process user data as outlined in our Privacy Policy. By using our app, you consent to the collection and use of your information as described. We take security seriously and implement measures to protect your data, but we cannot guarantee complete security against unauthorized access.",
                ),
                _buildTitle("Limitation of Liability"),
                _buildSection(
                  "Bliitz LLC provides this app on an 'as is' basis and does not guarantee uninterrupted or error-free service. We are not responsible for any losses, damages, or legal claims resulting from the use or inability to use the app. Users assume all risks associated with their interactions on the platform.",
                ),
                _buildTitle("Account Termination and Enforcement"),
                _buildSection(
                  "Bliitz LLC reserves the right to terminate or suspend accounts that violate these terms without prior notice. Users may also delete their accounts voluntarily at any time.",
                ),
                _buildTitle("Governing Law and Dispute Resolution"),
                _buildSection(
                  "These Terms and Conditions are governed by the laws of [Your Country]. Any disputes arising from the use of our services shall first be resolved through negotiation, and if necessary, through arbitration or legal proceedings.",
                ),
                _buildTitle("Changes to These Terms"),
                _buildSection(
                  "We may update these Terms and Conditions as necessary. Changes will be communicated through the app, and continued use after updates constitutes acceptance of the revised terms.",
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTitle(String title) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 16),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white.withOpacity(0.7),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

Widget _buildSection(String content) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      content,
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
  );
}
