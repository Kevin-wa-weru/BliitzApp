// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_pofile_details_cubit.dart';
import 'package:bliitz/services/actions_services.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/_index.dart';

class SendNotifications extends StatefulWidget {
  const SendNotifications({super.key});

  @override
  State<SendNotifications> createState() => _SendNotificationsState();
}

class _SendNotificationsState extends State<SendNotifications>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  late AnimationController _glowControllerOne;
  late Animation<Color?> _glowAnimationOne;

  late AnimationController _glowControllerTwo;
  late Animation<Color?> _glowAnimationTwo;

  @override
  void initState() {
    super.initState();

    _glowControllerOne = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationOne = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(_glowControllerOne);

    _glowControllerTwo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationTwo = ColorTween(
      begin: Colors.white.withOpacity(.4),
      end: Colors.white,
    ).animate(_glowControllerTwo);
  }

  handleForm() async {
    if (_titleController.text.isEmpty) {
      _glowControllerOne.forward().then((_) {
        _glowControllerOne.reverse();
      });
    }

    if (_aboutController.text.isEmpty) {
      _glowControllerTwo.forward().then((_) {
        _glowControllerTwo.reverse();
      });
    }

    if (_titleController.text.isNotEmpty && _aboutController.text.isNotEmpty) {
      Future<bool> uploaded = ActionServicesImpl().sendNotifications(
        title: _titleController.text,
        message: _aboutController.text,
      );

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
            const SnackBar(content: Text('Users have been notified')));
        context.read<GetProfileDetailsCubit>().getProfileDetails(true);
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Send Notifications',
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
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              'Notification title',
              style: TextStyle(
                fontFamily: 'Questrial',
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
                fontSize: 16,
                letterSpacing: 0.25,
                height: 1.5,
                decorationColor: Colors.white.withOpacity(0.75),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                height: 45,
                child: AnimatedBuilder(
                    animation: _glowAnimationOne,
                    builder: (context, child) {
                      return TextField(
                        controller: _titleController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
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
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          fillColor: const Color(0xFF141312),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: .2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide(
                              color: _glowAnimationOne.value!,
                              width: .2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide(
                              color: _glowAnimationOne.value!,
                              width: .2,
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Text(
              'Notification message',
              style: TextStyle(
                fontFamily: 'Questrial',
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
                fontSize: 16,
                letterSpacing: 0.25,
                height: 1.5,
                decorationColor: Colors.white.withOpacity(0.75),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                  animation: _glowAnimationTwo,
                  builder: (context, child) {
                    return TextField(
                      maxLines: 5,
                      controller: _aboutController,
                      maxLength: 100,
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
                            color: _glowAnimationTwo.value!,
                            width: .2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(
                            color: _glowAnimationTwo.value!,
                            width: .2,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 24,
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
          ],
        ),
      ),
    );
  }
}
