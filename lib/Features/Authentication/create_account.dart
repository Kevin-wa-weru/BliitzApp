// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:ui';

// import 'package:bliitz/Features/HomeScreen/home_screen.dart';
// import 'package:bliitz/Features/Policy%20Documents/privacy_policy_page.dart';
// import 'package:bliitz/services/auth_services.dart';
// import 'package:bliitz/Features/Policy%20Documents/terms_condtions_page.dart';
// import 'package:bliitz/utils/_index.dart';
// import 'package:bliitz/utils/check_internet.dart';
// import 'package:bliitz/utils/misc.dart';
// import 'package:bliitz/widgets/custom_loader.dart';
// import 'package:bliitz/widgets/type_writer_text.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SignUp extends StatefulWidget {
//   const SignUp({super.key});

//   @override
//   State<SignUp> createState() => _SignUpState();
// }

// class _SignUpState extends State<SignUp>
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   final ValueNotifier<bool> _rebuildFields = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _allFieldsFilled = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _isObscuredOne = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _isObscuredTwo = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _isObscuredThre = ValueNotifier<bool>(true);
//   final ValueNotifier<bool> _isObscuredFour = ValueNotifier<bool>(true);
//   final ValueNotifier<bool> _emailIsInvalid = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _passwordHasIssue = ValueNotifier<bool>(false);
//   final ValueNotifier<String> _passwordIssueMessage = ValueNotifier<String>('');
//   final ValueNotifier<double> _opacity = ValueNotifier<double>(0.0);
//   final ValueNotifier<bool> isChecked = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> isVerifying = ValueNotifier(false);
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordOneController = TextEditingController();
//   final TextEditingController _passwordTwoController = TextEditingController();

//   late AnimationController _glowControllerOne;
//   late Animation<Color?> _glowAnimationOne;
//   late Animation<double> _borderWidthAnimationOne;

//   late AnimationController _glowControllerTwo;
//   late Animation<Color?> _glowAnimationTwo;
//   late Animation<double> _borderWidthAnimationTwo;

//   late AnimationController _glowControllerThree;
//   late Animation<Color?> _glowAnimationThree;
//   late Animation<double> _borderWidthAnimationThree;

//   late AnimationController _glowControllerFour;
//   late Animation<Color?> _glowAnimationFour;
//   late Animation<double> _borderWidthAnimationFour;

//   late AnimationController _termsController;
//   late Animation<double> _shakeAnimation;

//   bool validateCheckbox = false;

//   ValueNotifier<int> resendCooldown = ValueNotifier<int>(30);
//   Timer? _resendTimer;

