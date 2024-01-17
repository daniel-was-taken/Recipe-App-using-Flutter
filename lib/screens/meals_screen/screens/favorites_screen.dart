import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_recipe_app/screens/meals_screen/screens/cart_screen.dart';

import '../models/meal.dart';
import '../widgets/meal_item.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Meal> favoriteMeals;
  FavoritesScreen(this.favoriteMeals);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // @override
  // void initState() {
  //   _getFavoritesCollection();
  //   super.initState();
  // }

  // List listOfFavorites = [];

  // _getFavoritesCollection() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user!.uid)
  //       .collection('favorites')
  //       .doc(user!.uid)
  //       .get()
  //       .then((DocumentSnapshot doc) {
  //     final data = doc.get('');
  //     listOfFavorites = data;
  //   });
  // }
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> favCollection =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('favRecipes')
            .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: favCollection,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const Text("Loading..."));
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data!.docs;

        return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return MealItem(
                id: docs[index].data()['username'].toString(),
                title: docs[index].data()['title'].toString(),
                imageUrl: docs[index].data()['recipeImage'].toString(),
                duration: int.parse(docs[index].data()['duration']),
                complexity: docs[index].data()['complexity'].toString(),
                affordability: docs[index].data()['affordability'].toString(),
                recipeId: docs[index].reference.id.toString(),
              );
            });
      },
    );
  }
}
