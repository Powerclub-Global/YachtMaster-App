import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class FbCollections {
  static CollectionReference user = db.collection('users');
  static CollectionReference notifications = db.collection('notifications');
  static CollectionReference chartersOffers = db.collection('charters_offers');
  static CollectionReference bookings = db.collection('bookings');
  static CollectionReference chatHeads = db.collection('chat_heads');
  static CollectionReference invites = db.collection('invites');
  static CollectionReference wallet_history = db.collection('wallet_history');
  static CollectionReference connected_accounts = db.collection('connected_accounts');
  static CollectionReference neighborhoodSuppport =
      db.collection('neighborhood_suppport');
  static CollectionReference appFeedBack = db.collection('app_feedback');
  static CollectionReference content = db.collection('content');
  static CollectionReference settings = db.collection('settings');
  static CollectionReference referral = db.collection('referral');
  static CollectionReference wallet = db.collection('wallet');
  static CollectionReference chat = db.collection('chat');
  static CollectionReference taxes = db.collection('taxes');
  static CollectionReference yachtForSale = db.collection('yacht_for_sale');
  static CollectionReference charterFleet = db.collection('charter_fleet');
  static CollectionReference services = db.collection('services');
  static CollectionReference bookingReviews = db.collection('booking_reviews');
  static CollectionReference appSocialLinks = db.collection('app_social_links');
  static CollectionReference adminChat = db.collection("admin_chat");
  static CollectionReference mail = db.collection("mail");
  static CollectionReference message(id) =>
      db.collection("admin_chat").doc(id).collection("messages");
}
