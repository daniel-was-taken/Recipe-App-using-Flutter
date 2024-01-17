import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_recipe_app/screens/meals_screen/screens/orders_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import './orders_screen.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

User? user = FirebaseAuth.instance.currentUser;

class _CartScreenState extends State<CartScreen> {
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _getPrice();
    _getShoppingIngredients();
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Successfull');
    _placeOrder();
    _deleteShoppingCart();
    Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    final snackBar = SnackBar(
      content: const Text('OOPS!.. ERROR OCCURED.'),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    final snackBar = SnackBar(
      content: const Text('EXTERNAL WALLET'),
    );
  }

  void _openCheckOut() async {
    print('testing payemtn');
    var options = {
      'key': ' your key ',
      'amount': 100 * sum,
      'name': 'test name',
      'description': 'test des',
      'prefill': {
        'contact': ' contact no ',
        'email': ' email address ',
      },
    };
    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  _deleteShoppingCart() {
    FirebaseFirestore.instance
        .collection("shoppingCart")
        .doc(user!.uid)
        .delete();
    FirebaseFirestore.instance
        .collection("shoppingCart")
        .doc('${user!.uid}cart')
        .delete();
  }

  _getShoppingIngredients() async {
    FirebaseFirestore.instance
        .collection('shoppingCart')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.get('cartIngredients');
      listForQty = data;
      _setShoppingCart();
    });
  }

  _updateListItems() {
    FirebaseFirestore.instance.collection('shoppingCart').doc(user!.uid).set({
      "cartIngredients": listForQty,
    });
    qtyCounts.clear();
    totalPrice.clear();
    listForQty.forEach((element) {
      if (!qtyCounts.containsKey(element)) {
        qtyCounts[element] = 1;
      } else {
        qtyCounts[element] += 1;
      }
    });
    _sort();
    print(qtyCounts);
  }

  var sortMapByValue = {};

  _sort() {
    setState(() {
      sortMapByValue = Map.fromEntries(qtyCounts.entries.toList()
        ..sort((e1, e2) => e2.value.compareTo(e1.value)));

      qtyCounts = sortMapByValue;
    });
    _getTotal();
  }

  _setShoppingCart() {
    listForQty.forEach((element) {
      if (!qtyCounts.containsKey(element)) {
        qtyCounts[element] = 1;
      } else {
        qtyCounts[element] += 1;
      }
    });
    _sort();
    FirebaseFirestore.instance
        .collection('shoppingCart')
        .doc('${user!.uid}cart')
        .set({"cartQty": qtyCounts});
  }

  _placeOrder() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('orders')
        .doc()
        .set({
      'Ingredients': qtyCounts,
      'PlacedAt': Timestamp.now(),
      'Total': sum
    });
  }

  List listForQty = [];

  Map qtyCounts = {};

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  Map modifyQty = {};
  Map<dynamic, dynamic> allPricedIngredients = {};

  _getPrice() {
    final pricedIngredientsRef = FirebaseFirestore.instance
        .collection("ingredients")
        .doc('availablePricedIngredients')
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.get('Ingredients');
      allPricedIngredients = data;
    });
  }

  _setTotal(dynamic totalAmount, dynamic qty) {
    return (totalAmount * qty).toString();
  }

  Map<dynamic, dynamic> allPricedCart = {};

  List<int> totalPrice = [];

  dynamic sum;

  _getTotal() {
    //sum = totalPrice.fold(sum, (sum, element) => sum! + element);
    //

    if(totalPrice.isEmpty) {
      qtyCounts.forEach((key, value) {
        if (allPricedIngredients.containsKey(key)) {
          var cal = allPricedIngredients[key] * qtyCounts[key];
          totalPrice.add(cal);
        }
      });

      
    }
    final int result = totalPrice.fold(0, (sum, element) => sum + element);
    
    setState(() {sum = result;});

    print(qtyCounts);

    //return sum;
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> qtyCollection =
        FirebaseFirestore.instance
            .collection('recipes')
            .doc('${user!.uid}cart')
            .snapshots();
    _getPricedIngredients(dynamic ingredient) {
      return allPricedIngredients[ingredient.toString()];
    }

    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
      ),
      body: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.all(10),
            child: Container(
              height: height * 0.75,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    //Stream builder get map

                    StreamBuilder<DocumentSnapshot<Map<dynamic, dynamic>>>(
                        stream: qtyCollection,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: const Text("Loading..."));
                          }

                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: qtyCounts.length,
                            itemBuilder: (context, index) {
                              String key = qtyCounts.keys.elementAt(index);
                              return ListTile(
                                title: Text(
                                  key.toString(),
                                ),
                                trailing: SizedBox(
                                  width: 200,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Qty: ' + qtyCounts[key].toString()),
                                      Text('Rs: ' +
                                          _setTotal(_getPricedIngredients(key),
                                              qtyCounts[key])),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              listForQty.remove(key);
                                              print(listForQty);
                                              setState(() {
                                                _updateListItems();
                                              });
                                            },
                                            icon: Icon(
                                              Icons.remove,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              listForQty.add(key);
                                              print(listForQty);
                                              setState(() {
                                                _updateListItems();
                                              });
                                            },
                                            icon: Icon(
                                              Icons.add,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: FloatingActionButton.extended(
                  label: sum == null
                      ? Text('Place Order')
                      : Text('Total Rs.$sum Place Order'),
                  onPressed: () {
                    if (qtyCounts.isNotEmpty) {
                      ///adding payment gateway

                      _openCheckOut();
                      // _placeOrder();

                      // Navigator.of(context)
                      //     .pushReplacementNamed(OrdersScreen.routeName);
                    } else {
                      var snackBar =
                          const SnackBar(content: Text('Please add items!'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