//   void startResendCooldown() {
//     resendCooldown.value = 30;
//     _resendTimer?.cancel();
//     _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendCooldown.value > 0) {
//         resendCooldown.value--;
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void showVerificationDialog(BuildContext context, String email) {
//     final ValueNotifier<bool> showVerifyButton = ValueNotifier<bool>(false);
//     final ValueNotifier<bool> showMessage = ValueNotifier(false);
//     final ValueNotifier<String> extraMessage = ValueNotifier('');
//     startResendCooldown();
//     Future.delayed(const Duration(seconds: 0), () {
//       showVerifyButton.value = true;
//     });
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//         child: WillPopScope(
//           onWillPop: () async => false,
//           child: AlertDialog(
//             backgroundColor: Colors.black,
//             title: Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 16.0),
//                   child: Icon(
//                     Icons.email_outlined,
//                     color: Colors.white.withOpacity(.8),
//                   ),
//                 ),
//                 Text(
//                   "Verify Your Email",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(.8),
//                     fontWeight: FontWeight.w400,
//                     fontFamily: 'Questrial',
//                     letterSpacing: 0.3,
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min, // ⬅️ This is important
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(.6),
//                         fontWeight: FontWeight.w400,
//                         fontFamily: 'Questrial',
//                         letterSpacing: 0.3,
//                         height: 1.5,
//                       ),
//                       children: [
//                         const TextSpan(
//                             text: "A verification link has been sent to "),
//                         TextSpan(
//                           text: email,
//                           style: TextStyle(
//                             color: const Color(0xFF01de27).withOpacity(.6),
//                           ),
//                         ),
//                         const TextSpan(
//                           text:
//                               ". Please check your inbox and follow the instructions to verify your email.",
//                         ),
//                       ],
//                     ),
//                   ),
//                   ValueListenableBuilder<String>(
//                       valueListenable: extraMessage,
//                       builder: (context, extraMsg, child) {
//                         return ValueListenableBuilder<bool>(
//                             valueListenable: showMessage,
//                             builder: (context, shwMsg, child) {
//                               return shwMsg
//                                   ? const SizedBox.shrink()
//                                   : Column(
//                                       children: [
//                                         const SizedBox(
//                                           height: 8,
//                                         ),
//                                         Row(
//                                           children: [
//                                             TypewriterText(
//                                               message: extraMsg,
//                                               trigger: showMessage,
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     );
//                             });
//                       })
//                 ],
//               ),
//             ),
//             actions: [
//               ValueListenableBuilder<bool>(
//                 valueListenable: showVerifyButton,
//                 builder: (context, value, _) {
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (value)
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               onPressed: () async {
//                                 showMessage.value = true;
//                                 extraMessage.value = 'Checking...';

//                                 final isVerified = await AuthServicesImpl()
//                                     .checkEmailVerified();

//                                 if (isVerified && mounted) {
//                                   Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (_) => const HomeScreen()),
//                                   );
//                                 }
//                                 if (!isVerified) {
//                                   showMessage.value = true;
//                                   extraMessage.value =
//                                       'Email has not yet been verified';
//                                 }
//                               },
//                               child: const Text(
//                                 "Click here once verified",
//                                 style: TextStyle(
//                                   color: Color(0xFF01de27),
//                                   fontWeight: FontWeight.w400,
//                                   fontFamily: 'Questrial',
//                                   letterSpacing: 0.3,
//                                   height: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       const SizedBox(
//                         height: 8,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           ValueListenableBuilder<int>(
//                               valueListenable: resendCooldown,
//                               builder: (context, value, _) {
//                                 final isDisabled = value > 0;
//                                 return GestureDetector(
//                                   onTap: isDisabled
//                                       ? null
//                                       : () {
//                                           AuthServicesImpl()
//                                               .sendEmailVerification();
//                                           startResendCooldown();
//                                           showMessage.value = true;
//                                           extraMessage.value =
//                                               'Link has been resent.';
//                                         },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: isDisabled
//                                           ? const Color(0xFF01de27)
//                                               .withOpacity(.1)
//                                           : const Color(0xFF01de27)
//                                               .withOpacity(.2),
//                                       borderRadius: BorderRadius.circular(25.0),
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 16.0, vertical: 8),
//                                       child: Text(
//                                         isDisabled
//                                             ? 'Resend in $value sec'
//                                             : "Resend link ",
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(.6),
//                                           fontWeight: FontWeight.w400,
//                                           fontFamily: 'Questrial',
//                                           letterSpacing: 0.3,
//                                           height: 1.5,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _checkEmailVerification() async {
//     bool isConnected = await ConnectivityHelper.isConnected();
//     if (!isConnected) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           backgroundColor: Colors.black,
//           title: Text(
//             "No Internet Connection",
//             style: TextStyle(
//               color: Colors.white.withOpacity(.8),
//               fontWeight: FontWeight.w400,
//               fontFamily: 'Questrial',
//               letterSpacing: 0.3,
//               height: 1.5,
//             ),
//           ),
//           content: Text(
//             "Please check your internet connection and try again.",
//             style: TextStyle(
//               color: Colors.white.withOpacity(.6),
//               fontWeight: FontWeight.w400,
//               fontFamily: 'Questrial',
//               letterSpacing: 0.3,
//               height: 1.5,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     isVerifying.value = true;

//     final isVerified = await AuthServicesImpl().checkEmailVerified();

//     if (isVerified && mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     }

//     isVerifying.value = false;
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _opacity.value = 0.2;
//     });
//     _glowControllerOne = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _glowAnimationOne = ColorTween(
//       begin: Colors.grey,
//       end: Colors.white,
//     ).animate(_glowControllerOne);

