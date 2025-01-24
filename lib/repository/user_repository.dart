import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  final userRepo = Get.put(UserRepository());
  createUser(UserModel user) async {
    await _db
        .collection("Users")
        .add(
          user
              .toJson()
              .whenComplete(
                () => Get.snackbar(
                  "Success",
                  "Your account has been stored.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.green,
                ),
              )
              .catchError((error, stackTrace) {
                Get.snackbar(
                  "Erorr",
                  "Something went wrong. Try again",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.amber,
                );
                // ignore: avoid_print
                print(error.toString());
              }),
        );
  }
}
