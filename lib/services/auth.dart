import 'package:firebase_auth/firebase_auth.dart';
import 'package:shareacab/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change user stream

  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged;
  }

  //sign in with email pass

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    var result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (result.user.isEmailVerified) {
      return true;
    } else {
      await result.user.sendEmailVerification();
      return false;
    }
  }

  Future<bool> checkVerification(FirebaseUser user) async {
    return user.isEmailVerified;
  }

  // sign up with email pass

  Future<void> registerWithEmailAndPassword({String email, String password, String name, String mobilenum, String hostel, String sex}) async {
    var result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    var user = result.user;
    // creating a new document for user
    await DatabaseService(uid: user.uid).enterUserData(name: name, mobileNumber: mobilenum, email: email, sex: sex);
    await result.user.sendEmailVerification();
  }

  Future<void> registerUser({String userid, String email, String phone, String name, String sex, String covid}) async {
    // creating a new document for user
    await DatabaseService(uid: userid).enterUserData(name: name, mobileNumber: phone, email: email, sex: sex, covid: covid);
  }

  Future<void> updateUser({String userid, String email, String phone, String name, String sex, String covid}) async {
    // creating a new document for user
    await DatabaseService(uid: userid).updateUserData(name: name, mobileNumber: phone, email: email, sex: sex, covid: covid);
  }


  // forgot password

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // verification mail resend

  Future<void> verificationEmail(FirebaseUser user) async {
    await user.sendEmailVerification();
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // is user verified check
  Future<bool> verificationcheck(FirebaseUser user) async {
    await user.reload();
    await user.getIdToken(refresh: true);
    await user.reload();
    var flag = await user.isEmailVerified;
    return flag;
  }

  Future<FirebaseUser> reloadCurrentUser() async {
    var oldUser = await FirebaseAuth.instance.currentUser();
    await oldUser.reload();
    var newUser = await FirebaseAuth.instance.currentUser();
    return newUser;
  }

  Future<String> getCurrentUID() async {
    var user = await _auth.currentUser();
    final uid = user.uid;
    return uid.toString();
  }

  // to update email
  Future<void> changeEmail(String newEmail) async {
    var user = await _auth.currentUser();
    await user.updateEmail(newEmail);
  }
}
