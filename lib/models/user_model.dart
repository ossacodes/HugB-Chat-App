import 'package:realm/realm.dart';

part 'user_model.g.dart';

@RealmModel()
class _Users {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late String username;

  @MapTo('user_id')
  late String userId;

  late String email;
}
