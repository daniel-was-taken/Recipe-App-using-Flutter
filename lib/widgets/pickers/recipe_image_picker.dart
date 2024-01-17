import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RecipeImagePicker extends StatefulWidget {
  RecipeImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  State<RecipeImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<RecipeImagePicker> {
  File? _pickedImage;

  void _getFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
      //maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(pickedImageFile);
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.camera,
      //maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
   

    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: [
        Container(
          height: 150,
          child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.all(10),
            child: _pickedImage != null
                ? Image.file(
                    _pickedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Center(
                    child: Text(
                      'No Image Taken',
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
        TextButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Pick Image'),
              content: const Text('Select an option to add an image.'),
              
              actions: <Widget>[
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera),
                  label: Text('Add Image from Camera'),
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: _getFromGallery,
                  icon: Icon(Icons.image),
                  label: Text('Add Image from Gallery'),
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          child: const Text('Pick image'),
        ),
      ],
    );
  }
}
