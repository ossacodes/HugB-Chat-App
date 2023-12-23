import 'package:flutter/material.dart';
import 'package:hugb/models/user_model.dart';
import 'package:realm/realm.dart';

class RealmServices with ChangeNotifier {
  late Realm realm;
  User? currentUser;
  App app;
  bool showAll = false;
  static const String queryAllName = "getAllItemsSubscription";
  static const String queryMyItemsName = "getMyItemsSubscription";

  RealmServices(this.app) {
    if (app.currentUser != null || currentUser != app.currentUser) {
      currentUser ??= app.currentUser;
      realm = Realm(Configuration.flexibleSync(currentUser!, [Users.schema], path: 'myRealm.realm'));
      showAll = (realm.subscriptions.findByName(queryAllName) != null);
      if (realm.subscriptions.isEmpty) {
        updateSubscriptions();
      }
    }
  }

  Future<void> updateSubscriptions() async {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
      if (showAll) {
        mutableSubscriptions.add(realm.all<Users>(), name: queryAllName);
      } else {
        mutableSubscriptions.add(
            realm.query<Users>(r'userId == $0', [currentUser?.id]),
            name: queryMyItemsName);
      }
    });
    await realm.subscriptions.waitForSynchronization();
  }

  void createUser(String username, String userId, String email) {
    final newItem = Users(
      ObjectId(),
      username,
      userId,
      email,
    );
    realm.write<Users>(() => realm.add<Users>(newItem));
    notifyListeners();
  }

  Future<void> close() async {
    if (currentUser != null) {
      await currentUser?.logOut();
      currentUser = null;
    }
    realm.close();
  }

  @override
  void dispose() {
    realm.close();
    super.dispose();
  }
}
