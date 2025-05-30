// // ignore_for_file: use_build_context_synchronously

// import 'package:bliitz/auth/create_account.dart';
// import 'package:bliitz/homescreen/home_screen.dart';
// import 'package:bliitz/services/auth_services.dart';
// import 'package:bliitz/utils/misc.dart';
// import 'package:bliitz/widgets/custom_loader.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SignIn extends StatefulWidget {
//   const SignIn({super.key});

//   @override
//   State<SignIn> createState() => _SignInState();
// }

// class _SignInState extends State<SignIn> with TickerProviderStateMixin {
//   final ValueNotifier<bool> _rebuildFields = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _allFieldsFilled = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _isObscured = ValueNotifier<bool>(true);
//   final ValueNotifier<bool> _emailIsInvalid = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _passwordHasIssue = ValueNotifier<bool>(false);
//   final ValueNotifier<String> _passwordIssueMessage = ValueNotifier<String>('');
//   final ValueNotifier<double> _opacity = ValueNotifier<double>(0.0);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   late AnimationController _glowControllerOne;
//   late Animation<Color?> _glowAnimationOne;
//   late Animation<double> _borderWidthAnimationOne;

//   late AnimationController _glowControllerTwo;
//   late Animation<Color?> _glowAnimationTwo;
//   late Animation<double> _borderWidthAnimationTwo;

//   @override
//   void initState() {
//     super.initState();
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
//   }

//   @override
//   void dispose() {
//     _isObscured.dispose();
//     _opacity.dispose();
//     _passwordController.dispose();
//     _emailController.dispose();
//     _glowControllerOne.dispose();
//     _glowControllerTwo.dispose();

//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     _rebuildFields.value = !_rebuildFields.value;

//     if (_emailController.text.isEmpty) {
//       _glowControllerOne.forward().then((_) {
//         _glowControllerOne.reverse();
//       });
//     }

//     if (_passwordController.text.isEmpty) {
//       _glowControllerTwo.forward().then((_) {
//         _glowControllerTwo.reverse();
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

//     if (_passwordController.text.isNotEmpty &&
//         MiscImpl().validatePassword(_passwordController.text) != null) {
//       _passwordHasIssue.value = true;
//       _passwordIssueMessage.value =
//           MiscImpl().validatePassword(_passwordController.text)!;
//     }
//     if (_passwordController.text.isNotEmpty &&
//         MiscImpl().validatePassword(_passwordController.text) == null) {
//       _passwordHasIssue.value = false;
//     }

//     final allFieldsFilled =
//         _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

//     final emailValid = MiscImpl().isValidEmail(_emailController.text);
//     final passwordValid =
//         MiscImpl().validatePassword(_passwordController.text) == null;

//     if (allFieldsFilled && emailValid && passwordValid) {
//       // ✅ All good, proceed with login
//       _allFieldsFilled.value = true;
//       _isLoading.value = true;

//       String result = await AuthServicesImpl().loginWithEmail(
//         _emailController.text.trim(),
//         _passwordController.text.trim(),
//       );

