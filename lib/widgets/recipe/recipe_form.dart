import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pickers/recipe_image_picker.dart';

class RecipeForm extends StatefulWidget {
  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  static List friendsList = [null];
  String _username = 'unavailable';

  int _count = 0;
  List<Map<String, dynamic>> _values = [];
  String _result = '';

  //For Recipe
  //Recipe Title
  var recipeTitle = '';
  var recipeDuration = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    _getUserName();
    _count = 0;
    _result = '';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }


  _row(int key) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: (val) {
                _onUpdate(key, val);
              },
              
              decoration: InputDecoration(
                labelText: 'Step ${key + 1}',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _onUpdate(int key, String val) async {
    int foundKey = -1;
    for (var map in _values) {
      if (map.containsKey("id")) {
        if (map["id"] == key) {
          foundKey = key;
          break;
        }
      }
    }
    if (-1 != foundKey) {
      _values.removeWhere((map) {
        return map["id"] == foundKey;
      });
    }
    Map<String, dynamic> json = {
      "id": key,
      "value": val,
    };
    _values.add(json);
    setState(() {
      _result = _prettyPrint(_values);
    });
  }

  String _prettyPrint(jsonObject) {
    var encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(jsonObject);
  }

  //Affordability
  static const List<String> affordibiliyList = <String>[
    'Affordable',
    'Pricey',
    'Luxurious',
  ];
  String dropdownAffordibiliyValue = affordibiliyList.first;
  //Complexity
  static const List<String> complexityList = <String>[
    'Simple',
    'Challenging',
    'Hard',
  ];
  String dropdownComplexityValue = complexityList.first;
  //ImageURL
  File? _recipeImageFile;
  //Duration
  var duration = '';
  //Steps

  //Filters
  // bool isGlutenFree = false;
  // bool isLactoseFree = false;
  // bool isVegetarian = false;
  // bool isVegan = false;

  void _pickedImage(File image) {
    _recipeImageFile = image;
  }

  List<String> userIngredientsChecked = [];

  void _onSelectedIngredients(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userIngredientsChecked.add(dataName);
      });
    } else {
      setState(() {
        userIngredientsChecked.remove(dataName);
      });
    }
  }

  List<String> userCategoriesChecked = [];
  void _onSelectedCategories(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userCategoriesChecked.add(dataName);
      });
    } else {
      setState(() {
        userCategoriesChecked.remove(dataName);
      });
    }
  }

  var ingredientsCount;
  var categoryCount;

  Widget buildCheckboxListTile(
      String cateTitle, bool category, VoidCallback tapHandler) {
    return CheckboxListTile(
      title: Text(cateTitle),
      value: category,
      onChanged: (value) {
        setState(tapHandler);
      },
    );
  }

  Widget _buildSwitchListTile(
    String title,
    String description,
    bool currentValue,
    Function(bool) updateValue,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      activeTrackColor: Theme.of(context).primaryColor,
      subtitle: Text(
        description,
      ),
      onChanged: updateValue,
    );
  }

  //init

  Future<void> _getUserName() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc((await FirebaseAuth.instance.currentUser!).uid)
        .get()
        .then((value) {
      setState(() {
        _username = value['username'].toString();
      });
    });
  }

  Future<void> _getRecipeImageUrl() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('recipe_images')
        .child('${_username + recipeTitle}.jpg');

    await ref.putFile(_recipeImageFile!);
    final url = await ref.getDownloadURL();

    setState(() {
      recipeUrl = url;
      print(url);
    });
  }

  var recipeUrl;

  void _sendMessage() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('recipe_images')
        .child('${_username + recipeTitle}.jpg');

    await ref.putFile(_recipeImageFile!);
    final url = await ref.getDownloadURL();
    FirebaseFirestore.instance.collection('recipes').add({
      'createdAt': Timestamp.now(),
      'username': _username,
      'categories': userCategoriesChecked,
      'title': recipeTitle,
      'affordability': dropdownAffordibiliyValue,
      'complexity': dropdownComplexityValue,
      // 'filters': {
      //   'gluten-free': isGlutenFree,
      //   'lactose-free': isLactoseFree,
      //   'vegetarian': isVegetarian,
      //   'vegan': isVegan,
      // },
      'ingredients': userIngredientsChecked,
      'duration': recipeDuration,
      'steps': _values,
      'recipeImage': url,
    });

    var snackBar = const SnackBar(content: Text('Recipe Added!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    nameController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> ingredientsCollection =
        FirebaseFirestore.instance
            .collection('ingredients')
            .doc('availableIngredients')
            .snapshots();

    Stream<DocumentSnapshot<Map<String, dynamic>>> categoriesCollection =
        FirebaseFirestore.instance
            .collection('categories')
            .doc('availableCategories')
            .snapshots();

    double height = MediaQuery.of(context).size.height;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Recipe Category
                const Text(
                  'Select Categories',
                  style: TextStyle(fontSize: 20),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Container(
                    height: height * 0.5,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                          //listtiles
                          StreamBuilder<
                              DocumentSnapshot<Map<dynamic, dynamic>>>(
                            stream: categoriesCollection,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              ingredientsCount =
                                  snapshot.data!['categories'].toList();
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: ingredientsCount.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                        snapshot.data!['categories'][index]),
                                    trailing: Checkbox(
                                      value: userCategoriesChecked.contains(
                                          snapshot.data!['categories'][index]),
                                      onChanged: (val) {
                                        _onSelectedCategories(
                                          val!,
                                          snapshot.data!['categories'][index],
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //Recipe Title
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Recipe',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          key: ValueKey('recipeTitle'),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.sentences,
                          enableSuggestions: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Recipe Title',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              recipeTitle = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                //Recipe Affordibility
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Affordability',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String?>(
                          value: dropdownAffordibiliyValue,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle_outlined,
                          ),
                          items: affordibiliyList
                              .map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value!),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              dropdownAffordibiliyValue = value!;
                              print(dropdownAffordibiliyValue);
                            });
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Recipe Complexity
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Complexity',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          value: dropdownComplexityValue,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle_outlined,
                          ),
                          items: complexityList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              dropdownComplexityValue = value!;
                            });
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Duration
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Duration',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          key: ValueKey('duration'),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.sentences,
                          enableSuggestions: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter the duration (in minutes)',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              recipeDuration = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                //Recipe Filters
                // Card(
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   margin: EdgeInsets.all(10),
                //   child: Column(
                //     children: [
                //       const Padding(
                //         padding: EdgeInsets.all(8.0),
                //         child: Text(
                //           'Filters',
                //           style: TextStyle(fontSize: 20),
                //         ),
                //       ),
                //       _buildSwitchListTile(
                //         'Gluten-free',
                //         'Only include gluten-free meals',
                //         isGlutenFree,
                //         (value) {
                //           setState(() {
                //             isGlutenFree = value;
                //           });
                //         },
                //       ),
                //       _buildSwitchListTile(
                //         'Lactose-free',
                //         'Only include lactose-free meals',
                //         isLactoseFree,
                //         (value) {
                //           setState(() {
                //             isLactoseFree = value;
                //           });
                //         },
                //       ),
                //       _buildSwitchListTile(
                //         'Vegetarian',
                //         'Only include vegetarian meals',
                //         isVegetarian,
                //         (value) {
                //           setState(() {
                //             isVegetarian = value;
                //           });
                //         },
                //       ),
                //       _buildSwitchListTile(
                //         'Vegan',
                //         'Only include vegan meals',
                //         isVegan,
                //         (value) {
                //           setState(() {
                //             isVegan = value;
                //           });
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                //Recipe Ingredients
                const Text(
                  'Select Ingredients',
                  style: TextStyle(fontSize: 20),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Container(
                    height: height * 0.5,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                          //listtiles
                          StreamBuilder<
                              DocumentSnapshot<Map<dynamic, dynamic>>>(
                            stream: ingredientsCollection,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              ingredientsCount =
                                  snapshot.data!['ingredients'].toList();
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: ingredientsCount.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                        snapshot.data!['ingredients'][index]),
                                    trailing: Checkbox(
                                      value: userIngredientsChecked.contains(
                                          snapshot.data!['ingredients'][index]),
                                      onChanged: (val) {
                                        _onSelectedIngredients(
                                          val!,
                                          snapshot.data!['ingredients'][index],
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //Recipe Steps
                const Text(
                  'Steps',
                  style: TextStyle(fontSize: 20),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Add your steps'),
                        Container(
                          height: height * 0.25, //0.1 -
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _count,
                                  itemBuilder: (context, index) {
                                    return _row(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                setState(() {
                                  _count++;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                setState(() {
                                  _count--;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                //Recipe Image
                RecipeImagePicker(_pickedImage),
                //Sized Box
                const SizedBox(
                  height: 20,
                ),
                //Recipe Submit
                FloatingActionButton.extended(
                  label: const Text('Submit'),
                  onPressed: () {
                    if (recipeTitle != '') {
                      _sendMessage();
                    } else {
                      print(_values);
                      var snackBar = const SnackBar(
                          content: Text('Please add required info!'));

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
