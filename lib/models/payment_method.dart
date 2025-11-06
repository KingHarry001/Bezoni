class PaymentMethod {
  final String id;
  String type;
  String cardNumber;
  String cardType;
  String expiryDate;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.cardNumber,
    required this.cardType,
    required this.expiryDate,
    required this.isDefault,
  });
}