//     _borderWidthAnimationOne = Tween<double>(
//       begin: 1.0,
//       end: 2.0,
//     ).animate(_glowControllerOne);

//     //
//     _glowControllerTwo = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _glowAnimationTwo = ColorTween(
//       begin: Colors.grey,
//       end: Colors.white,
//     ).animate(_glowControllerTwo);

//     _borderWidthAnimationTwo = Tween<double>(
//       begin: 1.0,
//       end: 2.0,
//     ).animate(_glowControllerTwo);
//     //

//     _glowControllerThree = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _glowAnimationThree = ColorTween(
//       begin: Colors.grey,
//       end: Colors.white,
//     ).animate(_glowControllerThree);

//     _borderWidthAnimationThree = Tween<double>(
//       begin: 1.0,
//       end: 2.0,
//     ).animate(_glowControllerThree);
//     //
//     _glowControllerFour = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _glowAnimationFour = ColorTween(
//       begin: Colors.grey,
//       end: Colors.white,
//     ).animate(_glowControllerFour);

//     _borderWidthAnimationFour = Tween<double>(
//       begin: 1.0,
//       end: 2.0,
//     ).animate(_glowControllerFour);

//     _termsController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _shakeAnimation = TweenSequence<double>([
//       TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
//       TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
//       TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
//       TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
//     ]).animate(_termsController);
//   }

//   @override
//   void dispose() {
//     _isObscuredOne.dispose();
//     _isObscuredTwo.dispose();
//     _isObscuredThre.dispose();
//     _isObscuredFour.dispose();
//     _opacity.dispose();
//     _usernameController.dispose();
//     _passwordOneController.dispose();
//     _passwordTwoController.dispose();
//     _glowControllerOne.dispose();
//     _glowControllerTwo.dispose();
//     _glowControllerThree.dispose();
//     _glowControllerFour.dispose();
//     _termsController.dispose();
//     _resendTimer?.cancel();
//     resendCooldown.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     _checkEmailVerification();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkEmailVerification();
//     }
//   }

//   Future<void> _handleLogin() async {
//     _rebuildFields.value = !_rebuildFields.value;
//     if (_usernameController.text.isEmpty) {
//       _glowControllerOne.forward().then((_) {
//         _glowControllerOne.reverse();
//       });
//     }

//     if (_emailController.text.isEmpty) {
//       _glowControllerTwo.forward().then((_) {
//         _glowControllerTwo.reverse();
//       });
//     }

//     if (_passwordOneController.text.isEmpty) {
//       _glowControllerThree.forward().then((_) {
//         _glowControllerThree.reverse();
//       });
//     }

//     if (_passwordTwoController.text.isEmpty) {
//       _glowControllerFour.forward().then((_) {
//         _glowControllerFour.reverse();
//       });
//     }

//     if (_emailController.text.isNotEmpty &&
//         !MiscImpl().isValidEmail(_emailController.text)) {
//       _emailIsInvalid.value = true;
//     }

//     if (_emailController.text.isNotEmpty &&
//         MiscImpl().isValidEmail(_emailController.text)) {
//       _emailIsInvalid.value = false;
//     }

//     if (_passwordOneController.text.isNotEmpty &&
//         MiscImpl().validatePassword(_passwordOneController.text) != null) {
//       _passwordHasIssue.value = true;
//       _passwordIssueMessage.value =
//           MiscImpl().validatePassword(_passwordOneController.text)!;
//     }
//     if (_passwordOneController.text.isNotEmpty &&
//         MiscImpl().validatePassword(_passwordOneController.text) == null) {
//       _passwordHasIssue.value = false;
//     }

//     if (_passwordOneController.text.isNotEmpty &&
//         _passwordTwoController.text.isNotEmpty) {
//       if (_passwordOneController.text != _passwordTwoController.text) {
//         _passwordHasIssue.value = true;
//         _passwordIssueMessage.value = 'Passwords don\'t match';
//       }
//     }

//     if (!isChecked.value) {
//       setState(() => validateCheckbox = true);
//       _termsController.forward().then((_) {
//         _termsController.reverse();
//       });
//       return;
//     }

//     final allFieldsFilled = _usernameController.text.isNotEmpty &&
//         _emailController.text.isNotEmpty &&
//         _passwordOneController.text.isNotEmpty &&
//         _passwordTwoController.text.isNotEmpty;

