const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {google} = require("googleapis");
const path = require("path");


admin.initializeApp();

const androidpublisher = google.androidpublisher("v3");

const serviceAccountPath = path.join(__dirname, "service-account.json");

const auth = new google.auth.GoogleAuth({
  keyFile: serviceAccountPath,
  scopes: ["https://www.googleapis.com/auth/androidpublisher"],
});

const PACKAGE_NAME = "com.bliitz.social";


exports.sendNotificationToAll = functions.https.
    onCall(async (data, context) => {
      const {title, message} = data;

      if (!context.auth) {
        throw new functions.https.
            HttpsError("unauthenticated", "Request had no valid credentials.");
      }

      try {
        const usersSnapshot = await admin.
            firestore().collection("Users").get();
        const tokens = [];

        usersSnapshot.forEach((doc) => {
          const userData = doc.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        });

        if (tokens.length === 0) {
          return {
            success: false,
            message: "No FCM tokens found.",
          };
        }

        const chunkArray = (arr, size) =>
          Array.from({
            length:
            Math.ceil(arr.length / size),
          }, (_, i) =>
            arr.slice(i * size, i * size + size),
          );

        const chunks = chunkArray(tokens, 500);
        const notification = {
          title: title || "Notification",
          body: message || "You have a new update.",
        };
        const dataPayload = {
          type: "broadcast",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        };

        let successCount = 0;
        let failureCount = 0;

        for (const chunk of chunks) {
          const response = await admin.messaging()
              .sendEachForMulticast({
                tokens: chunk,
                notification,
                data: dataPayload,
              });

          response.responses.forEach((res, index) => {
            if (!res.success) {
              const error = res.error;
              console.warn(
                  "Error sending to token", chunk[index], error.message);
              failureCount++;

              if (
                error.code ===
              "messaging/invalid-registration-token" ||
              error.code ===
              "messaging/registration-token-not-registered"
              ) {
                const tokenToRemove = chunk[index];
                const userDoc = usersSnapshot.docs.find(
                    (d) => d.data().fcmToken === tokenToRemove,
                );
                if (userDoc) {
                  admin.firestore().
                      collection("Users").doc(userDoc.id).update({
                        fcmToken: admin.firestore.FieldValue.delete(),
                      });
                }
              }
            } else {
              successCount++;
            }
          });
        }

        return {
          success: true,
          message: `Notification sent to 
      ${successCount} users, ${failureCount} failed.`,
        };
      } catch (error) {
        console.error("Notification error:", error);
        throw new functions.https.
            HttpsError("internal", "Failed to send notifications.");
      }
    });


exports.oauthRedirectHandler = functions.https.
    onRequest((req, res) => {
      console.log("Received data");
      res.status(200).send("Received data");
    });


exports.checkSubscriptionStatus = functions.
    https.onCall(async (data, context) => {
      const {purchaseToken, subscriptionId} = data;

      try {
        const authClient = await auth.getClient();
        const androidpublisher = google.
            androidpublisher({version: "v3", auth: authClient});

        const res = await androidpublisher.
            purchases.subscriptions.get({
              packageName: PACKAGE_NAME,
              subscriptionId,
              token: purchaseToken,
            });

        const subscription = res.data;
        const now = Date.now();
        const expiryTime =
        parseInt(subscription.expiryTimeMillis, 10);
        const isActive = expiryTime > now;

        return {
          active: isActive,
          expiryTimeMillis: expiryTime,
          autoRenewing: subscription.autoRenewing,
          paymentState: subscription.paymentState,
        };
      } catch (error) {
        console.
            error("Subscription check error:", error);
        throw new functions.https.
            HttpsError("unknown", "Failed to check subscription");
      }
    });


