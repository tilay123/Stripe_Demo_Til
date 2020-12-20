class Product {
  static String coin = 'Coins';
  static String diamond = 'Diamonds';

  Product(
      {this.gameCurrencyAmount,
      this.priceInDollars,
      this.imagePath,
      this.gameCurrencyType});

  String imagePath;
  double priceInDollars;
  int gameCurrencyAmount;
  String gameCurrencyType;
}
