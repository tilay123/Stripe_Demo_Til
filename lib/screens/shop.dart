import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:flutter/services.dart';
import 'package:stripe_demo_til/model/product.dart';
import 'package:stripe_demo_til/screens/signin.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:uuid/uuid.dart';

class Shop extends StatefulWidget {
  @override
  _ShopState createState() => _ShopState();
}

// Part of this code is from my previous project:
// link: https://github.com/tilay123/Trivia-Voice-Recognition-Trainer/blob/master/lib/screens/shop.dart

class _ShopState extends State<Shop> {
  @override
  void initState() {
    StripePayment.setOptions(
        StripeOptions(publishableKey: 'YOUR API PUBLISHABLE KEY HERE'));

    // TODO: implement initState
    super.initState();
  }

  final List<Product> products = [
    Product(
        imagePath: "threeCoin-07.png",
        priceInDollars: 4.99,
        gameCurrencyAmount: 5500,
        gameCurrencyType: Product.coin),
    Product(
        imagePath: "coinPack-03.png",
        priceInDollars: 9.99,
        gameCurrencyAmount: 11000,
        gameCurrencyType: Product.coin),
    Product(
        imagePath: "coinPile-06.png",
        priceInDollars: 24.99,
        gameCurrencyAmount: 29000,
        gameCurrencyType: Product.coin),
    Product(
        imagePath: "twoDiamond-08.png",
        priceInDollars: 2.99,
        gameCurrencyAmount: 3,
        gameCurrencyType: Product.diamond),
    Product(
        imagePath: "threeDiamond-09.png",
        priceInDollars: 4.99,
        gameCurrencyAmount: 5,
        gameCurrencyType: Product.diamond),
    Product(
        imagePath: "fourDiamond-10.png",
        priceInDollars: 24.99,
        gameCurrencyAmount: 30,
        gameCurrencyType: Product.diamond),
    Product(
        imagePath: "diamond-04.png",
        priceInDollars: 99.99,
        gameCurrencyAmount: 15000,
        gameCurrencyType: Product.diamond),
  ];

  String currentUserId = FirebaseAuth.instance.currentUser.uid;

  Widget build(BuildContext context) {
    if (currentUserId == null) {
      goToSignInPage(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('gameData')
                .doc(currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("Coins: Loading... Diamond: Loading... ");
              } else {
                return Text(
                    "Coins: ${snapshot.data['coin']}  Diamond: ${snapshot.data['diamond']}");
              }
            }),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xffD4B483),
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                margin: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image(
                      height: 80,
                      width: 80,
                      image: AssetImage("asset/${products[index].imagePath}"),
                      fit: BoxFit.contain,
                    ),
                    Expanded(
                      child: Text(
                        "${products[index].gameCurrencyAmount} ${products[index].gameCurrencyType}",
                        style: TextStyle(fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedButton(
                      height: 50,
                      width: 80,
                      child: Text(
                        "\$${products[index].priceInDollars}",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green,
                      onPressed: () async =>
                          await _handlePayment(context, products[index]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: products.length,
      ),
    );
  }
}

_handlePayment(BuildContext context, Product product) async {
  print("Handing Payment");

  try {
    await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((PaymentMethod paymentMethod) async {
      ///print("Hello after Paasdasdas ${paymentMethod.toJson()}");

      // If User enters a valid card
      String currentUserId = FirebaseAuth.instance.currentUser.uid;
      if (currentUserId != null) {
        FirebaseFirestore.instance
            .collection('charges')
            .doc(currentUserId)
            .collection('userCharges')
            .doc()
            .set({
          'paymentMethodId': paymentMethod.id,
          'amount': product.priceInDollars *
              100, // stripe counts in cents. $1.99 is 199,
          'idempotencyKey': Uuid().v1(),
          'email': FirebaseAuth.instance.currentUser.email,
          'gameCurrencyType': product.gameCurrencyType,
          'gameCurrencyAmount': product.gameCurrencyAmount
        });
      } else {
        goToSignInPage(context);
      }
    });

    // var source =  StripePayment.createSourceWithParams(SourceParams(returnURL: null, type: null))
    // print(paymentMethod.toJson());

  } on PlatformException catch (error) {
    // user clicked on the cancelled button
    // do thing
    print("PlatformException");
  } catch (error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('${error.toString()}'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }
}

goToSignInPage(BuildContext context) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => SignIn()));
}
