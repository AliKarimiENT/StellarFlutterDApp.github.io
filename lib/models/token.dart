class Token {
  final String image;
  final String name;
  final String symbol;
  final String issuerName;
  final String issuerAccountId;
  double value; // value in xlm
  int balance; // amount of token that user has
  bool trusted;
  int limit;
  Token({
    required this.image,
    required this.name,
    required this.symbol,
    required this.issuerName,
    required this.issuerAccountId,
    required this.value,
    required this.balance,
    required this.trusted,
    required this.limit,
  });
}
