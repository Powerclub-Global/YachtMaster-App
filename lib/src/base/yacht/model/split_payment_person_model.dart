import 'package:flutter/material.dart';

class SplitPaymentPersonModel
{
  dynamic personEmail;
  dynamic percentage;
  double? splitAmount;
  bool? isPaid;
  SplitPaymentPersonModel(
      {this.personEmail, this.percentage, this.splitAmount,this.isPaid=false});
}
