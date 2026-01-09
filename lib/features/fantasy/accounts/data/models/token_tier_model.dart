class TokenTierModel {
  final String id;
  final int minAmount;
  final int maxAmount;
  final int tokenAmount;

  TokenTierModel({
    required this.id,
    required this.minAmount,
    required this.maxAmount,
    required this.tokenAmount,
  });

  factory TokenTierModel.fromJson(Map<String, dynamic> json) {
    return TokenTierModel(
      id: json['_id'],
      minAmount: json['minAmount'],
      maxAmount: json['maxAmount'],
      tokenAmount: json['tokenAmount'],
    );
  }
}