//       if (result == "success") {
//         //  Navigator.push(
//         //     context,
//         //     MaterialPageRoute(builder: (context) => const HomeScreen()),
//         //   );

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user_email', _emailController.text.trim());
//         await prefs.setBool('email_verified', true);
//         _isLoading.value = false;
//         _allFieldsFilled.value = false;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeScreen()),
//         );
//       } else {
//         String errorMessage = "An error occurred. Try again.";
//         if (result == "user-not-found") {
//           errorMessage = "User not found.";
//         } else if (result == "wrong-password")
//           errorMessage = "Wrong password.";
//         else if (result == "email-not-verified") {
//           errorMessage = "Email not verified. Verification email sent.";
//         }
//         _isLoading.value = false;
//         _allFieldsFilled.value = false;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 30.0, right: 30, bottom: 50.0, top: 100),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SvgPicture.asset(
//                         'assets/images/logo.svg',
//                         height: 50,
//                         width: 50,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Login',
//                         style: TextStyle(
//                           fontFamily: 'Poppins',
//                           color: Colors.white.withOpacity(0.8),
//                           fontSize: 24,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: -0.5,
//                           height: 1.3,
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//                       _buildTextField(
//                         hintText: "Email address",
//                         isObscured: _isObscured,
//                         controller: _emailController,
//                         glowController: _glowControllerOne,
//                         borderWidthAnimation: _borderWidthAnimationOne,
//                         glowAnimation: _glowAnimationOne,
//                         keyboardType: TextInputType.emailAddress,
//                         emailInvalid: _emailIsInvalid,
//                         passwordInvalid: _passwordHasIssue,
//                         passwordIssueMessage: _passwordIssueMessage,
//                         rebuildFields: _rebuildFields,
//                         allFieldsFilled: _allFieldsFilled,
//                       ),
//                       const SizedBox(height: 20),
//                       _buildTextField(
//                         hintText: "Password",
//                         isObscured: _isObscured,
//                         toggleObscured: () {
//                           _isObscured.value = !_isObscured.value;
//                         },
//                         controller: _passwordController,
//                         glowController: _glowControllerTwo,
//                         borderWidthAnimation: _borderWidthAnimationTwo,
//                         glowAnimation: _glowAnimationTwo,
//                         keyboardType: TextInputType.name,
//                         emailInvalid: _emailIsInvalid,
//                         passwordInvalid: _passwordHasIssue,
//                         passwordIssueMessage: _passwordIssueMessage,
//                         rebuildFields: _rebuildFields,
//                         allFieldsFilled: _allFieldsFilled,
//                       ),
//                       ValueListenableBuilder<bool>(
//                           valueListenable: _rebuildFields,
//                           builder: (context, rebuildFieds, _) {
//                             return ValueListenableBuilder<bool>(
//                                 valueListenable: _passwordHasIssue,
//                                 builder: (context, passwordHasIssue, _) {
//                                   return ValueListenableBuilder<String>(
//                                       valueListenable: _passwordIssueMessage,
//                                       builder: (context, passwordIssue, _) {
//                                         return Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             passwordHasIssue &&
//                                                     _passwordController
//                                                         .text.isNotEmpty
//                                                 ? Column(
//                                                     children: [
//                                                       const SizedBox(
//                                                           height: 12),
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(
//                                                                 right: 0.0),
//                                                         child: Text(
//                                                           ' $passwordIssue',
//                                                           style:
//                                                               const TextStyle(
//                                                             color: Colors.red,
//                                                             fontWeight:
//                                                                 FontWeight.w400,
//                                                             fontSize: 12,
//                                                             fontFamily:
//                                                                 'Questrial',
//                                                             letterSpacing: 0.3,
//                                                             height: 1.5,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 6),
//                                                     ],
//                                                   )
//                                                 : const SizedBox(height: 12),
//                                           ],
//                                         );
//                                       });
//                                 });
//                           }),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Text(
//                             'Forgot Password?',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.5),
//                               fontWeight: FontWeight.w500,
//                               fontFamily: 'Questrial',
//                               fontSize: 12,
//                               letterSpacing: 0.3,
//                               height: 1.4,
//                               // decoration: TextDecoration.underline,
//                               decorationColor: Colors.white.withOpacity(0.75),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       const SizedBox(height: 40),
//                       _buildLoginButton(_isLoading),
//                       const SizedBox(height: 30),
//                       _buildDivider(),
//                       const SizedBox(height: 30),
//                       _buildGoogleSignUpButton(),
//                       const SizedBox(height: 20),
//                       ValueListenableBuilder<bool>(
//                           valueListenable: _isLoading,
//                           builder: (context, appLoading, child) {
//                             return Opacity(
//                               opacity: appLoading ? .5 : 1,
//                               child: RichText(
//                                 text: TextSpan(
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 14,
//                                       letterSpacing: 0.3,
//                                       fontWeight: FontWeight.w600),
//                                   children: [
//                                     TextSpan(
//                                       text: "Don't have an account? ",
//                                       style: TextStyle(
//                                         fontFamily: 'Questrial',
//                                         color: Colors.white.withOpacity(0.6),
//                                       ),
//                                     ),
//                                     const TextSpan(
//                                       text: "Sign Up",
//                                       style: TextStyle(
//                                         fontFamily: 'Questrial',
//                                         color: Colors.green,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             ValueListenableBuilder<bool>(
//                 valueListenable: _isLoading,
//                 builder: (context, appLoading, child) {
//                   return Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: GestureDetector(
//                       onTap: () {
//                         if (!appLoading) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const SignUp()),
//                           );
//                         }
//                       },
//                       child: Container(
//                         height: 85,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                             colors: [
//                               Colors.black.withOpacity(1),
//                               Colors.black.withOpacity(0),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//           ],
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
//       if (hintText == 'Email address') {
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
//       if (hintText == 'Password') {
//         if (fieldController.text.isEmpty) {
//           return Colors.grey;
//         } else {
//           if (passWordInvalid) {
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
//       if (hintText == 'Email address') {
//         if (_emailController.text.isNotEmpty &&
//             MiscImpl().isValidEmail(_emailController.text)) {
//           _emailIsInvalid.value = false;
//         }

//         if (_emailController.text.isNotEmpty &&
//             !MiscImpl().isValidEmail(_emailController.text)) {
//           _emailIsInvalid.value = true;
//         }
//       }

//       if (hintText == 'Password') {
//         if (_passwordController.text.isNotEmpty &&
//             MiscImpl().validatePassword(_passwordController.text) != null) {
//           _passwordHasIssue.value = true;
//           _passwordIssueMessage.value =
//               MiscImpl().validatePassword(_passwordController.text)!;
//         }
//         if (_passwordController.text.isNotEmpty &&
//             MiscImpl().validatePassword(_passwordController.text) == null) {
//           _passwordHasIssue.value = false;
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
//                                                   obscureText: hintText ==
//                                                           'Email address'
//                                                       ? false
//                                                       : obsc,
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
//                                                         hintText ==
//                                                             'Email address' &&
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

//   Widget _buildLoginButton(
//     ValueNotifier<bool> _isLoading,
//   ) {
//     return InkWell(
//       splashColor: Colors.transparent,
//       onTap: () {
//         _handleLogin();
//       },
//       child: ValueListenableBuilder<bool>(
//           valueListenable: _isLoading,
//           builder: (context, appLoading, child) {
//             return Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 53.0, vertical: 16.0),
//               decoration: BoxDecoration(
//                 color: appLoading
//                     ? const Color(0xFF01de27).withOpacity(.6)
//                     : const Color(0xFF01de27),
//                 borderRadius: BorderRadius.circular(25.0),
//               ),
//               child: appLoading
//                   ? const IntrinsicWidth(
//                       child: SizedBox(
//                           height: 14,
//                           child: EqualizerLoader(color: Colors.black)),
//                     )
//                   : Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontFamily: 'Questrial',
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                         letterSpacing: 0.5,
//                         height: 1.2,
//                         decorationColor: Colors.white.withOpacity(0.75),
//                       ),
//                     ),
//             );
//           }),
//     );
//   }

//   Widget _buildDivider() {
//     return ValueListenableBuilder<bool>(
//         valueListenable: _isLoading,
//         builder: (context, appLoading, child) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Divider(
//                     color: appLoading
//                         ? Colors.white.withOpacity(0.3)
//                         : Colors.white.withOpacity(0.5),
//                     thickness: 1,
//                     endIndent: 10,
//                   ),
//                 ),
//                 Text(
//                   "Or continue with",
//                   style: TextStyle(
//                       fontFamily: 'Questrial',
//                       color: appLoading
//                           ? Colors.white.withOpacity(0.5)
//                           : Colors.white.withOpacity(0.8),
//                       fontSize: 14),
//                 ),
//                 Expanded(
//                   child: Divider(
//                     color: appLoading
//                         ? Colors.white.withOpacity(0.3)
//                         : Colors.white.withOpacity(0.5),
//                     thickness: 1,
//                     indent: 10,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }

//   Widget _buildGoogleSignUpButton() {
//     return ValueListenableBuilder<bool>(
//         valueListenable: _isLoading,
//         builder: (context, appLoading, child) {
//           return GestureDetector(
//             onTap: () async {
//               if (!appLoading) {
//                 try {
//                   final userCredential =
//                       await AuthServicesImpl().signInWithGoogle();
//                   debugPrint(
//                       'Signed in asss: ${userCredential.user?.displayName.toString()}');
//                   final prefs = await SharedPreferences.getInstance();
//                   await prefs.setString(
//                       'user_email', userCredential.user!.email!);
//                   await prefs.setBool('email_verified', true);
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HomeScreen()),
//                   );
//                 } catch (e) {
//                   debugPrint('Error: ${e.toString()}');
//                   ScaffoldMessenger.of(context)
//                       .showSnackBar(SnackBar(content: Text(e.toString())));
//                 }
//               }
//             },
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1E1D1C),
//                 borderRadius: BorderRadius.circular(25.0),
//               ),
//               child: IntrinsicWidth(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Opacity(
//                       opacity: appLoading ? .5 : 1,
//                       child: SvgPicture.asset(
//                         'assets/icons/google.svg',
//                         height: 22,
//                         width: 22,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       "Google",
//                       style: TextStyle(
//                           color: appLoading
//                               ? Colors.white.withOpacity(0.5)
//                               : Colors.white.withOpacity(0.8),
//                           fontSize: 14,
//                           fontFamily: 'Questrial',
//                           letterSpacing: 0.3,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//   }
// }
