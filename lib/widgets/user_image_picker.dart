import "dart:io";
import "dart:math";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.pickedImage});
  final void Function(File pickedImage) pickedImage;

  @override
  State<StatefulWidget> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _userImagePicked;

  void _imagePicker(ImageSource source) async {
    final pickedimage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedimage == null) return;

    setState(() {
      _userImagePicked = File(pickedimage.path);
    });

    widget.pickedImage(_userImagePicked!);
  }

  Widget foregroundCamera() {
    return Align(
      alignment: Alignment.bottomRight,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey[200],
        child: IconButton(
            onPressed: () {
              _showModalBottomSheet();
            },
            icon: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.black,
            )),
      ),
    );
  }

  void _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => _imagePicker(ImageSource.camera),
                icon: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.grey[700],
                ),
                label: const Text(
                  "Camera",
                  style: TextStyle(
                    color: Color.fromARGB(255, 72, 68, 68),
                  ),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              TextButton.icon(
                onPressed: () => _imagePicker(ImageSource.gallery),
                icon: Icon(
                  Icons.image,
                  color: Colors.grey[700],
                ),
                label: const Text(
                  "Choose from Gallery",
                  style: TextStyle(
                    color: Color.fromARGB(255, 72, 68, 68),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor randomColors =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];
    return _userImagePicked != null
        ? CircleAvatar(
            radius: 80.0,
            backgroundColor: randomColors,
            backgroundImage: FileImage(_userImagePicked!),
            child: foregroundCamera(),
          )
        : CircleAvatar(
            radius: 80.0,
            backgroundColor: Colors.grey[300],
            backgroundImage: const AssetImage("assets/images/man.png"),
            child: foregroundCamera(),
          );
  }
}
