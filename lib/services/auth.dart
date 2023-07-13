// ignore_for_file: use_build_context_synchronously

import 'package:toy_exchange_app/constants/widgets.dart';
import 'package:toy_exchange_app/screens/auth/email_verify_screen.dart';
import 'package:toy_exchange_app/screens/location_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toy_exchange_app/screens/main_navigatiion_screen.dart';

import '../constants/validators.dart';
import '../screens/admin/admin_home_screen.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();
  User? currentUser = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');
  CollectionReference reports =
  FirebaseFirestore.instance.collection('reports');

  Future<void> getAdminCredentialPhoneNumber(BuildContext context, user) async {
    final QuerySnapshot userDataQuery =
        await users.where('uid', isEqualTo: user!.uid).get();
    List<DocumentSnapshot> wasUserPresentInDatabase = userDataQuery.docs;
    if (wasUserPresentInDatabase.isNotEmpty) {
      Navigator.pushReplacementNamed(context, LocationScreen.screenId);
    }
  }



  Future<DocumentSnapshot> getAdminCredentialEmailAndPassword(
      {required BuildContext context,
      required String email,
      String? firstName,
      String? lastName,
      required String password,
      required bool isLoginUser}) async {
    DocumentSnapshot result = await users.doc(email).get();
    if (kDebugMode) {
      print(result);
    }
    try {
      if(email == kAdminEmail){
        loadingDialogBox(context, 'Validating details');
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if(credential.user!.uid !=null){
          loginUser = "admin";
          Navigator.pushReplacementNamed(context, AdminHomeScreen.screenId);
          print('admin user');
        }
      }else if (isLoginUser) {
        print('loggin user');
        signInWithEmail(context, email, password);
      } else {
        if (result.exists) {
          customSnackBar(
              context: context,
              content: 'An account already exists with this email');
        } else {
          registerWithEmail(context, email, password, firstName!, lastName!);
        }
      }
    } catch (e) {
      customSnackBar(context: context, content: e.toString());
    }
    return result;
  }

  signInWithEmail(BuildContext context, String email, String password) async {
    try {
      loadingDialogBox(context, 'Validating details');
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (kDebugMode) {
        print(credential);
      }
      Navigator.pop(context);
      if (credential.user!.uid != null) {
        if(await getBlocked()){
          customSnackBar(context: context, content: "Your are blocked by admin\ndue to voilation of our term and services.");
        }else{
          loginUser = "user";
          Navigator.pushNamedAndRemoveUntil(context, LocationScreen.screenId,(route) => false);
        }

      } else {
        customSnackBar(
            context: context, content: 'Please check with your credentials');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        customSnackBar(
            context: context, content: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        customSnackBar(
            context: context,
            content: 'Wrong password provided for that user.');
      }
    }
  }

  void registerWithEmail(BuildContext context, String email, String password,
      String firstName, String lastName) async {
    try {
      loadingDialogBox(context, 'Validating details');

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Map address = {
        "email": "email",
        "mobile" : "+923",
      };

      return users.doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': "$firstName $lastName",
        'email': email,
        'mobile': '+923',
        'address': '',
        'contact_details': address,
        'isBlocked': false,
      }).then((value) async {
          Navigator.pushNamedAndRemoveUntil(context, MainNavigationScreen.screenId,(route) => false);
        customSnackBar(context: context, content: 'Registered successfully');
      }).catchError((onError) {
        if (kDebugMode) {
          print(onError);
        }
        customSnackBar(
            context: context,
            content:
                'Failed to add user to database, please try again $onError');
      });
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        customSnackBar(
            context: context, content: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        customSnackBar(
            context: context,
            content: 'The account already exists for that email.');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      customSnackBar(
          context: context, content: 'Error occured: ${e.toString()}');
    }
  }

  Future<void> deleteProducts(String itemId,context) async {
    loadingDialogBox(context, 'Please wait!!');
    try{
     await products.doc(itemId).delete().then((value) => Navigator.pop(context));
    }catch(e){
      customSnackBar(
          context: context, content: 'Error occured: ${e.toString()}');
    }

  }
  Future<void> deleteCategory(String itemId,context) async {
    loadingDialogBox(context, 'Please wait!!!');
    try{
      await categories.doc(itemId).delete().then((value) => Navigator.pop(context));
    }catch(e){
      customSnackBar(
          context: context, content: 'Error occured: ${e.toString()}');
    }

  }
  Future<void> updateUid(String itemId,context) async {
    try{
      await products.doc(itemId).update({'uid': itemId});
    }catch(e){

    }

  }
  Future<void> updateIsRead(String itemId,context) async {
    try{
      await reports.doc(itemId).update({'isRead': true});
    }catch(e){

    }

  }
  Future<void> blockUser(String uid,context) async {
    try{
      await users.doc(uid).update({'isBlocked': true}).then((value) => Navigator.pop(context));
      customSnackBar(context: context, content: "The users is blocked successfully");
    }catch(e){
      customSnackBar(context: context, content: "Error $e");
    }

  }

  void submitReport(BuildContext context, String report,String reportTo, String reportBy,String reportedUser) async {
    try {
      loadingDialogBox(context, 'Reporting. Please wait!!!');
      final newReport = reports.doc();
       newReport.set({
         'uid': newReport.id,
         'report': report,
         'reportBy': reportBy,
         'reportedUser': reportedUser,
         'reportTo': reportTo,
         'isRead': false,
         'date': DateTime.now().toString(),
      }).then((value) async {
        customSnackBar(context: context, content: 'Report successfully submitted');
        Navigator.pop(context);
      }).catchError((onError) {
        if (kDebugMode) {
          print(onError);
        }
        customSnackBar(
            context: context,
            content:
            'Failed to submit report, please try again $onError');
      });
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      customSnackBar(
          context: context, content: 'Error occured: ${e.toString()}');
    }
  }
  Future<bool> getBlocked() async {
    return await users.doc(_firebaseAuth.currentUser!.uid).get().then((value) => bool.parse(value['isBlocked'].toString()));
  }

}
