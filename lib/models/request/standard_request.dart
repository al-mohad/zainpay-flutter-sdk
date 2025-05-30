import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zainpay/models/response/init_payment_response.dart';

import '../../utils.dart';

class StandardRequest {
  final String fullName;
  final String amount;
  final String publicKey;
  final String transactionRef;
  final String email;
  final String mobileNumber;
  final String zainboxCode;
  final String callBackUrl;
  final bool isTest;

  StandardRequest(
      {required this.fullName,
      required this.publicKey,
      required this.transactionRef,
      required this.email,
      required this.mobileNumber,
      required this.zainboxCode,
      required this.callBackUrl,
      required this.amount,
      required this.isTest});

  @override
  String toString() => jsonEncode(toJson());

  /// Converts this instance to json
  Map<String, dynamic> toJson() => {
        "amount": amount,
        "txnRef": transactionRef,
        "mobileNumber": mobileNumber,
        "zainboxCode": zainboxCode,
        "emailAddress": email,
        "callBackUrl": callBackUrl,
        "isTest": isTest
      };

  /// Executes network call to initiate transactions
  Future<InitPaymentResponse?> initializePayment(publicKey) async {
    InitPaymentResponse? initPaymentResponse;

    try {
      final url = "${Utils.getBaseUrl(isTest)}/${Utils.initializePaymentUrl}";

      final response = await http.post(Uri.parse(url),
          headers: {
            "Authorization": "Bearer $publicKey",
            "Content-Type": "application/json"
          },
          body: toString());

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        initPaymentResponse = InitPaymentResponse.fromJson(responseBody);

        // Check if the response code indicates success
        if (responseBody["code"] != Utils.statusSuccess) {
          // Log the error for debugging
          print(
              "Payment initialization failed: ${responseBody["description"]}");
        }
      } else {
        // Log the error for debugging
        print(
            "Payment initialization failed with status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      // Log the error for debugging
      print("Exception during payment initialization: $e");
    }

    return initPaymentResponse;
  }
}
