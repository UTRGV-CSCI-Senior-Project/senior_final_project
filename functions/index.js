const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

exports.sendChatNotification = functions.https.onCall(async (request) => {
  const {tokens, title, body} = request.data;

  if (!tokens || !title || !body) {
    throw new functions.https.HttpsError("invalid-argument",
        "The function must be called with tokens, title, and body.");
  }

  const message = {
    tokens: tokens,
    notification: {
      title: title,
      body: body,
    },
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    return {success: true, response: response};
  } catch (error) {
    throw new functions.https.HttpsError("UNKNOWN",
        `There was an error: ${error}`);
  }
});