//     final emailValid = MiscImpl().isValidEmail(_emailController.text);
//     final passwordValid =
//         MiscImpl().validatePassword(_passwordOneController.text) == null;
//     final passwordsMatch =
//         _passwordOneController.text == _passwordTwoController.text;

//     final agreedToTerms = isChecked.value;

//     if (allFieldsFilled &&
//         emailValid &&
//         passwordValid &&
//         passwordsMatch &&
//         agreedToTerms) {
//       // ✅ All good, proceed with registration
//       _allFieldsFilled.value = true;
//       _isLoading.value = true;

//       final error = await AuthServicesImpl().registerUser(
//           name: _usernameController.text.trim(),
//           email: _emailController.text.trim(),
//           password: _passwordOneController.text.trim());

//       if (error == null) {
//         // Navigate or show success
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user_name', _usernameController.text.trim());
//         await prefs.setString('user_email', _emailController.text.trim());
//         await prefs.setString(
//             'user_password', _passwordOneController.text.trim());
//         await prefs.setBool('email_verified', false);
//         String? email = prefs.getString('user_email');
//         _isLoading.value = false;

//         showVerificationDialog(context, email!);
//       } else {
//         // Show error
//         _isLoading.value = false;
//         _allFieldsFilled.value = false;
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(error)));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Column(
//             children: [
//               const SizedBox(height: 60),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Container(
//                       height: Adapt.px(80),
//                       width: Adapt.px(80),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(.08),
//                         borderRadius: const BorderRadius.all(
//                           Radius.circular(100.0),
//                         ),
//                       ),
//                       child: const Center(
//                         child: Icon(
//                           Icons.arrow_back,
//                           color: Colors.white60,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // const SizedBox(height: 10),
//               Text(
//                 'Sign Up',
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 24,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: -0.5,
//                   height: 1.3,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               _buildTextField(
//                 hintText: "Name",
//                 isObscured: _isObscuredOne,
//                 controller: _usernameController,
//                 glowController: _glowControllerOne,
//                 borderWidthAnimation: _borderWidthAnimationOne,
//                 glowAnimation: _glowAnimationOne,
//                 keyboardType: TextInputType.name,
//                 emailInvalid: _emailIsInvalid,
//                 passwordInvalid: _passwordHasIssue,
//                 passwordIssueMessage: _passwordIssueMessage,
//                 rebuildFields: _rebuildFields,
//                 allFieldsFilled: _allFieldsFilled,
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(
//                 hintText: "Email",
//                 isObscured: _isObscuredTwo,
//                 controller: _emailController,
//                 glowController: _glowControllerTwo,
//                 borderWidthAnimation: _borderWidthAnimationTwo,
//                 glowAnimation: _glowAnimationTwo,
//                 keyboardType: TextInputType.emailAddress,
//                 emailInvalid: _emailIsInvalid,
//                 passwordInvalid: _passwordHasIssue,
//                 passwordIssueMessage: _passwordIssueMessage,
//                 rebuildFields: _rebuildFields,
//                 allFieldsFilled: _allFieldsFilled,
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(
//                 hintText: "Create Password",
//                 isObscured: _isObscuredThre,
//                 toggleObscured: () {
//                   _isObscuredThre.value = !_isObscuredThre.value;
//                 },
//                 controller: _passwordOneController,
//                 glowController: _glowControllerThree,
//                 borderWidthAnimation: _borderWidthAnimationThree,
//                 glowAnimation: _glowAnimationThree,
//                 keyboardType: TextInputType.name,
//                 emailInvalid: _emailIsInvalid,
//                 passwordInvalid: _passwordHasIssue,
//                 passwordIssueMessage: _passwordIssueMessage,
//                 rebuildFields: _rebuildFields,
//                 allFieldsFilled: _allFieldsFilled,
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(
//                 hintText: "Confirm Password",
//                 isObscured: _isObscuredFour,
//                 toggleObscured: () {
//                   _isObscuredFour.value = !_isObscuredFour.value;
//                 },
//                 controller: _passwordTwoController,
//                 glowController: _glowControllerFour,
//                 borderWidthAnimation: _borderWidthAnimationFour,
//                 glowAnimation: _glowAnimationFour,
//                 keyboardType: TextInputType.name,
//                 emailInvalid: _emailIsInvalid,
//                 passwordInvalid: _passwordHasIssue,
//                 passwordIssueMessage: _passwordIssueMessage,
//                 rebuildFields: _rebuildFields,
//                 allFieldsFilled: _allFieldsFilled,
//               ),
//               const SizedBox(height: 10),
//               ValueListenableBuilder<bool>(
//                   valueListenable: _rebuildFields,
//                   builder: (context, rebuildFieds, _) {
//                     return ValueListenableBuilder<bool>(
//                         valueListenable: _passwordHasIssue,
//                         builder: (context, passwordHasIssue, _) {
//                           return ValueListenableBuilder<String>(
//                               valueListenable: _passwordIssueMessage,
//                               builder: (context, passwordIssue, _) {
//                                 return Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     !passwordHasIssue
//                                         ? const SizedBox.shrink()
//                                         : Padding(
//                                             padding: const EdgeInsets.only(
//                                                 right: 8.0),
//                                             child: Text(
//                                               ' $passwordIssue',
//                                               style: const TextStyle(
//                                                 color: Colors.red,
//                                                 fontWeight: FontWeight.w400,
//                                                 fontSize: 12,
//                                                 fontFamily: 'Questrial',
//                                                 letterSpacing: 0.3,
//                                                 height: 1.5,
//                                               ),
//                                             ),
//                                           ),
//                                   ],
//                                 );
//                               });
//                         });
//                   }),
//               const SizedBox(height: 30),
//               AnimatedBuilder(
//                 animation: _shakeAnimation,
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(_shakeAnimation.value, 0),
//                     child: child,
//                   );
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ValueListenableBuilder<bool>(
//                       valueListenable: isChecked,
//                       builder: (context, value, _) {
//                         return Checkbox(
//                           value: value,
//                           onChanged: (newValue) {
//                             isChecked.value = newValue ?? false;
//                           },
//                           activeColor: Colors.green,
//                           checkColor: Colors.white,
//                           splashRadius: 20.0,
//                           materialTapTargetSize:
//                               MaterialTapTargetSize.shrinkWrap,
//                         );
//                       },
//                     ),
//                     RichText(
//                       text: TextSpan(
//                         style: const TextStyle(
//                           fontFamily: 'Questrial',
//                           color: Colors.green,
//                           fontSize: 12,
//                           letterSpacing: 0.3,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: "Agree to the ",
//                             style:
//                                 TextStyle(color: Colors.white.withOpacity(0.6)),
//                           ),
//                           TextSpan(
//                             text: "terms of use",
//                             style: const TextStyle(color: Colors.green),
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           const TermsAndConditions()),
//                                 );
//                               },
//                           ),
//                           TextSpan(
//                             text: " and ",
//                             style:
//                                 TextStyle(color: Colors.white.withOpacity(0.6)),
//                           ),
//                           TextSpan(
//                             text: "privacy policy",
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           const PrivacyPoliciy()),
//                                 );
//                               },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ValueListenableBuilder<bool>(
//                   valueListenable: _isLoading,
//                   builder: (context, appLoading, child) {
//                     return GestureDetector(
//                       onTap: () {
//                         _handleLogin();
//                       },
//                       child: Container(
//                         height: 50.0,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: appLoading
//                               ? const Color(0xFF01de27).withOpacity(.6)
//                               : const Color(0xFF01de27),
//                           borderRadius: BorderRadius.circular(25.0),
//                         ),
//                         child: Center(
//                           child: appLoading
//                               ? const EqualizerLoader(color: Colors.black)
//                               : const Text(
//                                   "Create Account",
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontFamily: 'Questrial',
//                                     fontSize: 14,
//                                     letterSpacing: 0.5,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     );
//                   }),
//               const SizedBox(height: 24), // Final padding at the bottom
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String hintText,
//     VoidCallback? toggleObscured,
//     final FormFieldValidator<String>? validator,
//     required TextEditingController controller,
//     required AnimationController glowController,
//     required Animation<double> borderWidthAnimation,
//     required Animation<Color?> glowAnimation,
//     required TextInputType? keyboardType,
//     required ValueNotifier<bool>? isObscured,
//     required ValueNotifier<bool>? emailInvalid,
//     required ValueNotifier<bool>? passwordInvalid,
//     required ValueNotifier<String>? passwordIssueMessage,
//     required ValueNotifier<bool>? rebuildFields,
//     required ValueNotifier<bool>? allFieldsFilled,
//   }) {
//     Color resolveTextFieldColor(
//         Color glowAnimationColor,
//         bool emailInvalid,
//         bool passWordInvalid,
//         String hintText,
//         TextEditingController fieldController) {
//       if (hintText == 'Name') {
//         if (fieldController.text.isEmpty) {
//           return Colors.grey;
//         } else {
//           return glowAnimationColor;
//         }
//       }

//       if (hintText == 'Email') {
//         if (fieldController.text.isEmpty) {
//           return Colors.grey;
//         } else {
//           if (emailInvalid) {
//             return Colors.red;
//           } else {
//             return glowAnimationColor;
//           }
//         }
//       }

//       if (hintText == 'Create Password') {
//         if (fieldController.text.isEmpty) {
//           return Colors.grey;
//         } else {
//           if (passWordInvalid) {
//             return Colors.red;
//           } else {
//             return glowAnimationColor;
//           }
//         }
//       }

//       if (hintText == 'Confirm Password') {
//         if (fieldController.text.isEmpty) {
//           return Colors.grey;
//         } else {
//           if (_passwordIssueMessage.value == 'Passwords don\'t match') {
//             return Colors.red;
//           } else {
//             return glowAnimationColor;
//           }
//         }
//       } else {
//         return Colors.grey;
//       }
//     }

//     void resolveOnchange(String hintText, String value) {
//       _rebuildFields.value = !_rebuildFields.value;

//       if (hintText == 'Email') {
//         if (_emailController.text.isNotEmpty &&
//             MiscImpl().isValidEmail(_emailController.text)) {
//           _emailIsInvalid.value = false;
//         }

//         if (_emailController.text.isNotEmpty &&
//             !MiscImpl().isValidEmail(_emailController.text)) {
//           _emailIsInvalid.value = true;
//         }
//       }

//       if (hintText == 'Create Password') {
//         if (_passwordOneController.text.isNotEmpty &&
//             MiscImpl().validatePassword(_passwordOneController.text) != null) {
//           _passwordHasIssue.value = true;
//           _passwordIssueMessage.value =
//               MiscImpl().validatePassword(_passwordOneController.text)!;
//         }
//         if (_passwordOneController.text.isNotEmpty &&
//             MiscImpl().validatePassword(_passwordOneController.text) == null) {
//           _passwordHasIssue.value = false;
//         }
//       }

//       if (hintText == 'Confirm Password') {
//         if (_passwordOneController.text.isNotEmpty &&
//             _passwordTwoController.text.isNotEmpty) {
//           if (_passwordOneController.text == _passwordTwoController.text) {
//             _passwordHasIssue.value = false;
//             _passwordIssueMessage.value = '';
//           }
//         }
//       }
//     }

//     return AnimatedBuilder(
//       animation: glowController,
//       builder: (context, child) {
//         return ValueListenableBuilder<bool>(
//             valueListenable: allFieldsFilled!,
//             builder: (context, allFieldsProvided, child) {
//               return ValueListenableBuilder<bool>(
//                   valueListenable: rebuildFields!,
//                   builder: (context, rebuildField, child) {
//                     return ValueListenableBuilder<bool>(
//                         valueListenable: isObscured!,
//                         builder: (context, obsc, child) {
//                           return ValueListenableBuilder<String>(
//                               valueListenable: passwordIssueMessage!,
//                               builder: (context, passwordMessage, child) {
//                                 return ValueListenableBuilder<bool>(
//                                     valueListenable: passwordInvalid!,
//                                     builder:
//                                         (context, passwordHasIssue, child) {
//                                       return ValueListenableBuilder<bool>(
//                                           valueListenable: emailInvalid!,
//                                           builder:
//                                               (context, emailHasIssue, child) {
//                                             return Stack(
//                                               children: [
//                                                 TextFormField(
//                                                   enabled: !allFieldsProvided,
//                                                   validator: validator,
//                                                   onChanged: (value) {
//                                                     resolveOnchange(
//                                                         hintText, value);
//                                                   },
//                                                   cursorColor:
//                                                       const Color(0xFF01de27),
//                                                   keyboardType: keyboardType,
//                                                   controller: controller,
//                                                   obscureText: obsc,
//                                                   style: TextStyle(
//                                                       color: allFieldsProvided
//                                                           ? Colors.grey
//                                                           : Colors.white),
//                                                   decoration: InputDecoration(
//                                                     hintText: hintText,
//                                                     hintStyle: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w400,
//                                                       fontSize: 14,
//                                                       fontFamily: 'Questrial',
//                                                       color: Colors.white
//                                                           .withOpacity(0.5),
//                                                       letterSpacing: 0.3,
//                                                       height: 1.5,
//                                                     ),
//                                                     contentPadding:
//                                                         const EdgeInsets
//                                                             .symmetric(
//                                                       vertical: 12.0,
//                                                       horizontal: 20.0,
//                                                     ),
//                                                     filled: true,
//                                                     fillColor:
//                                                         Colors.transparent,
//                                                     border: OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               30.0),
//                                                       borderSide:
//                                                           BorderSide.none,
//                                                     ),
//                                                     enabledBorder:
//                                                         OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               30.0),
//                                                       borderSide: BorderSide(
//                                                         color:
//                                                             resolveTextFieldColor(
//                                                           glowAnimation.value!,
//                                                           emailHasIssue,
//                                                           passwordHasIssue,
//                                                           hintText,
//                                                           controller,
//                                                         ),
//                                                         width:
//                                                             borderWidthAnimation
//                                                                 .value,
//                                                       ),
//                                                     ),
//                                                     focusedBorder:
//                                                         OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               30.0),
//                                                       borderSide: BorderSide(
//                                                         color:
//                                                             resolveTextFieldColor(
//                                                           glowAnimation.value!,
//                                                           emailHasIssue,
//                                                           passwordHasIssue,
//                                                           hintText,
//                                                           controller,
//                                                         ),
//                                                         width:
//                                                             borderWidthAnimation
//                                                                 .value,
//                                                       ),
//                                                     ),
//                                                     disabledBorder:
//                                                         OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               30.0),
//                                                       borderSide: BorderSide(
//                                                         color: Colors.grey,
//                                                         width:
//                                                             borderWidthAnimation
//                                                                 .value,
//                                                       ),
//                                                     ),
//                                                     suffixIcon:
//                                                         toggleObscured != null
//                                                             ? IconButton(
//                                                                 icon: Icon(
//                                                                   obsc
//                                                                       ? Icons
//                                                                           .visibility_off
//                                                                       : Icons
//                                                                           .visibility,
//                                                                   color: Colors
//                                                                       .grey,
//                                                                 ),
//                                                                 onPressed:
//                                                                     toggleObscured,
//                                                               )
//                                                             : null,
//                                                   ),
//                                                 ),
//                                                 emailInvalid.value &&
//                                                         hintText == 'Email' &&
//                                                         _emailController
//                                                             .text.isNotEmpty
//                                                     ? const Align(
//                                                         alignment: Alignment
//                                                             .centerRight,
//                                                         child: Padding(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   top: 15.0,
//                                                                   right: 15),
//                                                           child: Padding(
//                                                             padding: EdgeInsets
//                                                                 .symmetric(
//                                                                     horizontal:
//                                                                         2),
//                                                             child: Text(
//                                                               'Invalid email',
//                                                               style: TextStyle(
//                                                                 color:
//                                                                     Colors.red,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w400,
//                                                                 fontSize: 12,
//                                                                 fontFamily:
//                                                                     'Questrial',
//                                                                 letterSpacing:
//                                                                     0.3,
//                                                                 height: 1.5,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       )
//                                                     : const SizedBox.shrink()
//                                               ],
//                                             );
//                                           });
//                                     });
//                               });
//                         });
//                   });
//             });
//       },
//     );
//   }
// }
