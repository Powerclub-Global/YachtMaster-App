import 'package:cloud_firestore/cloud_firestore.dart';

class FBCollections {
  static FirebaseFirestore fb = FirebaseFirestore.instance;
  static CollectionReference mail = fb.collection("mail");
  static CollectionReference users = fb.collection("users");
  static CollectionReference notifications = fb.collection("notifications");
  static CollectionReference content = fb.collection("content");
  static CollectionReference feedback = fb.collection("app_feedback");
  static CollectionReference charterFleet = fb.collection("charter_fleet");
  static CollectionReference bookings = fb.collection("bookings");
  static CollectionReference taxes = fb.collection("taxes");
  static CollectionReference chatHeads = fb.collection("admin_chat");
  static CollectionReference yachtForSale = fb.collection("yacht_for_sale");
  static CollectionReference services = fb.collection("services");
  static CollectionReference message(id) =>
      fb.collection("admin_chat").doc(id).collection("messages");
  static CollectionReference settings = fb.collection("settings");
}
