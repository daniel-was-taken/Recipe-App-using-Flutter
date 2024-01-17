import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_recipe_app/screens/meals_screen/screens/cart_screen.dart';

import '../dummy_data.dart';

class MealDetailScreen extends StatefulWidget {
  static const routeName = '/meal-detail';

  final Function toggleFavorite;
  final Function isFavorite;

  MealDetailScreen(this.toggleFavorite, this.isFavorite);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  Widget buildSectionTitle(String text, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 200,
      width: 350,
      child: child,
    );
  }

  // var recipesDetail = FirebaseFirestore.instance.collection('recipes');
  User? user = FirebaseAuth.instance.currentUser;

  // var shoppingCart = FirebaseFirestore.instance.collection('shoppingCart');
  var ingredientsCount;

  var stepsCount;

  List _values = [];
  String _result = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getFavorite();
    _getShoppingCart();
    //add this
    _getPrice();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _getShoppingCart() {
    FirebaseFirestore.instance
        .collection('shoppingCart')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.get('cartIngredients');
      _values = data;
    });
  }

  // var favoritesCount;
  List _favorites = [];

  var _favoriteMeal = '';

  _someFunction() {
    return Scaffold(
      body: CircularProgressIndicator(),
    );
  }

  _getFavorite() {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('favorites')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot doc) {
        final data = doc.get('favorites');
        _favorites = data;
        setState(() {});
      });
    } catch (e) {
      //setState(() {});
    }
    //setState(() {});
  }

  _updateFavorites() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(user!.uid)
        .set({"favorites": _favorites});
  }

//add this

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
  // _setFavorite() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user!.uid)
  //       .collection('favorites')
  //       .doc(_favoriteMeal)
  //       .snapshots();
  // }

  @override
  Widget build(BuildContext context) {
    var isFavoriteBool;

    final mealId = ModalRoute.of(context)!.settings.arguments as String;
    _favoriteMeal = mealId;

    if (_favorites.contains(_favoriteMeal)) {
      isFavoriteBool = true;
    } else {
      isFavoriteBool = false;
    }

//add this
    _getPricedIngredients(dynamic ingredient) {
      return allPricedIngredients[ingredient.toString()].toString();
    }

    //_getIngredientsPrice() {}
    _getData() {
      final docRef =
          FirebaseFirestore.instance.collection("recipes").doc(mealId);

      docRef.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(data);
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('favRecipes')
            .doc(mealId)
            .set(data);
      });
    }

    _removeData() {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('favRecipes')
          .doc(mealId)
          .delete();
    }

    // final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == mealId);
    Stream<DocumentSnapshot<Map<String, dynamic>>> recipesCollection =
        FirebaseFirestore.instance
            .collection('recipes')
            .doc(mealId)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_basket_outlined),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(CartScreen.routeName);
            },
          ),
        ],
        title: StreamBuilder<DocumentSnapshot<Map<dynamic, dynamic>>>(
            stream: recipesCollection,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const Text("Loading..."));
              }
              return Text(snapshot.data!['title']);
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: StreamBuilder<DocumentSnapshot<Map<dynamic, dynamic>>>(
                  stream: recipesCollection,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const Text("Loading..."));
                    }
                    return Image.network(
                      snapshot.data!['recipeImage'],
                      fit: BoxFit.cover,
                    );
                  }),
            ),
            buildSectionTitle('Ingredients', context),
            buildContainer(
              StreamBuilder<DocumentSnapshot<Map<dynamic, dynamic>>>(
                  stream: recipesCollection,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const Text("Loading..."));
                    }
                    ingredientsCount = snapshot.data!['ingredients'].toList();
                    return ListView.builder(
                      itemBuilder: (ctx, index) => Card(
                        color: Theme.of(context).accentColor,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                snapshot.data!['ingredients'][index],
                              ),
                              //stream
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(snapshot.data!['ingredients'][index] ==
                                          null
                                      ? 'Loading'
                                      : 'Rs. ${_getPricedIngredients(snapshot.data!['ingredients'][index])}'),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.10,
                                  ),
                                  IconButton(
                                    tooltip: 'Add to Cart',
                                    splashColor: Colors.pink,
                                    onPressed: () {
                                      _values.add(
                                          snapshot.data!['ingredients'][index]);
                                      print(
                                          snapshot.data!['ingredients'][index]);
                                      print(_values);
                                      var snackBar = SnackBar(
                                        content: Text(
                                            '${snapshot.data!['ingredients'][index]} Added'),
                                        duration: Duration(
                                          milliseconds: 500,
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      FirebaseFirestore.instance
                                          .collection('shoppingCart')
                                          .doc(user!.uid)
                                          .set({
                                        "cartIngredients": _values,
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add,
                                    ),
                                  )
                                ],
                              )
                              //send ingredient to function
                            ],
                          ),
                        ),
                      ),
                      itemCount: ingredientsCount.length,
                    );
                  }),
            ),
            buildSectionTitle('Steps', context),
            buildContainer(
              StreamBuilder<DocumentSnapshot<Map<dynamic, dynamic>>>(
                  stream: recipesCollection,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const Text("Loading..."));
                    }
                    stepsCount = snapshot.data!['steps'].toList();
                    return ListView.builder(
                      itemBuilder: (ctx, index) => Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child: Text('# ${(index + 1)}'),
                            ),
                            title: Text(
                              snapshot.data!['steps'][index]['value'],
                            ),
                          ),
                          Divider()
                        ],
                      ),
                      itemCount: stepsCount.length,
                    );
                  }),
            ),
            StreamBuilder<DocumentSnapshot<Map<dynamic, dynamic>>>(
                stream: recipesCollection,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const Text("Loading..."));
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Recipe by - ' + snapshot.data!['username'],
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            isFavoriteBool ? Icons.star : Icons.star_border,
          ),
          onPressed: () {
            //_setFavorite();

            if (_favorites.contains(mealId)) {
              //delete doc
              _favorites.remove(mealId);
              _removeData();
              //delete doc
              var snackBar =
                  const SnackBar(content: Text('Removed from favorites'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              isFavoriteBool = false;
            } else {
              _favorites.add(mealId);
              _getData();
              var snackBar =
                  const SnackBar(content: Text('Added to favorites'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              isFavoriteBool = true;
            }
            setState(() {
              _updateFavorites();
            });
          }),
    );
  }
}
