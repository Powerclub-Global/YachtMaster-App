
class PaymentPayoutsModel{
  String? charterName;
  String? paidBy;
  String? price;
  String? date;

  PaymentPayoutsModel({this.charterName, this.paidBy, this.price, this.date});
}
class PaymentModel
{
  List<PaymentPayoutsModel>? payments;
  int? status;

  PaymentModel({this.payments, this.status});
}