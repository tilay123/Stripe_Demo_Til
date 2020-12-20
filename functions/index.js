// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


// 1. RUN(in cmd or terminal): firebase functions:config:set someservice.key="THE API KEY" someservice.id="THE CLIENT ID"
// example: firebase functions:config:set stripe.secret="sdfdsfsdfdfdgh"
// doc: https://firebase.google.com/docs/functions/config-env

// 2. Then deploy the functions:
//    RUN: firebase deploy --only functions
// OR RUN: firebase deploy --only "functions:createStripePayment"



const firestore = admin.firestore();
const settings = { timestampInSnapshots: true };
firestore.settings(settings);

const stripe = require('stripe')(functions.config().stripe.secret);

exports.createStripePayment = functions.firestore
  .document('charges/{userId}/userCharges/{docId}')
  .onCreate(async (snapshot, context) => {
    const { amount, paymentMethodId, idempotencyKey, email, gameCurrencyType, gameCurrencyAmount } = snapshot.data();
    try {
      // Create a charge using the idempotency key
      // to protect against double charges.

      const payment = await stripe.paymentIntents.create( // doc: https://stripe.com/docs/api/payment_intents/create
        {
          amount: amount,
          currency: 'usd',
          payment_method: paymentMethodId,
          confirm: true,
          receipt_email: email
          //   confirmation_method: 'automatic',  // 'automatic' is Default
        },
        { idempotencyKey }
      );

      if (payment.status === 'succeeded') {
        // If the result is successful, write it to the database.
        const fireStoreGameDataRef = admin.firestore().collection('gameData').doc(context.params.userId)
        const doc = await fireStoreGameDataRef.get()

        // finally update users game currency
        if (gameCurrencyType === 'Coins') {

          const updatedValue = doc.data().coin + gameCurrencyAmount;

          await admin.firestore().collection('gameData').doc(context.params.userId).update({ coin: updatedValue })

        } else if (gameCurrencyType === 'Diamonds') {

          const updatedValue = doc.data().diamond + gameCurrencyAmount;

          await admin.firestore().collection('gameData').doc(context.params.userId).update({ diamond: updatedValue })

        }
        await snapshot.ref.set(payment, { merge: true });
      }

    } catch (error) {
      // print the error in firebase console
      console.log(error);
      await snap.ref.set({ error: error.message }, { merge: true });
    }
  });