exports.consumeOneTimeProduct = functions.https.
    onCall(async (data, context) => {
      const {productId, purchaseToken} = data;

      if (!productId || !purchaseToken) {
        throw new functions.https.
            HttpsError("invalid-argument", "Missing required parameters.");
      }

      // Auth using service account
      const auth = new google.auth.GoogleAuth({
        keyFile: serviceAccountPath,
        scopes:
        ["https://www.googleapis.com/auth/androidpublisher"],
      });

      const authClient = await auth.getClient();

      try {
        const res = await androidpublisher.
            purchases.products.consume({
              packageName: PACKAGE_NAME,
              productId: productId,
              token: purchaseToken,
              auth: authClient,
            });

        return {
          success: true,
          message: "Product consumed successfully.",
          apiResponse: res.data,
        };
      } catch (error) {
        console.error("Error consuming product:", error);
        throw new functions.https.
            HttpsError("internal", "Failed to consume product.");
      }
    });

exports.fetchUserPersonalizedFeed = functions.https.
    onCall(async (data, context) => {
      const userId = data.userId;
      const limit = data.limit || 20;

      if (!userId) {
        throw new functions.https.
            HttpsError("invalid-argument", "userId is required.");
      }

      const firestore = admin.firestore();

      // Step 1: Fetch liked and favorite link IDs
      const likedSnap = await firestore
          .collection("Users")
          .doc(userId)
          .collection("Liked")
          .get();

      const favoriteSnap = await firestore
          .collection("Users")
          .doc(userId)
          .collection("Favorites")
          .get();

      const likedLinkIds = likedSnap.docs.
          map((doc) => doc.id);
      const favoriteLinkIds = favoriteSnap.docs.
          map((doc) => doc.id);

      const interactedLinkIds = Array.
          from(new Set([...likedLinkIds, ...favoriteLinkIds])).slice(0, 20);

      if (interactedLinkIds.length === 0) {
        return fetchTrendingLinks(firestore, limit);
      }

      // Step 2: Build user preferences profile
      const tagCount = {};
      const categoryCount = {};

      for (const linkId of interactedLinkIds) {
        const doc = await firestore.
            collection("Links").doc(linkId).get();
        if (!doc.exists) continue;

        const data = doc.data();
        const tags = Array.isArray(data.searchKeywords) ?
        data.searchKeywords : [];
        const category = data.Category;

        tags.forEach((tag) => {
          tagCount[tag] = (tagCount[tag] || 0) + 1;
        });

        if (category) {
          categoryCount[category] =
          (categoryCount[category] || 0) + 1;
        }
      }

      const topTags = Object.entries(tagCount)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 10)
          .map((entry) => entry[0]);

      let mostPreferredCategory = null;
      if (Object.keys(categoryCount).length > 0) {
        mostPreferredCategory = Object.entries(categoryCount)
            .sort((a, b) => b[1] - a[1])[0][0];
      }

      // Step 3: Query personalized feed
      let query = firestore.collection("Links")
          .orderBy("rankingScore", "desc")
          .orderBy("totalImpressions", "asc");

      if (topTags.length > 0) {
        query = query.where("searchKeywords",
            "array-contains-any", topTags);
      }

      if (mostPreferredCategory) {
        query = query.where("Category", "==",
            mostPreferredCategory);
      }

      try {
      // Fetch a larger pool to balance impressions and ranking
        const poolSize = limit * 3;
        const result = await query.
            limit(poolSize).get();

        let feed = result.docs
            .map((doc) => ({id: doc.id, ...doc.data()}))
            .slice(0, limit);

        if (feed.length < limit) {
          const fallback = await
          fetchTrendingLinks(firestore, limit - feed.length);
          feed = feed.concat(fallback);
        }

        return feed;
      } catch (error) {
        console.error("Error fetching personalized feed:", error);
        return fetchTrendingLinks(firestore, limit);
      }
    });

// Helper function
/**
 * Fetches trending links ordered by likes.
 * @param {FirebaseFirestore.Firestore} firestore - The Firestore instance.
 * @param {number} limit - The number of links to fetch.
 * @return {Promise<Array<Object>>}
 */
