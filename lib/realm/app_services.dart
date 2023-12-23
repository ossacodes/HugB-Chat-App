import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:realm/realm.dart';

import '../screens/home_screen.dart';
import 'realm_services.dart';

class AppServices with ChangeNotifier {
  String id;
  Uri baseUrl;
  App app;
  User? currentUser;
  var box = Hive.box('myData');
  AppServices(this.id, this.baseUrl)
      : app = App(AppConfiguration(id, baseUrl: baseUrl));

  Future<User> logInUserEmailPassword(String email, String password) async {
    User loggedInUser =
        await app.logIn(Credentials.emailPassword(email, password));
    await box.put('id', loggedInUser.id);
    await box.put('isLoggedIn', true);
    print('user ${loggedInUser.id} logged in!');
    Get.offAll(
      const HomeScreen(),
    );
    currentUser = loggedInUser;
    notifyListeners();
    return loggedInUser;
  }

  Future<User> registerUserEmailPassword(
    RealmServices realmServices,
    String username,
    String email,
    String password,
  ) async {
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(email, password);
    User loggedInUser =
        await app.logIn(Credentials.emailPassword(email, password));
    currentUser = loggedInUser;
    await box.put('id', currentUser!.id);
    await box.put('isLoggedIn', true);

    // await collection.insertOne(
    //   MongoDocument(
    //     {
    //       'userId': value.id,
    //       'username': name,
    //       'email': email,
    //     },
    //   ),
    // );
    realmServices.createUser(
      username,
      currentUser!.id,
      email,
    );
    print('user ${currentUser!.id} logged in!');
    Get.offAll(
      const HomeScreen(),
    );
    notifyListeners();
    return loggedInUser;
  }

  Future<void> logOut() async {
    await currentUser?.logOut();
    currentUser = null;
  }
}
