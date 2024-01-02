import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:kam/features/user_auth/presentation/pages/login_page.dart';
import 'package:kam/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:kam/global/common/toast.dart';
import 'package:user_profile_avatar/user_profile_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String bio; //get bio from database

  late User? user = auth.currentUser;
  late String? username = user?.displayName;
  late String? email = user?.email;

  late TextEditingController _passwordController = TextEditingController();
  late TextEditingController _bioController =
      TextEditingController(text: username);

  bool isSigningUp = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
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
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username!,
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProfilePicture(
                      name: username.toString(),
                      radius: 90,
                      fontsize: 67.5,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Elektronski naslov: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email!,
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Geslo",
                  isPasswordField: true,
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    updatePassword();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: isSigningUp
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Spremeni geslo",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, "/login");
                  },
                  child: Container(
                    height: 45,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Izpis",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updatePassword() async {
    String? oldPassword = await showPasswordDialog();

    if (oldPassword == null) {
      showToast(message: "Sprememba gesla preklicana");
      return;
    }

    setState(() {
      isSigningUp = true;
    });

    String newPassword = _passwordController.text;

    if (newPassword != null && newPassword.trim() != "") {
      try {
        // Reauthenticate before updating the password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user?.email ?? '',
          password: oldPassword,
        );
        await user?.reauthenticateWithCredential(credential);

        // Update the password
        await user?.updatePassword(newPassword);

        showToast(message: "Geslo spremenjeno");
      } catch (e) {
        showToast(message: "Gesla ni bilo možno spremeniti. $e");
      }
    } else {
      showToast(message: "Novo geslo ni veljavno");
    }

    setState(() {
      isSigningUp = false;
    });

    Navigator.pop(context);
  }

  Future<String?> showPasswordDialog() async {
    TextEditingController _oldPasswordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          obscureText: true,
          controller: _oldPasswordController,
          decoration: InputDecoration(labelText: 'Vnesite staro geslo'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_oldPasswordController.text);
            },
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: Text("Preklic"),
          ),
        ],
      ),
    );
  }
}
