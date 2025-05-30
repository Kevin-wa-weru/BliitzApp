// ignore_for_file: deprecated_member_use

import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrivacyPoliciy extends StatefulWidget {
  const PrivacyPoliciy({super.key});

  @override
  State<PrivacyPoliciy> createState() => _PrivacyPoliciyState();
}

class _PrivacyPoliciyState extends State<PrivacyPoliciy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                        "Bliitz Privacy Policy",
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
                  "At Bliitz LLC, we respect your privacy and are committed to protecting the personal information you share with us. This Privacy Policy explains how we collect, use, store, and protect your information when you use our app and related services. By using our app, you agree to the terms outlined in this Privacy Policy.",
                ),
                _buildTitle("Information We Collect"),
                _buildSection(
                  "We collect both personal and non-personal information to enhance your experience. Personal data may include your name, email address, phone number, and payment details when you register or interact with our services. Additionally, we collect non-personal data such as device type, IP address, browser type, and app usage patterns. If you sign in using third-party platforms like Google or Facebook, we may collect necessary account details as permitted by those services.",
                ),
                _buildTitle("How We Collect Your Information"),
                _buildSection(
                  "We gather information when you create an account, interact with our app, contact customer support, or use third-party services integrated with our platform. We may also use cookies, tracking technologies, and analytics tools to understand how users engage with our services.",
                ),
                _buildTitle("How We Use Your Information"),
                _buildSection(
                  "Your information is used to provide and improve our app, personalize your experience, process transactions, communicate with you, and ensure security. We may send notifications, promotional messages, or service updates, but you can opt out of marketing communications at any time.",
                ),
                _buildTitle("Sharing and Disclosure of Information"),
                _buildSection(
                  "We do not sell your personal information. However, we may share data with third-party service providers who assist with payment processing, cloud storage, analytics, and security. We may also disclose information if required by law, to protect our legal rights, or in connection with a business transaction such as a merger or acquisition.",
                ),
                _buildTitle("Data Security and Retention"),
                _buildSection(
                  "We take reasonable security measures to protect your data from unauthorized access, loss, or misuse. Your personal information is stored using encryption and access controls. We retain data for as long as necessary to fulfill the purposes outlined in this policy, comply with legal obligations, or resolve disputes.",
                ),
                _buildTitle("Your Rights and Choices"),
                _buildSection(
                  "You have the right to access, update, or delete your personal information. You may also withdraw consent for data processing or opt out of marketing messages. If you wish to exercise these rights, please contact us using the details provided below.",
                ),
                _buildTitle("Cookies and Tracking Technologies"),
                _buildSection(
                  "Our app may use cookies and similar technologies to enhance functionality, measure user engagement, and deliver personalized experiences. You can manage or disable cookies through your device settings.",
                ),
                _buildTitle("Third-Party Links and Services"),
                _buildSection(
                  "Our app may contain links to external websites or services. We are not responsible for the privacy practices of third parties, and we encourage you to review their policies before sharing any information.",
                ),
                _buildTitle("Children's Privacy"),
                _buildSection(
                  "Our app is not intended for users under 13 years of age. We do not knowingly collect personal data from children. If we become aware that a child’s information has been collected, we will take steps to delete it.",
                ),
                _buildTitle("Changes to This Privacy Policy"),
                _buildSection(
                  "We may update this Privacy Policy periodically to reflect changes in our practices or legal requirements. Any updates will be posted in the app, and we may notify you via email or other means. Continued use of our services after updates constitutes acceptance of the revised policy.",
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
