import 'dart:math';

import 'package:flutter/material.dart';
import '../dummy_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../widgets/category_item.dart';

class CategoriesScreen extends StatelessWidget {
  var categoriesCount;

  CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categories');
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Object?>>(
        stream: categoryCollection.doc('availableCategories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const Text("Loading..."));
          }
          categoriesCount = snapshot.data!['categories'].toList();
          return GridView.builder(
            padding: const EdgeInsets.all(25),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (BuildContext context, int index) {
              Color _randomColor =
                  Colors.primaries[Random().nextInt(Colors.primaries.length)];
              return CategoryItem(
                index.toString(),
                snapshot.data!['categories'][index],
                _randomColor,
              );
            },
            itemCount: categoriesCount.length,
          );
        });
    return GridView(
        padding: const EdgeInsets.all(25),
        children: DUMMY_CATEGORIES
            .map(
              (catData) => CategoryItem(
                catData.id,
                catData.title,
                catData.color,
              ),
            )
            .toList(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
      );
    }
  }
//}
