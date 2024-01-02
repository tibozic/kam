import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/userData.dart';
import 'package:kam/features/user_auth/presentation/pages/login_page.dart';
import 'package:kam/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:kam/global/common/toast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Kam?",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Registracija",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                FormContainerWidget(
                  controller: _nameController,
                  hintText: "Ime",
                  isPasswordField: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite ime';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                FormContainerWidget(
                  controller: _surnameController,
                  hintText: "Priimek",
                  isPasswordField: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite priimek';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Elektronski naslov",
                  isPasswordField: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite elektronski naslov';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Geslo",
                  isPasswordField: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite geslo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    _signUp();
                  },
                  child: isSigningUp
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Že imate račun?"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Vpis",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSigningUp = true;
      });

      String name = _nameController.text;
      String surname = _surnameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      User? user = await _auth.signUpWithEmailAndPassword(email, password);
      await user?.updateDisplayName(name + " " + surname);

      if (user != null) {
        final docUser =
            FirebaseFirestore.instance.collection("users").doc(user?.uid);

        int radndomInt;
        String tag;

        while (true) {
          radndomInt = Random().nextInt(100000) + 10000;
          tag = name[0] + surname[0] + "#" + radndomInt.toString();

          final usersCollection =
              FirebaseFirestore.instance.collection("users");
          final query = usersCollection.where("tag", isEqualTo: tag);

          final querySnapshot = await query.get();

          if (querySnapshot.docs.isEmpty) {
            break;

            /*for (final doc in querySnapshot.docs) {
              print("Document ID: ${doc.id}, Data: ${doc.data()}");
            }*/
          }
        }

        final profileData = userData(
            uid: user!.uid,
            role: "user",
            name: name,
            surname: surname,
            tag: tag);

        final json = profileData.toJson();

        await docUser.set(json);
      }
      setState(() {
        isSigningUp = false;
      });

      if (user != null) {
        showToast(message: "Uporabnik uspešno registriran");
        Navigator.pushNamed(context, "/home");
      } else {
        showToast(message: "An error occurred, please try again later");
      }
    }
  }
}
