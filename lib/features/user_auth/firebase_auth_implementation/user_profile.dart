// user_profile.dart
/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String uid;
  String displayName;
  String email;
  String profileURL;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.profileURL,
  });

  factory UserProfile.fromSharedPreferences(SharedPreferences prefs) {
    return UserProfile(
      uid: prefs.getString('uid') ?? '',
      displayName: prefs.getString('displayName') ?? '',
      email: prefs.getString('email') ?? '',
      profileURL: prefs.getString('profileURL') ?? '',
    );
  }
}*/
/*
Future<UserProfile> getUserProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check local storage first
  String uid = prefs.getString('uid') ?? '';
  if (uid.isNotEmpty) {
    return UserProfile.fromSharedPreferences(prefs);
  }

  // If not available locally, fetch from Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User? user = _auth.currentUser;

  final FirebaseAuthService auth = FirebaseAuthService();

  // Save fetched user data locally
  await auth.saveUserDataLocally(user);

  return UserProfile.fromSharedPreferences(prefs);
}*/
