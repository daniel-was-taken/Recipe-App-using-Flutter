import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    _deleteShoppingCart();
    super.initState();
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

  User? user = FirebaseAuth.instance.currentUser;

  var orderCollection = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: orderCollection
            .doc(user!.uid)
            .collection("orders")
            .orderBy("PlacedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const Text("Your orders will load here"));
          }

          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.data!.docs;

          return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    bottom: 8,
                    right: 20,
                    top: 8,
                  ),
                  child: Card(
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      height: height * 0.25,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMMMMEEEEd().format(
                                      docs[index].data()['PlacedAt'].toDate()),
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Ingredients: \n${docs[index].data()['Ingredients'].toString()}',
                                  style: TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  'Total: Rs. \n${docs[index].data()['Total'].toString()}',
                                  style: TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
                //return Text(docs[index].data().toString());
              });
        },
      ),
    );
  }
}
