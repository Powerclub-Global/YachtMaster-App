const { onCall } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const Stripe = require('stripe');
const admin = require('firebase-admin');

// Initialize Stripe with secret key from environment
// Use a placeholder during deployment, will be set via firebase functions:config:set
const stripeKey = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';
const stripe = Stripe(stripeKey);

/**
 * Create a Payment Intent
 * Only publishable key is exposed to client
 */
exports.createPaymentIntent = onCall(async (request) => {
  const { amount, currency, customerId, metadata } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  // Validate amount
  if (!amount || amount <= 0) {
    throw new Error('Invalid payment amount');
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: currency || 'usd',
      customer: customerId,
      metadata: {
        userId: uid,
        ...metadata
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    logger.info('Payment intent created', { userId: uid, amount, paymentIntentId: paymentIntent.id });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    logger.error('Failed to create payment intent', { error: error.message, userId: uid });
    throw new Error('Payment processing failed');
  }
});

/**
 * Create Stripe Customer
 */
exports.createStripeCustomer = onCall(async (request) => {
  const { email, name } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  try {
    const customer = await stripe.customers.create({
      email,
      name,
      metadata: {
        firebaseUID: uid,
      },
    });

    // Store customer ID in Firestore
    await admin.firestore().collection('users').doc(uid).update({
      stripeCustomerId: customer.id,
    });

    logger.info('Stripe customer created', { userId: uid, customerId: customer.id });

    return {
      customerId: customer.id,
    };
  } catch (error) {
    logger.error('Failed to create Stripe customer', { error: error.message, userId: uid });
    throw new Error('Customer creation failed');
  }
});

/**
 * Create Setup Intent for saving payment methods
 */
exports.createSetupIntent = onCall(async (request) => {
  const { customerId } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  try {
    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
      payment_method_types: ['card'],
    });

    logger.info('Setup intent created', { userId: uid, setupIntentId: setupIntent.id });

    return {
      clientSecret: setupIntent.client_secret,
      setupIntentId: setupIntent.id,
    };
  } catch (error) {
    logger.error('Failed to create setup intent', { error: error.message, userId: uid });
    throw new Error('Setup intent creation failed');
  }
});

/**
 * Attach Payment Method to Customer
 */
exports.attachPaymentMethod = onCall(async (request) => {
  const { paymentMethodId, customerId } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  try {
    const paymentMethod = await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });

    logger.info('Payment method attached', { userId: uid, paymentMethodId });

    return {
      paymentMethodId: paymentMethod.id,
    };
  } catch (error) {
    logger.error('Failed to attach payment method', { error: error.message, userId: uid });
    throw new Error('Payment method attachment failed');
  }
});

/**
 * Process Connect Account Transfer (for host payouts)
 */
exports.createConnectTransfer = onCall(async (request) => {
  const { amount, connectedAccountId, transferGroup, metadata } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  try {
    const transfer = await stripe.transfers.create({
      amount: Math.round(amount * 100),
      currency: 'usd',
      destination: connectedAccountId,
      transfer_group: transferGroup,
      metadata: {
        userId: uid,
        ...metadata
      },
    });

    logger.info('Connect transfer created', { userId: uid, transferId: transfer.id });

    return {
      transferId: transfer.id,
    };
  } catch (error) {
    logger.error('Failed to create transfer', { error: error.message, userId: uid });
    throw new Error('Transfer processing failed');
  }
});

/**
 * Confirm Payment Intent (if additional confirmation needed)
 */
exports.confirmPaymentIntent = onCall(async (request) => {
  const { paymentIntentId } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  try {
    const paymentIntent = await stripe.paymentIntents.confirm(paymentIntentId);

    logger.info('Payment intent confirmed', { userId: uid, paymentIntentId });

    return {
      status: paymentIntent.status,
    };
  } catch (error) {
    logger.error('Failed to confirm payment intent', { error: error.message, userId: uid });
    throw new Error('Payment confirmation failed');
  }
});

/**
 * Get Payment Intent status
 */
exports.getPaymentIntent = onCall(async (request) => {
  const { paymentIntentId } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  try {
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    return {
      status: paymentIntent.status,
      amount: paymentIntent.amount / 100,
      currency: paymentIntent.currency,
    };
  } catch (error) {
    logger.error('Failed to retrieve payment intent', { error: error.message, userId: uid });
    throw new Error('Failed to retrieve payment status');
  }
});

/**
 * Create refund
 */
exports.createRefund = onCall(async (request) => {
  const { paymentIntentId, amount, reason } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    throw new Error('Authentication required');
  }

  try {
    const refundData = {
      payment_intent: paymentIntentId,
      reason: reason || 'requested_by_customer',
    };

    if (amount) {
      refundData.amount = Math.round(amount * 100);
    }

    const refund = await stripe.refunds.create(refundData);

    logger.info('Refund created', { userId: uid, refundId: refund.id });

    return {
      refundId: refund.id,
      status: refund.status,
    };
  } catch (error) {
    logger.error('Failed to create refund', { error: error.message, userId: uid });
    throw new Error('Refund processing failed');
  }
});
