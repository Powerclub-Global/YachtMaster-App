import 'dart:convert';
import 'dart:developer';

import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yacht_master/main.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/stripe/stripe_api.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/withdraw_money.dart';

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
      final currentCustomer = await getCustomers(
        secretKey: secretKey,
        customerID: customerID,
      );
      if (currentCustomer != null) {
        customer = currentCustomer;
        getCustomerID!(customer['id']);
      } else {
        // 1. Create User
        customer = await createCustomer(
          userName: userName,
          userEmail: userEmail,
          secretKey: secretKey,
        );
        log('Stripe customer created', name: 'StripeService');
        getCustomerID!(customer?['id']);
      }

      // 2. Create payment method
      if (isCardAvailable!) {
        await Stripe.instance.dangerouslyUpdateCardDetails(card!);
      }

      if (isSubscription!) {
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          options: const PaymentMethodOptions(
            setupFutureUsage: PaymentIntentsFutureUsage.OffSession,
          ),
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
          ),
        );

        await attachPaymentMethod(
          paymentId: paymentMethod.id,
          customerId: customer?['id'],
          secretKey: secretKey,
        );
        // 4. call API to update the user with the payment method
        await updateCustomer(
          paymentId: paymentMethod.id,
          customerId: customer?['id'],
          secretKey: secretKey,
        );
        // 5. call API to create subscription

        var subscription = await createSubscription(
          priceID: priceID!,
          customerId: customer?['id'],
          secretKey: secretKey,
        );
        // log(subscription?["id"]);
        getSubscriptionID!(subscription?["id"]);
        if (subscription?['status'] == 'active') {
          onPaymentSuccess();
        } else {
          var invoice = await getInvoice(
            secretKey: secretKey,
            invoiceID: subscription?['latest_invoice'],
          );
          var paymentIntent = await getPaymentIntent(
            secretKey: secretKey,
            paymentID: invoice?["payment_intent"],
          );
          final confirm = await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: paymentIntent?["client_secret"],
            options: const PaymentMethodOptions(
              setupFutureUsage: PaymentIntentsFutureUsage.OffSession,
            ),
            data: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: billingDetails,
              ),
            ),
          );
          if (confirm.status == PaymentIntentsStatus.Succeeded) {
            paymentDetails!(confirm);
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

        if (paymentIntentResult?['error'] != null) {
          // Error during creating or confirming Intent
          onError!(paymentIntentResult?['error']);
          ZBotToast.loadingClose();
          log("ERROR:${paymentIntentResult?['error']}");
          return;
        }
        if (!isCardAvailable) {
          await createSetupIntent(
            secretKey: secretKey,
            customerId: customer?['id'],
          );
          log('Initializing Stripe payment sheet', name: 'StripeService');
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              customerId: customerID,
              paymentIntentClientSecret: paymentIntentResult?['client_secret'],
              style: ThemeMode.dark,
              applePay: PaymentSheetApplePay(merchantCountryCode: 'US'),
              merchantDisplayName: "Yacht Master",
            ),
          );

          await Stripe.instance.presentPaymentSheet().then(
            (value) => {
              log('Payment sheet completed', name: 'StripeService'),
              onPaymentSuccess(),
            },
          );

          final paymentIntent = await Stripe.instance.handleNextAction(
            paymentIntentResult?['client_secret'],
          );

          // await Stripe.instance.confirmPaymentSheetPayment();

          if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
          } else {
            ZBotToast.showToastError(
              message: getTranslated(Get.context!, "payment_failed"),
            );
          }
        } else {
          if (paymentIntentResult?['client_secret'] != null &&
              paymentIntentResult?['status'] == "succeeded") {
            onPaymentSuccess();
            return;
          }

          if (paymentIntentResult?['client_secret'] != null &&
              paymentIntentResult?['status'] == "requires_confirmation") {
            log('Confirming payment intent requiring action', name: 'StripeService');
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
                  paymentMethodData: PaymentMethodData(
                    billingDetails: billingDetails,
                  ),
                ),
              );
              if (confirm.status == PaymentIntentsStatus.Succeeded) {
                log('Payment intent confirmed', name: 'StripeService');
                paymentDetails!(confirm);
                onPaymentSuccess();
              }
            } else {
              onError!(paymentIntentResult?['error']);
              ZBotToast.loadingClose();
              log('Stripe payment error response', name: 'StripeService');
            }
          }
        }
      }
    } catch (e) {
      log('Stripe payment error: $e', name: 'StripeService');
      ZBotToast.loadingClose();
    }
  }

  Future<void> checkDetailsSubmitted(
    BuildContext context,
    bool isRedirect,
    String connectedAccount,
  ) async {
    var headers = {'Authorization': 'Basic $connectKey'};
    var request = http.Request(
      'GET',
      Uri.parse('https://api.stripe.com/v1/accounts/$connectedAccount'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var accountData = jsonDecode(await response.stream.bytesToString());
      if (accountData['details_submitted']) {
        ZBotToast.loadingClose();
        Get.toNamed(
          WithdrawMoney.route,
          arguments: {'accountId': connectedAccount},
        );
      } else {
        ZBotToast.loadingClose();
        if (isRedirect) {
          Navigator.pop(context);
          Get.dialog(
            AlertDialog(
              content: Text(
                getTranslated(
                  context,
                  "onboarding_return_details_not_submitted",
                )!,
              ),
            ),
          );
        } else {
          // error in onboarding starting again
          Get.bottomSheet(
            Container(
              color: Colors.black,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      getTranslated(context, "fail_prev_intro")!,
                      softWrap: true,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      getTranslated(context, "read_instructions")!,
                      style: TextStyle(color: Colors.white),
                      softWrap: true,
                    ),
                    SizedBox(height: 20),
                    BulletedList(
                      style: TextStyle(
                        color: const Color.fromARGB(188, 255, 255, 255),
                      ),
                      listItems: [
                        getTranslated(
                          context,
                          "first_time_intro_bullet_text_1",
                        )!,
                        getTranslated(
                          context,
                          "first_time_intro_bullet_text_2",
                        )!,
                        getTranslated(
                          context,
                          "first_time_intro_bullet_text_3",
                        )!,
                      ],
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        ZBotToast.loadingShow();
                        String accountLink = await createAccountLink(
                          connectedAccount,
                        );
                        if (accountLink == 'internet error') {
                          // ignore: use_build_context_synchronously
                          Get.dialog(
                            AlertDialog(
                              content: Text(
                                getTranslated(
                                  context,
                                  "no_internet_onboarding",
                                )!,
                              ),
                            ),
                          );
                          return;
                        }
                        ZBotToast.loadingClose();
                        launchUrl(Uri.parse(accountLink));
                      },
                      child: Container(
                        height: Get.height * .05,
                        width: Get.width * .65,
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 2.h,
                        ),
                        decoration: AppDecorations.gradientButton(radius: 30),
                        child: Center(
                          child: Text(
                            getTranslated(context, "proceed") ?? "",
                            style: R.textStyle.helvetica().copyWith(
                              color: R.colors.black,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    } else {
      ZBotToast.loadingClose();
      Get.dialog(
        AlertDialog(
          content: Text(getTranslated(context, "no_internet_onboarding")!),
        ),
      );
    }
  }

  Future<void> payout(String accountId, String amount) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic $connectKey',
    };
    var request = http.Request(
      'POST',
      Uri.parse('https://api.stripe.com/v1/transfers'),
    );
    request.bodyFields = {
      'amount': amount,
      'currency': 'usd',
      'destination': accountId,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      log('Payout initiated successfully', name: 'StripeService');
      await response.stream.drain();
    } else {
      log('Payout failed: ${response.statusCode}', name: 'StripeService');
      Get.dialog(AlertDialog(content: Text(response.reasonPhrase ?? 'Error')));
    }
  }

  Future<String> createStripeConnectedAccount(String uid) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic $connectKey',
    };
    var request = http.Request(
      'POST',
      Uri.parse('https://api.stripe.com/v1/accounts'),
    );
    request.bodyFields = {
      'controller[losses][payments]': 'application',
      'controller[fees][payer]': 'application',
      'controller[stripe_dashboard][type]': 'express',
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var accountData = jsonDecode(await response.stream.bytesToString());
      FbCollections.connected_accounts.add({
        "account_id": accountData['id'],
        "uid": uid,
      });
      return accountData['id'];
    } else {
      log('Failed to create connected account: ${response.statusCode}', name: 'StripeService');
      return "internet error";
    }
  }

  Future<String> createAccountLink(String accountId) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic $connectKey',
    };
    var request = http.Request(
      'POST',
      Uri.parse('https://api.stripe.com/v1/account_links'),
    );
    request.bodyFields = {
      'account': accountId,
      'type': 'account_onboarding',
      'refresh_url': 'https://yachtmasterapp.com?status=refresh',
      'return_url': 'https://yachtmasterapp.com?status=return',
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var accountLinkData = jsonDecode(await response.stream.bytesToString());
      return accountLinkData["url"];
    } else {
      log('Failed to create account link: ${response.statusCode}', name: 'StripeService');
      return "internet error";
    }
  }

  Future<void> cancelSubscription({
    required String secretKey,
    required String subscriptionID,
    required VoidCallback onCancelSuccess,
  }) async {
    var cancelSub = await cancelSubs(
      secretKey: secretKey,
      subscriptionID: subscriptionID,
    );
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'DELETE',
      Uri.parse(ApisForStripe.cancelSubscription(subscriptionID)),
    );

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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'POST',
      Uri.parse(ApisForStripe.paymentIntents()),
    );
    request.bodyFields = {'amount': amount, 'currency': currency};
    request.headers.addAll(headers);
    log('Creating payment intent', name: 'StripeService');
    http.StreamedResponse response = await request.send();
    log('Stripe payment intent response: ${response.statusCode}', name: 'StripeService');
    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log('Stripe payment intent failed: ${response.statusCode}', name: 'StripeService');
    }
    return null;
  }

  Future<Map<String, dynamic>?> createCustomer({
    required String userName,
    required String userEmail,
    required String secretKey,
  }) async {
    log('Ensuring Stripe customer exists', name: 'StripeService');
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'POST',
      Uri.parse(ApisForStripe.createCustomer()),
    );
    request.bodyFields = {'name': userName, 'email': userEmail};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      return jsonDecode(result);
    } else {
      log(response.reasonPhrase.toString());
    }
    log(
      "REASON ${response.reasonPhrase.toString()} ${response.statusCode.toString()}",
    );
    return null;
  }

  Future<Map<String, dynamic>?> getCustomers({
    required String secretKey,
    required String customerID,
  }) async {
    String result = "";
    var headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'GET',
      Uri.parse(ApisForStripe.getCustomer(customerID)),
    );
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'GET',
      Uri.parse(ApisForStripe.getCard(customerID)),
    );
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      log('Retrieved card list for customer', name: 'StripeService');
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'GET',
      Uri.parse(ApisForStripe.createCard(customerID)),
    );
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      result = await response.stream.bytesToString();
      log("create card err:$result");

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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'POST',
      Uri.parse(ApisForStripe.attachCard(paymentId, customerId)),
    );
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'POST',
      Uri.parse(ApisForStripe.updateCustomer(customerId)),
    );
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'POST',
      Uri.parse(ApisForStripe.createSubscription()),
    );
    request.bodyFields = {'customer': customerId, 'items[0][price]': priceID};
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
      secretKey: secretKey,
      subscriptionId: subscriptionId,
      body: body,
    );
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'POST',
      Uri.parse(ApisForStripe.updateSubscription(subscriptionId)),
    );
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
      secretKey: secretKey,
      subscriptionId: subscriptionId,
      body: body,
    );
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'GET',
      Uri.parse(ApisForStripe.updateSubscription(subscriptionId)),
    );
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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'GET',
      Uri.parse(ApisForStripe.getInvoice(invoiceID)),
    );

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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request(
      'GET',
      Uri.parse(ApisForStripe.getPaymentIntent(paymentID)),
    );

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
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var response = await http.post(
      Uri.parse(ApisForStripe.createSetupIntent()),
      body: {
        'customer': customerId!,
        'automatic_payment_methods[enabled]': 'true',
      },
      headers: headers,
    );

    if (response.statusCode == 200) {
      result = response.body;
      return jsonDecode(result);
    } else {
      log("${response.reasonPhrase}");
    }
    return null;
  }
}