async function fetchTrendingLinks(firestore, limit) {
  const result = await firestore
      .collection("Links")
      .orderBy("likes", "desc")
      .orderBy("rankingScore", "desc")
      .limit(limit)
      .get();

  return result.docs.map((doc) =>
    ({id: doc.id, ...doc.data()}));
}

exports.fetchYouMightAlsoLikeLinks = functions.
    https.onCall(async (data, context) => {
      const {currentLinkId, category, searchKeywords,
        limit = 10} = data;
      const firestore = admin.firestore();

      const queryLinks = async (query) => {
        const snapshot = await query.limit(limit * 3).
            get(); // get more to allow balancing
        return snapshot.docs
            .filter((doc) => doc.id !== currentLinkId)
            .map((doc) => ({id: doc.id, ...doc.data()}));
      };

      try {
        // Step 1: Category + searchKeywords
        if (category && Array.isArray(searchKeywords) &&
       searchKeywords.length > 0) {
          const query = firestore.collection("Links")
              .where("Category", "==", category)
              .where("searchKeywords", "array-contains-any",
                  searchKeywords.slice(0, 10))
              .orderBy("rankingScore", "desc")
              .orderBy("totalImpressions", "asc");

          const result = await queryLinks(query);
          if (result.length >= limit) {
            return result.slice(0, limit);
          }
        }

        // Step 2: Category only
        if (category) {
          const query = firestore.collection("Links")
              .where("Category", "==", category)
              .orderBy("rankingScore", "desc")
              .orderBy("totalImpressions", "asc");

          const result = await
          queryLinks(query);
          if (result.length >= limit) {
            return result.slice(0, limit);
          }
        }

        // Step 3: Fallback
        const fallbackQuery = firestore.
            collection("Links")
            .orderBy("rankingScore", "desc")
            .orderBy("totalImpressions", "asc");

        const fallbackResult = await queryLinks(fallbackQuery);
        return fallbackResult.slice(0, limit);
      } catch (error) {
        console.
            error("Error in fetchYouMightAlsoLikeLinks:", error);
        return [];
      }
    });

exports.fetchSearchSuggestions = functions.https.
    onCall(async (data, context) => {
      const userId = data.userId;
      if (!userId) {
        throw new functions.https.
            HttpsError("invalid-argument", "userId is required.");
      }

      const firestore = admin.firestore();
      const userRef = firestore.
          collection("Users").doc(userId);
      const searchedIds = data.searchedLinkIds || [];

      try {
        // 1. Fetch favorited links
        const favSnapshot = await userRef.
            collection("Favorites").get();
        const favoritedIds = favSnapshot.docs.
            map((doc) => doc.id);

        // 2. Fetch created links
        const createdSnapshot = await firestore
            .collection("Links")
            .where("createdBy", "==", userId)
            .get();
        const createdIds = createdSnapshot.docs.
            map((doc) => doc.id);

        // 3. Combine all unique linkIds
        const allLinkIds = Array.from(new
        Set([...favoritedIds, ...createdIds, ...searchedIds]));

        if (allLinkIds.length === 0) {
          return [];
        }

        // 4. Chunk to avoid Firestore's 10-item "whereIn" limit
        const chunks = [];
        for (let i = 0; i < allLinkIds.
            length; i += 10) {
          chunks.push(allLinkIds.
              slice(i, i + 10));
        }

        const allLinks = [];
        for (const chunk of chunks) {
          const query = await firestore
              .collection("Links")
              .where(admin.firestore.FieldPath.
                  documentId(), "in", chunk)
              .orderBy("rankingScore", "desc")
              .orderBy("totalImpressions", "asc")
              .get();

          const links = query.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
          }));
          allLinks.push(...links);
        }

        return allLinks;
      } catch (error) {
        console.
            error("❌ Error fetching search suggestions:",
                error);
        throw new functions.https.HttpsError("internal",
            "Error fetching search suggestions.");
      }
    });
