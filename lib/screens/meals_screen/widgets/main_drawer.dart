import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_recipe_app/screens/meals_screen/screens/cart_screen.dart';
import 'package:my_recipe_app/screens/meals_screen/screens/orders_screen.dart';
import '../new_recipe_screen/add_recipe_screen.dart';
import '../screens/filters_screen.dart';

class MainDrawer extends StatefulWidget {
  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  Widget buildListTile(
      String title, IconData icon, Color color, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'RobotoCondensed',
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      textColor: color,
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    //final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = FirebaseAuth.instance.currentUser;
//TODO Add your own Collection Name instead of 'users'
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
        
    return Drawer(
      child: Column(
        children: [
          Container(
            height: height * 0.2,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).accentColor,
            child: StreamBuilder<DocumentSnapshot<Object?>>(
                stream: usersCollection.doc(user!.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Let's cook");
                  }
                  final userName = snapshot.data!['username'];
                  return Text(
                    "Let's cook,\n${userName}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: Theme.of(context).primaryColor),
                  );
                }),
          ),
          SizedBox(
            height: height * 0 + 10,
          ),
          buildListTile('Meals', Icons.restaurant, Colors.black, () {
            Navigator.of(context).pushReplacementNamed('/');
          }),
          // buildListTile('Filters', Icons.settings, Colors.black, () {
          //   Navigator.of(context).pushNamed(FiltersScreen.routeName);
          // }),
          buildListTile('Cart', Icons.shopping_basket, Colors.black, () {
            Navigator.of(context).pushNamed(CartScreen.routeName);
          }),
          buildListTile('Orders', Icons.receipt, Colors.black, () {
            Navigator.of(context).pushNamed(OrdersScreen.routeName);
          }),
          buildListTile('Add Recipe', Icons.add, Colors.black, () {
            Navigator.of(context).pushNamed(AddRecipeScreen.routeName);
          }),
          buildListTile('Logout', Icons.exit_to_app, Colors.red, () {
            FirebaseAuth.instance.signOut();
          }),
        ],
      ),
    );
  }
}
