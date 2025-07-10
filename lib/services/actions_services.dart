import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class ActionServices {
  // Future<Map<String, Set<String>>> fetchUserLinkStatuses();

  // Future<void> syncUserLinkActionsWithBackend();

  Future<void> addFavorite({required String linkId, required String creatorId});
  Future<void> removeFavorite(
      {required String linkId, required String creatorId});

  Future<void> addLikedLinks(String linkId);
  Future<void> removeLikedLinks(String linkId);

  Future<void> addDisLikedLinks(String linkId);
  Future<void> removeDisLikedLinks(String linkId);

  Future<void> toggleFavoriteCount({
    required String linkId,
    required bool isAdding,
    required String creatorId,
  });

  Future<void> toggleLikeCount({
    required String linkId,
    required bool isAdding,
  });

  Future<void> toggleDisLikeCount({
    required String linkId,
    required bool isAdding,
  });

  Future<bool> reportAccount({
    required String reportedUserId,
    required String issueMessage,
  });

  Future<bool> sendNotifications({
    required String title,
    required String message,
  });
}

class ActionServicesImpl implements ActionServices {
  // @override
  // Future<Map<String, Set<String>>> fetchUserLinkStatuses() async {
  //   final userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId == null) return {};

  //   final docSnapshot =
  //       await FirebaseFirestore.instance.collection('Users').doc(userId).get();

  //   final data = docSnapshot.data();
  //   if (data == null) return {};

  //   return {
  //     'likedLinks': Set<String>.from(data['liked'] ?? []),
  //     'favoritedLinks': Set<String>.from(data['favorites'] ?? []),
  //     'dislikedLinks': Set<String>.from(data['disliked'] ?? []),
  //   };
  // }

  @override
  Future<void> addFavorite(
      {required String linkId, required String creatorId}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;
    final userDocRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);

    await userDocRef.set({
      'favoritesLinks': FieldValue.arrayUnion([linkId]),
    }, SetOptions(merge: true)); // merge keeps existing fields

    await ActionServicesImpl().toggleFavoriteCount(
        linkId: linkId, isAdding: true, creatorId: creatorId);
  }

  @override
  Future<void> removeFavorite(
      {required String linkId, required String creatorId}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      await userDocRef.update({
        'favoritesLinks': FieldValue.arrayRemove([linkId]),
      });

      await ActionServicesImpl().toggleFavoriteCount(
          linkId: linkId, isAdding: false, creatorId: creatorId);
    } catch (e) {
      debugPrint('Hoalla $e');
    }
  }

//   @override
//   Future<void> syncUserLinkActionsWithBackend() async {
//     final linkStatusMap = await ActionServicesImpl().fetchUserLinkStatuses();

//     final backendLikedLinks = linkStatusMap['liked'] ?? {};
//     final backendFavourites = linkStatusMap['favorites'] ?? {};
//     final backendDisLikedLinks = linkStatusMap['disliked'] ?? {};

// //sync Favorites With Backend
//     var localFavourites = await MiscImpl().getFavoriteLinks();
//     final mergedFavourites = {...localFavourites, ...backendFavourites};

//     localFavourites = mergedFavourites.toList();

//     for (var i in localFavourites) {
//       await MiscImpl().addFavorite(i);
//     }
// //sync Liked Links With Backend
//     var localLikedLinks = await MiscImpl().getLikedLinks();
//     final mergedLikedLinks = {...localLikedLinks, ...backendLikedLinks};

//     localLikedLinks = mergedLikedLinks.toList();

//     for (var i in localLikedLinks) {
//       await MiscImpl().addLikedLinks(i);
//     }
// //sync Disliked With Backend
//     var localDisLikedLinks = await MiscImpl().getDisLikedLinks();
//     final mergedDisLikedLinks = {
//       ...localDisLikedLinks,
//       ...backendDisLikedLinks
//     };

//     localDisLikedLinks = mergedDisLikedLinks.toList();

