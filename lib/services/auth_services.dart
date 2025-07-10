import 'dart:io';

import 'package:bliitz/services/payment_services.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthServices {
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> loginWithFacebook();
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  });
  Future<String> loginWithEmail(String email, String password);
  Future<bool> checkEmailVerified();
  Future<void> sendEmailVerification();
  Future<Map<String, dynamic>?> fetchUserProfile();
  Future<Map<String, dynamic>?> fetchSpecificUserProfile(String userId);
  Future<bool> updateProfile({
    required File? imageFile,
    required String name,
    required String bio,
  });
  Future<bool> sendSupportRequest(String message);
  Future<void> checkAndPersistIfUserIsAdmin();
  Future<bool> isUserAdmin();

  Future<void> updateFcmToken(String token);
  Future<bool> logOut();
  Future<bool> deleteUserAccount();
}

class AuthServicesImpl implements AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final prefs = await SharedPreferences.getInstance();
    if (googleUser == null) {
      throw Exception('Sign-in aborted');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await prefs.setBool('is_loggedIn', true);

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> loginWithFacebook() async {
    final prefs = await SharedPreferences.getInstance();

    final LoginResult result = await FacebookAuth.i.login();

    final accessToken = result.accessToken;

    final facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken!.token);

    final UserCredential userCredential =
        await _auth.signInWithCredential(facebookAuthCredential);

    User? user = userCredential.user;
    debugPrint("Logged in as: ${user?.displayName}");
    await prefs.setBool('is_loggedIn', true);

    return userCredential;
  }

  @override
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      await userCredential.user?.sendEmailVerification();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already in use';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else {
        return 'Registration failed: ${e.message}';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  @override
  Future<String> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null && userCredential.user!.emailVerified) {
        return "success";
      } else {
        // Email not verified
        await userCredential.user!.sendEmailVerification();
        await _auth.signOut();
        return "email-not-verified";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "user-not-found";
      if (e.code == 'wrong-password') return "wrong-password";
      return "error";
    } catch (e) {
      return "error";
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user!.emailVerified) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('email_verified', true);
      }
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ No user logged in.');
        return null;
      }

      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final prefs = await SharedPreferences.getInstance();

        //Persist User stats locally
        await prefs.setString(
            'totalFavorites',
            doc.data()!['totalFavorites'] == null
                ? '0'
                : doc.data()!['totalFavorites'].toString());

        await prefs.setString(
            'totalImpressions',
            doc.data()!['totalImpressions'] == null
                ? '0'
                : doc.data()!['totalImpressions'].toString());

        //Sync backend favourites, likes and disliked links with local ones
        final data = doc.data();
        syncUserLinkActionsWithBackend(linkStatusMap: {
          'likedLinks': Set<String>.from(data!['liked'] ?? []),
          'favoritedLinks': Set<String>.from(data['favorites'] ?? []),
          'dislikedLinks': Set<String>.from(data['disliked'] ?? []),
        });

        //  Initialise Store and get User Payment Services.
        prefs.setString(
          'paymentPlanId',
          doc.data()!['paymentPlanId'],
        );

        await PaymentServicesImpl().initStoreInfo();
        var verified = await PaymentServicesImpl().getActivePurchases(doc: doc);

        return {
          'about': doc.data()!['bio'] as String?,
          'isVerified': verified,
        };
      } else {
        return null; // Bio not set or document missing
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch profile details: $e');
      return null;
    }
  }

  Future<void> syncUserLinkActionsWithBackend({
    required Map<String, Set<String>> linkStatusMap,
  }) async {
    final backendLikedLinks = linkStatusMap['liked'] ?? {};
    final backendFavourites = linkStatusMap['favorites'] ?? {};
    final backendDisLikedLinks = linkStatusMap['disliked'] ?? {};

//sync Favorites With Backend
    var localFavourites = await MiscImpl().getFavoriteLinks();
    final mergedFavourites = {...localFavourites, ...backendFavourites};

    localFavourites = mergedFavourites.toList();

    for (var i in localFavourites) {
      await MiscImpl().addFavorite(i);
    }
//sync Liked Links With Backend
    var localLikedLinks = await MiscImpl().getLikedLinks();
    final mergedLikedLinks = {...localLikedLinks, ...backendLikedLinks};

    localLikedLinks = mergedLikedLinks.toList();

    for (var i in localLikedLinks) {
      await MiscImpl().addLikedLinks(i);
    }
//sync Disliked With Backend
    var localDisLikedLinks = await MiscImpl().getDisLikedLinks();
    final mergedDisLikedLinks = {
      ...localDisLikedLinks,
      ...backendDisLikedLinks
    };

    localDisLikedLinks = mergedDisLikedLinks.toList();

    for (var i in localDisLikedLinks) {
      await MiscImpl().addDisLikedLinks(i);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchSpecificUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return {
          'name': doc.data()!['name'] as String?,
          'about': doc.data()!['bio'] as String?,
          'photoURL': doc.data()!['photoURL'] as String?,
          'verified': doc.data()!['verified'],
          'totalImpressions': doc.data()!['totalImpressions'],
          'totalFavorites': doc.data()!['totalFavorites'],
          'totalCommunities': doc.data()!['totalCommunities'],
        };
      } else {
        return null; // Bio not set or document missing
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch profile details: $e');
      return null;
    }
  }

  @override
  Future<bool> updateProfile({
    required File? imageFile,
    required String name,
    required String bio,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? imageUrl;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      // 1. Upload image if available
      if (imageFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');
        await ref.putFile(imageFile);

        // Get the download URL
        imageUrl = await ref.getDownloadURL();

        await user!.updateDisplayName(name);
        await user.updatePhotoURL(imageUrl);
        await user.reload();
      } else {
        await user!.updateDisplayName(name);
        await user.reload();
      }

      await FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'bio': bio,
      }, SetOptions(merge: true));

      debugPrint("✅ Link data successfully uploaded to Firestore.");
      return true;
    } catch (e) {
      debugPrint("❌ Failed to upload link: $e");
      return false;
    }
  }

  @override
  Future<bool> sendSupportRequest(String message) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      await FirebaseFirestore.instance.collection('Support').add({
        'userId': userId,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Support request sent successfully.");
      return true;
    } catch (e) {
      debugPrint("❌ Failed to send support request: $e");
      return false;
    }
  }

  @override
  Future<void> checkAndPersistIfUserIsAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final adminDoc = await FirebaseFirestore.instance
        .collection('Administrators')
        .doc(currentUser.uid)
        .get();

    final isAdmin =
        adminDoc.exists && adminDoc.data()?['userId'] == currentUser.uid;

    final prefs = await SharedPreferences.getInstance();
    debugPrint('IS ADMIN? $isAdmin');
    await prefs.setBool('is_admin', isAdmin);
  }

  @override
  Future<bool> isUserAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    debugPrint("FCM Token: $token");

    // Save this token in Firestore or your backend to send targeted notifications later
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  @override
  Future<bool> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('is_loggedIn', false);
      return true;
    } catch (e) {
      debugPrint("❌ Failed to LogOut: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteUserAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final uid = user.uid;

    try {
      // Step 1: Delete profile image from Firebase Storage (if it exists)
      final imageRef =
          FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      try {
        await imageRef.delete();
        debugPrint("Profile image deleted.");
      } catch (e) {
        debugPrint("No profile image found or error deleting image: $e");
      }

      // Step 2: Delete user document from Firestore
      await FirebaseFirestore.instance.collection('Users').doc(uid).delete();
      debugPrint("Firestore user document deleted.");

      await reauthenticateUser();
      // Step 3: Delete the user from Firebase Authentication
      await user.delete();
      debugPrint("Firebase user account deleted.");

      return true;
    } catch (e) {
      debugPrint("Error deleting user account: $e");

      return false;
    }
  }

  Future<void> reauthenticateUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) throw Exception("No user is currently signed in.");

    final providerId = user.providerData.first.providerId;

    AuthCredential? credential;

    if (providerId == 'google.com') {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth == null)
        throw Exception("Failed to retrieve Google auth.");

      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } else if (providerId == 'facebook.com') {
      final result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        throw Exception("Facebook login failed: ${result.message}");
      }

      final accessToken = result.accessToken;
      if (accessToken == null)
        throw Exception("No Facebook access token found.");

      credential = FacebookAuthProvider.credential(accessToken.token);
    } else {
      throw Exception("Unsupported provider: $providerId");
    }

    // Reauthenticate
    await user.reauthenticateWithCredential(credential);
    debugPrint("Re-authentication successful.");
  }
}
