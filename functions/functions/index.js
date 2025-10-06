const sdk = require("node-appwrite");
const { onRequest } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const admin = require('firebase-admin');
const Stripe = require('stripe');
const cors = require('cors')({ origin: true });

admin.initializeApp();

// Import Stripe payment processing functions
const stripeService = require('./stripe_service');

exports.deleteuser = onRequest(async (req, res) => {
  // Grab the text parameter.
  const userId = req.query.userId;
  logger.log("User ID", userId);
  // Push the new message into Firestore using the Firebase Admin SDK.
  const client = new sdk.Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT || "https://cloud.appwrite.io/v1")
    .setProject(process.env.APPWRITE_PROJECT_ID || "")
    .setKey(process.env.APPWRITE_API_KEY || ""); // Secret key from environment

  const users = new sdk.Users(client);

  await users.delete(
    userId, // userId
  );

  // Send back a message that we've successfully written the message
  res.json({ result: `User with ID: ${userId} deleted.` });
});

const stripe = Stripe(process.env.STRIPE_API_KEY || ''); // Environment variable

exports.createVerificationSession = onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== 'POST') {
      return res.status(405).send({ error: 'Method not allowed' });
    }

    const { email, userId } = req.body;

    if (!email || !userId) {
      return res.status(400).json({ error: 'Missing email or userId' });
    }

    try {
      const verificationSession = await stripe.identity.verificationSessions.create({
        type: 'document',
        provided_details: {
          email: email,
        },
        metadata: {
          user_id: userId,
        },
      });

      const ephemeralKey = await stripe.ephemeralKeys.create(
        { verification_session: verificationSession.id },
        { apiVersion: '2025-03-31.basil' }
      );

      return res.status(200).json({
        verificationSessionId: verificationSession.id,
        ephemeralKeySecret: ephemeralKey.secret,
      });
    } catch (err) {
      console.error('Error:', err);
      return res.status(500).json({ error: 'Internal Server Error' });
    }
  });
});

// Export Stripe payment functions
exports.createPaymentIntent = stripeService.createPaymentIntent;
exports.createStripeCustomer = stripeService.createStripeCustomer;
exports.createSetupIntent = stripeService.createSetupIntent;
exports.attachPaymentMethod = stripeService.attachPaymentMethod;
exports.createConnectTransfer = stripeService.createConnectTransfer;
exports.confirmPaymentIntent = stripeService.confirmPaymentIntent;
exports.getPaymentIntent = stripeService.getPaymentIntent;
exports.createRefund = stripeService.createRefund;