// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();

  late AnimationController _glowControllerOne;
  late Animation<Color?> _glowAnimationOne;

  @override
  void initState() {
    super.initState();

    _glowControllerOne = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationOne = ColorTween(
      begin: Colors.white.withOpacity(.8),
      end: Colors.white,
    ).animate(_glowControllerOne);
  }

  handleForm() async {
    if (_textController.text.isEmpty) {
      _glowControllerOne.forward().then((_) {
        _glowControllerOne.reverse();
      });
    }

    if (_textController.text.isNotEmpty) {
      Future<bool> uploaded =
          AuthServicesImpl().sendSupportRequest(_textController.text);

      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: const AlertDialog(
              backgroundColor: Colors.transparent,
              content: EqualizerLoader(color: Color(0xE601DE27))),
        ),
      );
      if (await uploaded) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your feedback has been received')));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('An Error Ocurred')));
      }
    }
  }

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
            Stack(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Support',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                  animation: _glowAnimationOne,
                  builder: (context, child) {
                    return TextField(
                      controller: _textController,
                      maxLines: 10,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Write message...',
                        hintStyle: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.4,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: .2),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide(
                            color: _glowAnimationOne.value!,
                            width: .2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(
                            color: _glowAnimationOne.value!,
                            width: .2,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                handleForm();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xCC01DE27),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Text(
                  'Send',
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
            ),
            const SizedBox(
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Text(
                "We value your Feedback ✨\n"
                "Your thoughts and suggestions mean the world to us! Whether you have ideas for improvement, found and issue, or just want to share your experience, we're all ears "
                "How can we make this app better for you? Drop you feedback above, and we'll do our best tomake your experience even better",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontFamily: 'Questrial',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  height: 1.2,
                  decorationColor: Colors.white.withOpacity(0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
