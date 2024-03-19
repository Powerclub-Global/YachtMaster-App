import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:yacht_master/services/stripe/stripe_api.dart';

import '../../localization/app_localization.dart';
import '../../utils/zbot_toast.dart';

class StripeService {
  Future<void> handlePayPress({
    required BillingDetails billingDetails,
    CardDetails? card,
    String? price,
    required String secretKey,
    required String userName,
    required String userEmail,
    required String customerID,
    String? priceID,
    required VoidCallback onPaymentSuccess,
    ValueChanged<String>? onError,
    ValueChanged<String>? getCustomerID,
    ValueChanged<String>? getSubscriptionID,
    ValueChanged<PaymentIntent>? paymentDetails,
    bool? isSubscription = true,
    bool? isCardAvailable = true,
  }) async {
    try {
      Map<String, dynamic>? customer;
      final currentCustomer =
          await getCustomers(secretKey: secretKey, customerID: customerID);
      if (currentCustomer != null) {
        customer = currentCustomer;
        getCustomerID!(customer['id']);
      } else {
        // 1. Create User
        customer = await createCustomer(
            userName: userName, userEmail: userEmail, secretKey: secretKey);
        print("SECRENT $secretKey");
        print("CUSTOMER $customer");
        getCustomerID!(customer?['id']);
      }

      // 2. Create payment method
      if (isCardAvailable!) {
        await Stripe.instance.dangerouslyUpdateCardDetails(card!);
      }

      if (isSubscription!) {
        final paymentMethod = await Stripe.instance.createPaymentMethod(
            options: const PaymentMethodOptions(
                setupFutureUsage: PaymentIntentsFutureUsage.OffSession),
            params: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: billingDetails,
              ),
            ));

        await attachPaymentMethod(
            paymentId: paymentMethod.id,
            customerId: customer?['id'],
            secretKey: secretKey);
        // 4. call API to update the user with the payment method
        await updateCustomer(
            paymentId: paymentMethod.id,
            customerId: customer?['id'],
            secretKey: secretKey);
        // 5. call API to create subscription

        var subscription = await createSubscription(
            priceID: priceID!,
            customerId: customer?['id'],
            secretKey: secretKey);
        // log(subscription?["id"]);
        getSubscriptionID!(subscription?["id"]);
        if (subscription?['status'] == 'active') {
          print(5);
          onPaymentSuccess();
        } else {
          var invoice = await getInvoice(
              secretKey: secretKey, invoiceID: subscription?['latest_invoice']);
          var paymentIntent = await getPaymentIntent(
              secretKey: secretKey, paymentID: invoice?["payment_intent"]);
          final confirm = await Stripe.instance.confirmPayment(
              paymentIntentClientSecret: paymentIntent?["client_secret"],
              options: const PaymentMethodOptions(
                  setupFutureUsage: PaymentIntentsFutureUsage.OffSession),
              data: PaymentMethodParams.card(
                  paymentMethodData:
                      PaymentMethodData(billingDetails: billingDetails)));
          if (confirm.status == PaymentIntentsStatus.Succeeded) {
            paymentDetails!(confirm);
            print(4);
            onPaymentSuccess();
          }
        }
      } else {
        // 3. call API to create PaymentIntent
        final paymentIntentResult = await createPaymentIntents(
          amount: price!,
          currency: 'usd', // mocked data
          secretKey: secretKey,
        );

        log("____MAP:${paymentIntentResult}");
        if (paymentIntentResult?['error'] != null) {
          // Error during creating or confirming Intent
          onError!(paymentIntentResult?['error']);
          ZBotToast.loadingClose();
          log("ERROR:${paymentIntentResult?['error']}");
          return;
        }
        if (!isCardAvailable) {
          var intent = await createSetupIntent(
              secretKey: secretKey, customerId: customer?['id']);
          print("Bhai bout to start payment sheet");
          await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  customerId: customerID,
                  paymentIntentClientSecret:
                      paymentIntentResult?['client_secret'],
                  style: ThemeMode.dark,
                  applePay: PaymentSheetApplePay(merchantCountryCode: 'US'),
                  merchantDisplayName: "Yacht Master"));

          await Stripe.instance.presentPaymentSheet().then((value) =>
              {print("Printing status now ........"), onPaymentSuccess()});

          final paymentIntent = await Stripe.instance
              .handleNextAction(paymentIntentResult?['client_secret']);

          // await Stripe.instance.confirmPaymentSheetPayment();

