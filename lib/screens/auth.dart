import "dart:io";

import "package:chat_app/widgets/auth_services.dart";
//import "package:firebase_core/firebase_core.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:chat_app/widgets/user_image_picker.dart";

final fireBase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isSignIn = true;
  var passwordVisibility = false;
  var _enteredEmail = "";
  var _enteredPassword = "";
  var _entredUsername = "";
  var _isAuthenticating = false;
  File? _selectedImage;

  void _onSubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      if (!_isSignIn && _selectedImage == null) {
        showDialog(
          context: context,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              height: 100,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: Text(
                "Please! uplode the image",
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
          ),
        );
      }
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isSignIn) {
        // signIn process
        final userCredential = await fireBase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        print(userCredential);
      } else {
        //creating new user credentials
        final userCredential = await fireBase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        // storing image of the user
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredential.user!.uid}.jpg");
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        //for storing user deatils in firestore
        await FirebaseFirestore.instance
            .collection("user")
            .doc(userCredential.user!.uid)
            .set({
          "username": _entredUsername,
          "e-mail": _enteredEmail,
          "image-url": imageUrl,
        });
        // print(imageUrl);
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        // showing error message
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey[400],
            content: Text(error.message ?? "Authentication Failed",
                style: const TextStyle(color: Colors.black)),
          ),
        );
      }
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Widget myInputFiled({
    required String hintText,
    required bool obscureText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    String? Function(String?)? validator,
    String? Function(String?)? onChanged,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey.shade600,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              passwordVisibility = !passwordVisibility;
            });
          },
          icon: Icon(
            suffixIcon,
            color: passwordVisibility ? Colors.black : Colors.grey.shade600,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      onSaved: onSaved,
    );
  }

  Widget myButton({required String buttonName}) {
    return GestureDetector(
      onTap: _onSubmit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 125),
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(8.0)),
        child: Text(buttonName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget squareTiles(
      {required String imagePath, required void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Image.asset(
          imagePath,
          height: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: _isAuthenticating
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isSignIn
                          ? Image.asset(
                              "assets/images/write.png",
                              height: 140,
                            )
                          : UserImagePicker(
                              pickedImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (!_isSignIn)
                                  myInputFiled(
                                      hintText: "Username",
                                      obscureText: false,
                                      prefixIcon: Icons.person,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty ||
                                            value.trim().length < 4) {
                                          return "Atleast 4 character ";
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _entredUsername = value!;
                                      }),
                                if (!_isSignIn)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                myInputFiled(
                                    hintText: "Email",
                                    obscureText: false,
                                    prefixIcon: Icons.person,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          !value.contains("@")) {
                                        return "Please enter valid email address ";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _enteredEmail = value!;
                                    }),
                                const SizedBox(
                                  height: 10,
                                ),
                                myInputFiled(
                                    hintText: "Password",
                                    obscureText: !passwordVisibility,
                                    prefixIcon: Icons.key,
                                    suffixIcon: passwordVisibility
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().length < 6) {
                                        return "Please enter  Atleast 6 characters";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _enteredPassword = value!;
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _enteredPassword = value!;
                                    }),
                                const SizedBox(
                                  height: 10,
                                ),
                                _isSignIn
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey[600],
                                            ),
                                            child: Text(_isSignIn
                                                ? "Forgot password?"
                                                : ""),
                                          ),
                                        ],
                                      )
                                    : myInputFiled(
                                        hintText: " Confirm Password",
                                        obscureText: false,
                                        prefixIcon: Icons.key,
                                        validator: (value) {
                                          if (value == null ||
                                              value != _enteredPassword) {
                                            return "Password does not match  ";
                                          }
                                          return null;
                                        }),
                                const SizedBox(height: 15),
                                myButton(
                                    buttonName:
                                        _isSignIn ? "Sign In" : "Sign Up"),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                      thickness: 0.5,
                                      color: Colors.grey.shade400,
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        "or continue with",
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(
                                      thickness: 0.5,
                                      color: Colors.grey.shade400,
                                    )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    squareTiles(
                                      imagePath: "assets/images/google.png",
                                      onTap: () =>
                                          AuthServices().signInWithGoogle(),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    squareTiles(
                                      imagePath: "assets/images/facebook.png",
                                      onTap: () =>
                                          AuthServices().signInWithFacebook(),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: _isSignIn
                                        ? "Not a member? "
                                        : "Already have an Account.| ",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  WidgetSpan(
                                    child: InkWell(
                                      splashColor: Colors.blue[200],
                                      onTap: () {
                                        setState(() {
                                          _isSignIn = !_isSignIn;
                                        });
                                      },
                                      child: Text(
                                        _isSignIn ? "Register Now" : "Sign In ",
                                        style:
                                            TextStyle(color: Colors.blue[400]),
                                      ),
                                    ),
                                  )
                                ])),
                              ],
                            )),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
