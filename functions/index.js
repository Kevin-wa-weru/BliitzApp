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
