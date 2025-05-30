// ignore_for_file: deprecated_member_use

import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Row(
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
                          "About Bliitz LLC",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 20,
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
            ),
            Column(
              children: [
                _buildSection(
                  "Welcome to Bliitz LLC, where finding and connecting with online communities has never been easier. Founded on October 27, 2024, our platform is designed to help users effortlessly discover groups, channels, and pages with just the search of a button.",
                ),
                _buildSection(
                  "Whether you're looking for communities that match your interests, trending discussions, or exclusive content, Bliitz simplifies the process with smart recommendations and an intuitive search system.",
                ),
                _buildTitle("Why Bliitz?"),
                _buildSection(
                  "What sets Bliitz apart is our commitment to simplicity and efficiency. With a clean, user-friendly interface, our app ensures that users can navigate and find what they need without any hassle.",
                ),
                _buildSection(
                  "We prioritize a seamless experience, ensuring that anyone—regardless of technical expertise—can enjoy the benefits of our platform.",
                ),
                _buildTitle("Our Commitment to Safety"),
                _buildSection(
                  "At Bliitz LLC, we maintain strict content policies to ensure a safe and authentic environment. We do not allow the sharing of pornographic content or impersonation, protecting users from harmful or misleading experiences.",
                ),
                _buildSection(
                  "Our goal is to build a trustworthy space where people can find and engage with communities that truly matter to them.",
                ),
                _buildTitle("Looking Ahead"),
                _buildSection(
                  "As we continue to grow, our focus remains on innovation, security, and user satisfaction. We are constantly improving our platform to provide better recommendations, faster searches, and enhanced features that make discovering online communities easier than ever.",
                ),
                _buildTitle("Contact Us"),
                _buildSection(
                  "For support, inquiries, or partnership opportunities, feel free to contact us:\n\n~ contact.bliitzco@yahoo.com",
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
