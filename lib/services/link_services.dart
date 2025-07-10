import 'dart:convert';
import 'dart:io';

import 'package:bliitz/utils/misc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LinkServices {
  Future<bool> uploadAndSaveLink({
    required File imageFile,
    required String social,
    required String name,
    required String link,
    required String linkType,
    required String category,
    required String description,
  });
  Future<List<Map<String, dynamic>>> fetchLinks(bool isUserLinks);
  Future<List<Map<String, dynamic>>> fetchSpecificUserLinks(String userId);
  Future<List<Map<String, dynamic>>> fetchLinksByType(String linkType);
  Future<List<Map<String, dynamic>>> filtertLinksBySocialAndCatgory(
      String category, String socialType);
  Future<List<Map<String, dynamic>>> fetchLinksBySocial(
      String socialType, bool isUserLinks);
  Future<List<Map<String, dynamic>>> fetchLinksByCategory(
      String category, bool isUserLinks);
  Future<List<Map<String, dynamic>>> fetchFavoritedGroups(
      {required String userId});
  Future<List<Map<String, dynamic>>> fetchFavoritedLinksBySocial(
      String socialType);
  Future<List<Map<String, dynamic>>> fetchSpeicifcUserinksBySocial(
      String socialType, String userId);
  Future<bool> deleteLink(String linkId);
  Future<Map<String, dynamic>> updateLink({
    required String linkId, // Document ID of the link
    required File? imageFile,
    required String name,
    required String description,
  });
  Future<List<Map<String, dynamic>>> searchLinks(String query);
  Future<List<Map<String, dynamic>>> fetchSearchSuggestions();
  Future<List<Map<String, dynamic>>> fetchYouMightAlsoLikeLinks({
    required String currentLinkId,
    required String? category,
    required List<dynamic>? searchKeywords,
    required String? uploaderId,
    int limit = 10,
  });

  Future<Map<String, dynamic>?> fetchLinkDetails(String linkId);
  Future<bool> alterLinkScore(
      {required String linkId,
      required bool isIncrement,
      required String planId});
  Future<void> resetUserLinkPromotion(String userId);
  Future<List<Map<String, dynamic>>> fetchUserFeedFromCloud(
      {int limit = 20, required bool fetchFirstSocial});
}

class LinkServicesImpl implements LinkServices {
  @override
  Future<bool> uploadAndSaveLink({
    File? imageFile,
    required String social,
    required String name,
    required String link,
    required String linkType,
    required String category,
    required String description,
  }) async {
    try {
      String? imageUrl;

      List<String> generateSearchKeywords(String text) {
        final List<String> keywords = [];
        for (final word in text.toLowerCase().split(' ')) {
          for (int i = 1; i <= word.length; i++) {
            keywords.add(word.substring(0, i));
          }
        }
        return keywords.toSet().toList(); // remove duplicates
      }

      final keywords = [
        ...generateSearchKeywords(name),
        ...generateSearchKeywords(description),
        ...generateSearchKeywords(category),
        ...generateSearchKeywords(social),
      ];

      // 1. Upload image if available
      if (imageFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');
        await ref.putFile(imageFile);

        // Get the download URL
        imageUrl = await ref.getDownloadURL();
      }

      final prefs = await SharedPreferences.getInstance();
      var verficationpaymentPlanId =
          prefs.getString('verficationpaymentPlanId');

      // 2. Create document in Firestore
      await FirebaseFirestore.instance.collection('Links').add({
        'Social': social,
        'Name': name,
        'Description': description,
        'Link': link,
        'Link Type': linkType,
        'Category': category,
        'Profile Image': imageUrl ?? '', // Empty string if image not provided
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'favourites': 0,
        'searchKeywords': keywords,
        'likes': 0,
        'dislikes': 0,
        'rankingScore': 0,
        'totalImpressions': 0,
        'promoted': verficationpaymentPlanId != null &&
                verficationpaymentPlanId.isNotEmpty
            ? true
            : false,
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({'totalCommunities': FieldValue.increment(1)},
              SetOptions(merge: true));

      final categoryRef =
          FirebaseFirestore.instance.collection('Categories').doc(category);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final categorySnapshot = await transaction.get(categoryRef);

        if (!categorySnapshot.exists) {
          // 👶 First time this category is being used
          if (imageUrl == null || imageUrl.isEmpty) {
            transaction.set(categoryRef, {
              'name': category,
              'linkCount': 1,
            });
          }
          if (imageUrl!.isNotEmpty) {
            transaction.set(categoryRef,
                {'name': category, 'linkCount': 1, 'imageUrl': imageUrl});
          }
        } else {
          // 🛠 Category exists, increment the linkCount

          if (imageUrl == null) {
            transaction.update(categoryRef,
                {'linkCount': FieldValue.increment(1), 'imageUrl': imageUrl});
          } else {
            transaction.update(categoryRef,
                {'linkCount': FieldValue.increment(1), 'imageUrl': imageUrl});
          }
        }
      });

      debugPrint("✅ Link data successfully uploaded to Firestore.");
      return true;
    } catch (e) {
      debugPrint("❌ Failed to upload link: $e");
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLinks(bool isUserLinks) async {
    try {
      if (isUserLinks) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Links')
            .where('createdBy',
                isEqualTo: FirebaseAuth
                    .instance.currentUser?.uid) // Optional: newest first
            .get();
        final links = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // 👈 Add the document ID manually
          return data;
        }).toList();

        debugPrint("✅ Successfully fetched ${links.length} links.");
        return links;
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('Links')
            .orderBy('createdAt', descending: true) // Optional: newest first
            .get();
        final links = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // 👈 Add the document ID manually
          return data;
        }).toList();

