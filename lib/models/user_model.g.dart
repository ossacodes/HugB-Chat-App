// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'user_model.dart';

// // **************************************************************************
// // RealmObjectGenerator
// // **************************************************************************

// class User extends _User with RealmEntity, RealmObjectBase, RealmObject {
//   User(
//     int id,
//     String username,
//     String password,
//     String email,
//   ) {
//     RealmObjectBase.set(this, 'id', id);
//     RealmObjectBase.set(this, 'username', username);
//     RealmObjectBase.set(this, 'password', password);
//     RealmObjectBase.set(this, 'email', email);
//   }

//   User._();

//   @override
//   int get id => RealmObjectBase.get<int>(this, 'id') as int;
//   @override
//   set id(int value) => RealmObjectBase.set(this, 'id', value);

//   @override
//   String get username =>
//       RealmObjectBase.get<String>(this, 'username') as String;
//   @override
//   set username(String value) => RealmObjectBase.set(this, 'username', value);

//   @override
//   String get password =>
//       RealmObjectBase.get<String>(this, 'password') as String;
//   @override
//   set password(String value) => RealmObjectBase.set(this, 'password', value);

//   @override
//   String get email => RealmObjectBase.get<String>(this, 'email') as String;
//   @override
//   set email(String value) => RealmObjectBase.set(this, 'email', value);

//   @override
//   Stream<RealmObjectChanges<User>> get changes =>
//       RealmObjectBase.getChanges<User>(this);

//   @override
//   User freeze() => RealmObjectBase.freezeObject<User>(this);

//   static SchemaObject get schema => _schema ??= _initSchema();
//   static SchemaObject? _schema;
//   static SchemaObject _initSchema() {
//     RealmObjectBase.registerFactory(User._);
//     return const SchemaObject(ObjectType.realmObject, User, 'User', [
//       SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
//       SchemaProperty('username', RealmPropertyType.string),
//       SchemaProperty('password', RealmPropertyType.string),
//       SchemaProperty('email', RealmPropertyType.string),
//     ]);
//   }
// }
