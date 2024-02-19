class ApisForStripe {
  static String baseUrl = "https://api.stripe.com/v1/";

  static String paymentIntents() => "${baseUrl}payment_intents";
  static String createCustomer() => "${baseUrl}customers";
  static String getCustomer(cId) => "${baseUrl}customers/$cId";
  static String getCard(customerId) => "${baseUrl}customers/$customerId/sources";
  static String createCard(customerId) => "${baseUrl}customers/$customerId/sources";
  static String attachCard(paymentId, customerId) => "${baseUrl}payment_methods/$paymentId/attach?customer=$customerId";
  static String updateCustomer(cId) => "${baseUrl}customers/$cId";
  static String createSubscription() => "${baseUrl}subscriptions";
  static String updateSubscription(subscriptionId) => "${baseUrl}subscriptions/$subscriptionId";
  static String createSetupIntent() => "${baseUrl}setup_intents";
  static String getInvoice(invoiceID) => "${baseUrl}invoices/$invoiceID";
  static String getPaymentIntent(paymentIntentID) => "${baseUrl}payment_intents/$paymentIntentID";
  static String cancelSubscription(sId) => "${baseUrl}subscriptions/$sId";
  
}