        debugPrint("✅ Successfully fetched ${links.length} links.");
        return links;
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSpecificUserLinks(
      String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Links')
          .where('createdBy', isEqualTo: userId) // Optional: newest first
          .get();
      final links = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // 👈 Add the document ID manually
        return data;
      }).toList();

      debugPrint("✅ Successfully fetched ${links.length} links.");
      return links;
    } catch (e) {
      debugPrint("❌ Failed to fetch links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLinksByType(String linkType) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Links')
          .where('Link Type', isEqualTo: linkType) // 👈 Filter by link type
          .get();
      final links = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add the document ID manually
        return data;
      }).toList();

      debugPrint("✅ Successfully fetched ${links.length} '$linkType' links.");
      return links;
    } catch (e) {
      debugPrint("❌ Failed to fetch '$linkType' links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLinksBySocial(
      String socialType, bool isUserLinks) async {
    try {
      if (isUserLinks) {
        final userId = FirebaseAuth.instance.currentUser?.uid;

        final snapshot = await FirebaseFirestore.instance
            .collection('Links')
            .where('Social', isEqualTo: socialType) // 👈 Filter by social type
            .where('createdBy', isEqualTo: userId) // 👈 Filter by user ID
            .get();
        final links = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add the document ID manually
          return data;
        }).toList();

        debugPrint(
            "✅ Successfully fetched ${links.length} '$socialType' links.");
        return links;
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('Links')
            .where('Social', isEqualTo: socialType) // 👈 Filter by link type
            .get();
        final links = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add the document ID manually
          return data;
        }).toList();

        debugPrint(
            "✅ Successfully fetched ${links.length} '$socialType' links.");
        return links;
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch '$socialType' links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSpeicifcUserinksBySocial(
      String socialType, String userId) async {
    try {
      print('Vwalasss ${socialType}');
      final snapshot = await FirebaseFirestore.instance
          .collection('Links')
          .where('Social', isEqualTo: socialType) // 👈 Filter by social type
          .where('createdBy', isEqualTo: userId) // 👈 Filter by user ID
          .get();
      final links = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add the document ID manually
        return data;
      }).toList();

      debugPrint("✅ Successfully fetched ${links.length} '$socialType' links.");
      return links;
    } catch (e) {
      debugPrint("❌ Failed to fetch '$socialType' links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLinksByCategory(
      String category, bool isUserLinks) async {
    try {
      if (isUserLinks) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        final snapshot = await FirebaseFirestore.instance
            .collection('Links')
            .where('Category', isEqualTo: category)
            . // 👈 Filter by link type
            where('createdBy', isEqualTo: userId)
            .get();

        final links = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add the document ID manually
          return data;
        }).toList();

        debugPrint("✅ Successfully fetched ${links.length} '$category' links.");
        return links;
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('Links')
            .where('Category', isEqualTo: category) // 👈 Filter by link type
            .get();

        final links = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add the document ID manually
          return data;
        }).toList();

        debugPrint("✅ Successfully fetched ${links.length} '$category' links.");
        return links;
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch '$category' links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFavoritedGroups(
      {required String userId}) async {
    try {
      // Step 1: Get favorited group IDs
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      late List groupIds = [];
      if (doc.exists && doc.data() != null) {
        if (doc.data()!['favoritesLinks'] == null) {
          return [];
        } else {
          groupIds = doc.data()!['favoritesLinks'];
        }
      }

      // Step 2: Batch fetch group details using `whereIn` (max 30 at a time)
      final groups = <Map<String, dynamic>>[];
      final groupsRef = FirebaseFirestore.instance.collection('Links');

      const batchSize = 10;
      for (int i = 0; i < groupIds.length; i += batchSize) {
        final batchIds = groupIds.skip(i).take(batchSize).toList();
        final batchSnapshot = await groupsRef
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        for (final doc in batchSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          groups.add(data);
        }
      }

      return groups;
    } catch (e) {
      debugPrint("❌ Error fetching favorited groups: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFavoritedLinksBySocial(
      String socialType) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    try {
      // Step 1: Get favorited group IDs
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      late List favLinkIds = [];
      if (doc.exists && doc.data() != null) {
        if (doc.data()!['favoritesLinks'] == null) {
          return [];
        } else {
          favLinkIds = doc.data()!['favoritesLinks'];
        }
      }

      // Step 2: Fetch Links by ID (in batches of 10–30)
      const batchSize = 10;
      final links = <Map<String, dynamic>>[];

      for (int i = 0; i < favLinkIds.length; i += batchSize) {
        final batchIds = favLinkIds.skip(i).take(batchSize).toList();
        final batchSnapshot = await FirebaseFirestore.instance
            .collection('Links')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        for (final doc in batchSnapshot.docs) {
          final data = doc.data();
          if (data['Social'] == socialType) {
            data['id'] = doc.id;
            links.add(data);
          }
        }
      }

      return links;
    } catch (e) {
      debugPrint("❌ Error fetching favorited links by social: $e");
      return [];
    }
  }

  @override
  Future<bool> deleteLink(String linkId) async {
    try {
      final linkDocRef =
          FirebaseFirestore.instance.collection('Links').doc(linkId);

      await linkDocRef.delete();

      debugPrint('✅ Link with ID $linkId deleted successfully.');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete link: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> updateLink({
    required String linkId, // Document ID of the link
    required File? imageFile,
    required String name,
    required String description,
  }) async {
    try {
      final linkRef =
          FirebaseFirestore.instance.collection('Links').doc(linkId);

      String? imageUrl;

      // Step 1: Upload image if available
      if (imageFile != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('link_images/$linkId.jpg');

        final uploadTask = await storageRef.putFile(imageFile);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Step 2: Update link document
      final updateData = {
        'Name': name,
        'Description': description,
        if (imageUrl != null) 'Profile Image': imageUrl,
      };

      await linkRef.update(updateData);

      debugPrint('✅ Link updated successfully.');
      return {'success': true, 'imageUrl': imageUrl};
    } catch (e) {
      debugPrint('❌ Failed to update link: $e');
      return {
        'success': true,
        'imageUrl': '',
      };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> filtertLinksBySocialAndCatgory(
      String category, String socialType) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Links')
          .where('Category', isEqualTo: category) // 👈 Filter by link type
          .where('Social', isEqualTo: socialType)
          .get();
      final links = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add the document ID manually
        return data;
      }).toList();

      debugPrint("✅ Successfully fetched ${links.length} '$socialType' links.");
      return links;
    } catch (e) {
      debugPrint("❌ Failed to fetch '$socialType' links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchLinks(String query) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Links')
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .get();
      final links = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      return links;
    } catch (e) {
      debugPrint("❌ Failed to fetch search links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSearchSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searchedJson = prefs.getStringList('searched_links') ?? [];
      final searchedIds =
          searchedJson.map((e) => json.decode(e)['id'].toString()).toSet();
      final searchedLinkIds =
          searchedIds.map((e) => json.decode(e)['id'].toString()).toList();
      final callable =
          FirebaseFunctions.instance.httpsCallable('fetchSearchSuggestions');

      final favoritedLinks = await MiscImpl().getFavoriteLinks();

      final result = await callable.call({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'searchedLinkIds': searchedLinkIds, // List<String>
        'favoriteLinkIds': favoritedLinks,
      });

      final List<Map<String, dynamic>> links = (result.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return links;
    } catch (e) {
      debugPrint("❌ Failed to fetch search links: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchYouMightAlsoLikeLinks({
    required String currentLinkId,
    required String? category,
    required List<dynamic>? searchKeywords,
    required String? uploaderId,
    int limit = 10,
  }) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('fetchYouMightAlsoLikeLinks');

      final response = await callable.call({
        // 'currentLinkId': currentLinkId,
        'category': category,
        'searchKeywords': searchKeywords,
        'limit': limit,
        // 'creatorId': uploaderId
      });

      final List<Map<String, dynamic>> links = (response.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      debugPrint('✅ Might Like Links: $links $category');
      return links;
    } catch (e) {
      debugPrint('❌ Error calling cloud function: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserFeedFromCloud(
      {int limit = 20, required bool fetchFirstSocial}) async {
    try {
      final likedLInks = await MiscImpl().getLikedLinks();
      final favoritedLinks = await MiscImpl().getFavoriteLinks();

      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('fetchUserPersonalizedFeed');
      final result = await callable.call({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'likedLinkIds': likedLInks, // Set<String> or List<String>
        'favoriteLinkIds': favoritedLinks,
        'limit': limit
      });

      // Return the list from the function
      final List<dynamic> data = result.data;

      if (fetchFirstSocial) {
        final List<dynamic> facebookSocials =
            data.where((element) => element['Social'] == "Facebook").toList();
        return facebookSocials
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error calling cloud function: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchLinkDetails(String linkId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Links')
          .doc(linkId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          return {
            'id': docSnapshot.id,
            ...data,
          };
        }
      }

      return null; // Document does not exist or has no data
    } catch (e) {
      debugPrint('❌ Error fetching link details: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<bool> alterLinkScore(
      {required String linkId,
      required bool isIncrement,
      required String planId}) async {
    try {
      // ignore: unused_local_variable
      const Set<String> kProductIds = {
        'upgrade_minimal',
        'upgrade_basic',
        'upgrade_essential',
        'upgrade_premium',
        'subscribe_minimal',
        'subscribe_basic',
        'subscribe_essential',
        'subscribe_premium',
      };
      if (isIncrement) {
        if (planId.contains('minimal')) {
          FirebaseFirestore.instance.collection('Links').doc(linkId).update({
            'promoted': true,
            'rankingScore': 1,
          });
        }
        if (planId.contains('basic')) {
          FirebaseFirestore.instance.collection('Links').doc(linkId).update({
            'promoted': true,
            'rankingScore': 2,
          });
        }
        if (planId.contains('essential')) {
          FirebaseFirestore.instance.collection('Links').doc(linkId).update({
            'promoted': true,
            'rankingScore': 3,
          });
        }
        if (planId.contains('premium')) {
          FirebaseFirestore.instance.collection('Links').doc(linkId).update({
            'promoted': true,
            'rankingScore': 4,
          });
        }
      }
      if (!isIncrement) {
        FirebaseFirestore.instance.collection('Links').doc(linkId).update({
          'promoted': false,
          'rankingScore': 0,
        });
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error raising link score');
      return false;
    }
  }

  @override
  Future<void> resetUserLinkPromotion(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore
          .collection('Links')
          .where('createdBy', isEqualTo: userId)
          .get();

      final batch = firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'promoted': false,
          'rankingScore': 0,
        });
      }

      await batch.commit();
      debugPrint('Successfully updated ${querySnapshot.docs.length} links.');
    } catch (e) {
      debugPrint('Error updating links: $e');
    }
  }
}

extension ListChunk<T> on List<T> {
  List<List<T>> sliced(int size) {
    List<List<T>> chunks = [];
    for (var i = 0; i < length; i += size) {
      int end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}
