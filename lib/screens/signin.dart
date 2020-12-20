import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stripe_demo_til/screens/shop.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // We need to initialize these variables before calling build
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  final formKey = new GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xff121212),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Stripe Demo',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: 'Enter email'),
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                  ),
                  // validator: (submittedText) {
                  //   if (submittedText.trim().length < 6) {
                  //     return 'Password must be at least 6 characters long';
                  //   }
                  //   return null;
                  // },
                ),
                RaisedButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    print('Submitting');
                    setState(() {
                      print("setting is loading to true");
                      _isLoading = true;
                    });
                    // if (formKey.currentState.validate()) {
                    //   formKey.currentState.save();

                    UserCredential user;
                    try {
                      user = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                    } catch (error) {
                      showDialog<void>(
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
                                  Navigator.of(dialogContext)
                                      .pop(); // Dismiss alert dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }

                    if (user != null) {
                      DocumentSnapshot gameData = await FirebaseFirestore
                          .instance
                          .collection('gameData')
                          .doc(user.user.uid)
                          .get();

                      if (!gameData.exists) {
                        await FirebaseFirestore.instance
                            .collection('gameData')
                            .doc(user.user.uid)
                            .set({'coin': 0, 'diamond': 0});
                      }

                      setState(() {
                        print("setting is loading to false");
                        _isLoading = false;
                      });
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Shop()),
                          (route) => false);
                    } else {
                      setState(() {
                        _isLoading = false;
                        print("setting is loading to false");
                      });
                    }
                    // }
                  },
                  color: Colors.cyan,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