          if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
            print(1);
          } else {
            ZBotToast.showToastError(
                message: getTranslated(Get.context!, "payment_failed"));
          }
        } else {
          if (paymentIntentResult?['client_secret'] != null &&
              paymentIntentResult?['status'] == "succeeded") {
            print(2);
            onPaymentSuccess();
            return;
          }

          if (paymentIntentResult?['client_secret'] != null &&
              paymentIntentResult?['status'] == "requires_confirmation") {
            log("____HERE:${paymentIntentResult?['status']}_____${paymentIntentResult?['client_secret']}");
            // 4. if payment requires action calling handleNextAction
            // final paymentIntent = await Stripe.instance.handleNextAction(paymentIntentResult?['client_secret']);

            if (paymentIntentResult?['status'] == "requires_confirmation") {
              // 5. Call API to confirm payment
              final confirm = await Stripe.instance.confirmPayment(
                  paymentIntentClientSecret:
                      paymentIntentResult?['client_secret'],
                  options: const PaymentMethodOptions(
                    setupFutureUsage: PaymentIntentsFutureUsage.OffSession,
                  ),
                  data: PaymentMethodParams.card(
                      paymentMethodData:
                          PaymentMethodData(billingDetails: billingDetails)));
              if (confirm.status == PaymentIntentsStatus.Succeeded) {
                log("____PAYMENT METHOD ID:${confirm.paymentMethodId}___${customerID}");
                paymentDetails!(confirm);
                print(3);
                onPaymentSuccess();
              }
            } else {
              onError!(paymentIntentResult?['error']);
              ZBotToast.loadingClose();
              log("ERROR:${paymentIntentResult?['error']}");
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
      ZBotToast.loadingClose();
    }
  }

  Future<void> cancelSubscription({
    required String secretKey,
    required String subscriptionID,
    required VoidCallback onCancelSuccess,
  }) async {
    var cancelSub =
        await cancelSubs(secretKey: secretKey, subscriptionID: subscriptionID);
    if (cancelSub != null) {
      onCancelSuccess();
    }
    log("cancel $cancelSub");
  }

  Future<Map<String, dynamic>?> cancelSubs({
    required String secretKey,
    required String subscriptionID,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'DELETE', Uri.parse(ApisForStripe.cancelSubscription(subscriptionID)));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> createPaymentIntents({
    required String currency,
    required String amount,
    required String secretKey,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request =
        http.Request('POST', Uri.parse(ApisForStripe.paymentIntents()));
    request.bodyFields = {
      'amount': amount,
      'currency': currency,
    };
    request.headers.addAll(headers);
    print("about to make request");
    http.StreamedResponse response = await request.send();
    print("request made");
    print(response.statusCode);
    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      print(jsonDecode(result));
      return jsonDecode(result);
    } else {
      log("${response.reasonPhrase}");
    }
    return null;
  }

  Future<Map<String, dynamic>?> createCustomer({
    required String userName,
    required String userEmail,
    required String secretKey,
  }) async {
    log("$userName$userEmail$secretKey");
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request =
        http.Request('POST', Uri.parse(ApisForStripe.createCustomer()));
    request.bodyFields = {'name': userName, 'email': userEmail};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    log("REASON ${response.reasonPhrase.toString()} ${response.statusCode.toString()}");
    return null;
  }

  Future<Map<String, dynamic>?> getCustomers({
    required String secretKey,
    required String customerID,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request =
        http.Request('GET', Uri.parse(ApisForStripe.getCustomer(customerID)));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  ///GET CARD
  Future<Map<String, dynamic>?> getCard({
    required String secretKey,
    required String customerID,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request =
        http.Request('GET', Uri.parse(ApisForStripe.getCard(customerID)));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      log("____get card successs:${request}");
      return jsonDecode(result);
    } else {
      log("get card err:${response.reasonPhrase.toString()}");
    }
    return null;
  }

  ///CREATE CARD
  Future<Map<String, dynamic>?> createCard({
    required String secretKey,
    required String customerID,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request =
        http.Request('GET', Uri.parse(ApisForStripe.createCard(customerID)));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      log("create card err:${result}");

      return jsonDecode(result);
    } else {
      log("create card err:${response.reasonPhrase.toString()}");
    }
    return null;
  }

  Future<Map<String, dynamic>?> attachPaymentMethod({
    required String paymentId,
    required String customerId,
    required String secretKey,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST', Uri.parse(ApisForStripe.attachCard(paymentId, customerId)));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateCustomer({
    required String paymentId,
    required String customerId,
    required String secretKey,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST', Uri.parse(ApisForStripe.updateCustomer(customerId)));
    request.bodyFields = {
      'invoice_settings[default_payment_method]': paymentId,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> createSubscription({
    required String priceID,
    required String customerId,
    required String secretKey,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request =
        http.Request('POST', Uri.parse(ApisForStripe.createSubscription()));
    request.bodyFields = {
      'customer': customerId,
      'items[0][price]': priceID,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      log(result);
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<void> updateSubscription({
    required String secretKey,
    required String subscriptionId,
    required Function(Map<String, dynamic>) onSuccess,
    Map<String, String>? body,
  }) async {
    var updateSub = await updateSubs(
        secretKey: secretKey, subscriptionId: subscriptionId, body: body);
    if (updateSub != null) {
      onSuccess(updateSub);
    }
    log("cancel $updateSub");
  }

  Future<Map<String, dynamic>?> updateSubs({
    required String subscriptionId,
    required String secretKey,
    Map<String, String>? body,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST', Uri.parse(ApisForStripe.updateSubscription(subscriptionId)));
    if (body != null) {
      request.bodyFields = body;
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<void> retrieveSubscription({
    required String secretKey,
    required String subscriptionId,
    required Function(Map<String, dynamic>) onSuccess,
    Map<String, String>? body,
  }) async {
    var updateSub = await retrieveSubs(
        secretKey: secretKey, subscriptionId: subscriptionId, body: body);
    if (updateSub != null) {
      onSuccess(updateSub);
    }
  }

  Future<Map<String, dynamic>?> retrieveSubs({
    required String subscriptionId,
    required String secretKey,
    Map<String, String>? body,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'GET', Uri.parse(ApisForStripe.updateSubscription(subscriptionId)));
    if (body != null) {
      request.bodyFields = body;
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      log(result);
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> getInvoice({
    required String secretKey,
    required String invoiceID,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request =
        http.Request('GET', Uri.parse(ApisForStripe.getInvoice(invoiceID)));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPaymentIntent({
    required String secretKey,
    required String paymentID,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'GET', Uri.parse(ApisForStripe.getPaymentIntent(paymentID)));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> createSetupIntent({
    String? customerId,
    String? secretKey,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var response = await http.post(Uri.parse(ApisForStripe.createSetupIntent()),
        body: {
          'customer': customerId!,
          'automatic_payment_methods[enabled]': 'true',
        },
        headers: headers);

    if (response.statusCode == 200) {
      result = response.body;
      return jsonDecode(result);
    } else {
      log("${response.reasonPhrase}");
    }
    return null;
  }
}