//     for (var i in localDisLikedLinks) {
//       await MiscImpl().addDisLikedLinks(i);
//     }
//   }

  @override
  Future<void> addLikedLinks(String linkId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;
    final userDocRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);

    await userDocRef.set({
      'likedLinks': FieldValue.arrayUnion([linkId]),
    }, SetOptions(merge: true)); // merge keeps existing fields

    await ActionServicesImpl().toggleLikeCount(linkId: linkId, isAdding: true);
  }

  @override
  Future<void> removeLikedLinks(String linkId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      await userDocRef.update({
        'likedLinks': FieldValue.arrayRemove([linkId]),
      });

      await ActionServicesImpl()
          .toggleLikeCount(linkId: linkId, isAdding: false);
    } catch (e) {
      debugPrint('Hoalla $e');
    }
  }

  @override
  Future<void> addDisLikedLinks(String linkId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final userDocRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);

    await userDocRef.set({
      'dislikedLinks': FieldValue.arrayUnion([linkId]),
    }, SetOptions(merge: true)); // merge keeps existing fields
  }

  @override
  Future<void> removeDisLikedLinks(String linkId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      await userDocRef.update({
        'dislikedLinks': FieldValue.arrayRemove([linkId]),
      });

      await ActionServicesImpl()
          .toggleDisLikeCount(linkId: linkId, isAdding: false);
    } catch (e) {
      debugPrint('Hoalla $e');
    }
  }

  @override
  Future<void> toggleFavoriteCount({
    required String linkId,
    required bool isAdding,
    required String creatorId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final linkRef = FirebaseFirestore.instance.collection('Links').doc(linkId);
    final snapshot = await linkRef.get();
    final currentCount = snapshot.get('favourites') ?? 0;

    try {
      if (isAdding) {
        // Increment favorites count on the link
        await linkRef.update({'favourites': FieldValue.increment(1)});
        debugPrint('✅ Link added to favorites and count incremented.');
        await FirebaseFirestore.instance.collection('Users').doc(creatorId).set(
            {'totalFavorites': FieldValue.increment(1)},
            SetOptions(merge: true));
      } else {
        if (currentCount > 0) {
          await linkRef.update({'favourites': FieldValue.increment(-1)});
          debugPrint('✅ Link removed from favorites and count decremented.');
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(creatorId)
              .set({'totalFavorites': FieldValue.increment(-1)},
                  SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to toggle favorite: $e');
    }
  }

  @override
  Future<void> toggleLikeCount({
    required String linkId,
    required bool isAdding,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final linkRef = FirebaseFirestore.instance.collection('Links').doc(linkId);
    final snapshot = await linkRef.get();
    final currentCount = snapshot.get('favourites') ?? 0;

    try {
      if (isAdding) {
        // Increment favorites count on the link
        await linkRef.update({'likes': FieldValue.increment(1)});
        debugPrint('✅ Link added to favorites and count incremented.');
      } else {
        if (currentCount > 0) {
          await linkRef.update({'likes': FieldValue.increment(-1)});
          debugPrint('✅ Link removed from favorites and count decremented.');
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to toggle favorite: $e');
    }
  }

  @override
  Future<void> toggleDisLikeCount({
    required String linkId,
    required bool isAdding,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final linkRef = FirebaseFirestore.instance.collection('Links').doc(linkId);
    final snapshot = await linkRef.get();
    final currentCount = snapshot.get('favourites') ?? 0;
    try {
      if (isAdding) {
        // Increment favorites count on the link
        await linkRef.update({'dislikes': FieldValue.increment(1)});
        debugPrint('✅ Link added to favorites and count incremented.');
      } else {
        if (currentCount > 0) {
          await linkRef.update({'dislikes': FieldValue.increment(-1)});
          debugPrint('✅ Link removed from favorites and count decremented.');
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to toggle favorite: $e');
    }
  }

  @override
  Future<bool> reportAccount({
    required String reportedUserId,
    required String issueMessage,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated.');
      }

      final reportData = {
        'reportedUserId': reportedUserId,
        'reportedBy': currentUser.uid,
        'message': issueMessage,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('AccountReports')
          .add(reportData);
      debugPrint('✅ Repoerted user suuccessfully:');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to report user: $e');
      return false;
    }
  }

  @override
  Future<bool> sendNotifications({
    required String title,
    required String message,
  }) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('sendNotificationToAll')
          .call({'title': title, 'message': message});

      debugPrint('✅ Sent notifications suuccessfully: ${result.data}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to send Notification: $e');
      return false;
    }
  }
}
