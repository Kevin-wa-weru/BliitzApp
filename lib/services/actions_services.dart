import 'package:bliitz/utils/misc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class ActionServices {
  Future<Set<String>> fetchFavorites();
  Future<void> addFavorite({required String linkId, required String creatorId});
  Future<void> removeFavorite(
      {required String linkId, required String creatorId});
  Future<void> syncFavoritesWithBackend();

  Future<Set<String>> fetchLikedLinks();
  Future<void> addLikedLinks(String linkId);
  Future<void> removeLikedLinks(String linkId);
  Future<void> syncLikedLinksWithBackend();

  Future<Set<String>> fetchDisLikedLinks();
  Future<void> addDisLikedLinks(String linkId);
  Future<void> removeDisLikedLinks(String linkId);
  Future<void> syncDisLikedLinksWithBackend();

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
  @override
  Future<Set<String>> fetchFavorites() async {
    Set<String> favoriteLinkIds = {};
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Favorites')
        .get();

    favoriteLinkIds = snapshot.docs.map((doc) => doc.id).toSet();
    return favoriteLinkIds;
  }

  @override
  Future<void> addFavorite(
      {required String linkId, required String creatorId}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Favorites')
        .doc(linkId) // 👈 Use linkId as doc id
        .set({
      'linkId': linkId,
      'addedAt': FieldValue.serverTimestamp(), // optional field
    });

    await ActionServicesImpl().toggleFavoriteCount(
        linkId: linkId, isAdding: true, creatorId: creatorId);
  }

  @override
  Future<void> removeFavorite(
      {required String linkId, required String creatorId}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Favorites')
          .doc(linkId)
          .delete();

      await ActionServicesImpl().toggleFavoriteCount(
          linkId: linkId, isAdding: false, creatorId: creatorId);
    } catch (e) {
      debugPrint('Hoalla $e');
    }
  }

  @override
  Future<void> syncFavoritesWithBackend() async {
    var backendFavourites = await ActionServicesImpl().fetchFavorites();

    var localFavourites = await MiscImpl().getFavoriteLinks();
    final mergedFavourites = {...localFavourites, ...backendFavourites};

    localFavourites = mergedFavourites.toList();

    for (var i in localFavourites) {
      await MiscImpl().addFavorite(i);
    }
  }

  //
  @override
  Future<Set<String>> fetchLikedLinks() async {
    Set<String> likedLinkIds = {};
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Liked')
        .get();

    likedLinkIds = snapshot.docs.map((doc) => doc.id).toSet();
    return likedLinkIds;
  }

  @override
  Future<void> addLikedLinks(String linkId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Liked')
        .doc(linkId) // 👈 Use linkId as doc id
        .set({
      'linkId': linkId,
      'addedAt': FieldValue.serverTimestamp(), // optional field
    });

    await ActionServicesImpl().toggleLikeCount(linkId: linkId, isAdding: true);
  }

  @override
  Future<void> removeLikedLinks(String linkId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Liked')
          .doc(linkId)
          .delete();

      await ActionServicesImpl()
          .toggleLikeCount(linkId: linkId, isAdding: false);
    } catch (e) {
      debugPrint('Hoalla $e');
    }
  }

  @override
  Future<void> syncLikedLinksWithBackend() async {
    var backendLikedLinks = await ActionServicesImpl().fetchLikedLinks();

    var localLikedLinks = await MiscImpl().getLikedLinks();
    final mergedFavourites = {...localLikedLinks, ...backendLikedLinks};

    localLikedLinks = mergedFavourites.toList();

    for (var i in localLikedLinks) {
      await MiscImpl().addLikedLinks(i);
    }
  }

  //
  @override
  Future<Set<String>> fetchDisLikedLinks() async {
    Set<String> dislikedLinkIds = {};
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('DisLiked')
        .get();

    dislikedLinkIds = snapshot.docs.map((doc) => doc.id).toSet();
    return dislikedLinkIds;
  }

  @override
  Future<void> addDisLikedLinks(String linkId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('DisLiked')
        .doc(linkId) // 👈 Use linkId as doc id
        .set({
      'linkId': linkId,
      'addedAt': FieldValue.serverTimestamp(), // optional field
    });

    await ActionServicesImpl()
        .toggleDisLikeCount(linkId: linkId, isAdding: true);
  }

  @override
  Future<void> removeDisLikedLinks(String linkId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('DisLiked')
          .doc(linkId)
          .delete();

      await ActionServicesImpl()
          .toggleDisLikeCount(linkId: linkId, isAdding: false);
    } catch (e) {
      debugPrint('Hoalla $e');
    }
  }

  @override
  Future<void> syncDisLikedLinksWithBackend() async {
    var backendDisLikedLinks = await ActionServicesImpl().fetchDisLikedLinks();

    var localDisLikedLinks = await MiscImpl().getDisLikedLinks();
    final mergedFavourites = {...localDisLikedLinks, ...backendDisLikedLinks};

    localDisLikedLinks = mergedFavourites.toList();

    for (var i in localDisLikedLinks) {
      await MiscImpl().addDisLikedLinks(i);
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
