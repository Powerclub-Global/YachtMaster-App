const sdk = require("node-appwrite");
const { onRequest } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const admin = require('firebase-admin');
const Stripe = require('stripe');
const cors = require('cors')({ origin: true });

admin.initializeApp();

exports.deleteuser = onRequest(async (req, res) => {
  // Grab the text parameter.
  const userId = req.query.userId;
  logger.log("User ID", userId);
  // Push the new message into Firestore using the Firebase Admin SDK.
  const client = new sdk.Client()
    .setEndpoint("https://cloud.appwrite.io/v1") // Your API Endpoint
    .setProject("66322b1f002a454ae73f") // Your project ID
    .setKey("e3a37d6d98467e231db5481075c68dfbd61d7ec08b2722ac682708e43aab57f1432a6498b9c85cb86be721180e7fae1f9971f84d3b825ed7da2545a09c669a289d6c1133af9df3761d71be1ee4d74bfa63885f4a4a5195c9e67a604c75fefc84a533fbb9350d8ed1991f30319776363f19e075804d3a7cf676d4f10a67e36feb"); // Your secret API key

  const users = new sdk.Users(client);

  await users.delete(
    userId, // userId
  );

  // Send back a message that we've successfully written the message
  res.json({ result: `User with ID: ${userId} deleted.` });
});

const stripe = Stripe(STRIPE_API_KEY); // <-- uses config

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