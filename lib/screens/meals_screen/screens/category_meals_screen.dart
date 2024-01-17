import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/exit-popup.dart';

import '../widgets/meal_item.dart';

import '../models/meal.dart';

class Category_meals_screen extends StatefulWidget {
  static const routeName = '/category-meals';
  final List<Meal> _availableMeals;
  Category_meals_screen(this._availableMeals);

  @override
  State<Category_meals_screen> createState() => _Category_meals_screenState();
}

class _Category_meals_screenState extends State<Category_meals_screen> {
  late String categoryTitle;
  late List<Meal> displayedMeals;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    categoryTitle = routeArgs['title'] as String;
    final categoryId = routeArgs['id'];

    displayedMeals = widget._availableMeals.where((meal) {
      return meal.categories.contains(categoryTitle);
    }).toList();
  }
  
  void _removeMeal(String mealId) {
    setState(() {
      displayedMeals.removeWhere((meal) => meal.id == mealId);
    });
  }
  
  var recipesCount;
  var recipesCollection = FirebaseFirestore.instance.collection('recipes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: recipesCollection
            .where("categories", arrayContains: categoryTitle)
            .snapshots(),
        builder: (BuildContext context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const Text("Loading..."));
          }
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data!.docs;
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
      ),
    );
  }
}
