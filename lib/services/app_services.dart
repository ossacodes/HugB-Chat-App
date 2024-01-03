import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:hugb/config/db_paths.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AppServices {
  final client = Client()
      .setEndpoint(DbPaths.projectEndPoint) // Your Appwrite Endpoint
      .setProject(DbPaths.project) // Your project ID
      .setSelfSigned();

  Future createUser(String userId, String username, String email) async {
    final databases = Databases(client);

    try {
      databases.createDocument(
        databaseId: DbPaths.database,
        collectionId: DbPaths.usersCollection,
        documentId: userId,
        data: {
          'userId': userId,
          'username': username,
          'email': email,
          'notificationToken': null,
        },
      );
    } on AppwriteException catch (e) {
      print(e);
    }
  }

  Future<DocumentList> getUsers({required String query}) async {
    final databases = Databases(client);
    DocumentList docs = DocumentList(
      documents: [],
      total: 0,
    );

    try {
      final documents = await databases.listDocuments(
        databaseId: DbPaths.database,
        collectionId: DbPaths.usersCollection,
        queries: query.trim() != ''
            ? [
                Query.equal('username', [query]),
                // Query.greaterThan('year', 1999)
              ]
            : [],
      );

      docs = documents;

      return documents;
    } on AppwriteException catch (e) {
      print(e);
    }
    return docs;
  }

  static String getChatId(String? currentUserNo, String? peerNo) {
    if (currentUserNo.hashCode <= peerNo.hashCode) {
      return '$currentUserNo-$peerNo';
    }
    return '$peerNo-$currentUserNo';
  }

  Future sendMessages({
    required String chatId,
    required String userId,
    required String receiverId,
    required String message,
    required bool seen,
    required String? notificationToken,
    required String username,
  }) async {
    final databases = Databases(client);
    final docId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await databases.createDocument(
        databaseId: DbPaths.database,
        collectionId: DbPaths.messagesCollection,
        documentId: docId,
        data: {
          'chatId': chatId,
          'senderId': userId,
          'receiverId': receiverId,
          'message': message,
          'seen': seen,
        },
      );

      if (notificationToken != null) {
        await sendNotification(
          notificationToken: notificationToken,
          title: username,
          body: message,
          peerId: receiverId,
          currentUserId: userId,
          msgId: docId,
        );
      }
    } on AppwriteException catch (e) {
      print(e);
    }
  }

  Future<DocumentList> getMessages({
    required String chatId,
    required String userId,
  }) async {
    final databases = Databases(client);
    DocumentList docs = DocumentList(
      documents: [],
      total: 0,
    );

    try {
      final documents = await databases.listDocuments(
        databaseId: DbPaths.database,
        collectionId: DbPaths.messagesCollection,
        queries: [
          Query.equal('chatId', [chatId]),
          // Query.equal('senderId', [userId]),
        ],
      );

      docs = documents;

      return documents;
    } on AppwriteException catch (e) {
      print(e);
    }
    return docs;
  }

  Future createChat({
    required String chatOwnerId,
    required String userId,
    required String currentMessage,
    required String username,
    required String email,
    required String? profileUrl,
  }) async {
    final databases = Databases(client);
    final docId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await databases.listDocuments(
        databaseId: DbPaths.database,
        collectionId: DbPaths.chatsCollection,
        queries: [
          Query.equal(
            'ownerId',
            [chatOwnerId],
          ),
          Query.equal(
            'userId',
            [userId],
          ),
        ],
      ).then((value) async {
        if (value.documents.isEmpty) {
          await databases.createDocument(
            databaseId: DbPaths.database,
            collectionId: DbPaths.chatsCollection,
            documentId: docId,
            data: {
              'ownerId': chatOwnerId,
              'userId': userId,
              'currentMessage': currentMessage,
              'username': username,
              'profileUrl': profileUrl,
              'email': email,
              'timestamp': int.parse(docId),
            },
          );
        } else {
          await databases.updateDocument(
            databaseId: DbPaths.database,
            collectionId: DbPaths.chatsCollection,
            documentId: value.documents[0].$id,
            data: {
              'ownerId': chatOwnerId,
              'userId': userId,
              'currentMessage': currentMessage,
              'username': username,
              'profileUrl': profileUrl,
              'email': email,
              'timestamp': int.parse(docId),
            },
          );
        }
      });
    } on AppwriteException catch (e) {
      print(e);
    }
  }

  Future updateChat({
    required String chatOwnerId,
    required String userId,
    required String currentMessage,
    required String username,
    required String email,
    required String? profileUrl,
  }) async {
    final databases = Databases(client);

    try {
      databases.updateDocument(
        databaseId: DbPaths.database,
        collectionId: DbPaths.chatsCollection,
        documentId: chatOwnerId,
        data: {
          'ownerId': chatOwnerId,
          'userId': userId,
          'currentMessage': currentMessage,
          'username': username,
          'profileUrl': profileUrl,
          'email': email,
        },
      );
    } on AppwriteException catch (e) {
      print(e);
    }
  }

  Future deleteChat({required String chatOwnerId}) async {
    final databases = Databases(client);

    try {
      databases.deleteDocument(
        databaseId: DbPaths.database,
        collectionId: DbPaths.chatsCollection,
        documentId: chatOwnerId,
      );
    } on AppwriteException catch (e) {
      print(e);
    }
  }

  Future<DocumentList> getChats({
    required String userId,
    required String query,
  }) async {
    final databases = Databases(client);
    DocumentList docs = DocumentList(
      documents: [],
      total: 0,
    );

    try {
      final documents = await databases.listDocuments(
        databaseId: DbPaths.database,
        collectionId: DbPaths.chatsCollection,
        queries: query.trim() != ''
            ? [
                Query.equal(
                  'username',
                  [query],
                ),
                Query.equal(
                  'userId',
                  [userId],
                ),
              ]
            : [
                Query.equal(
                  'ownerId',
                  [userId],
                ),
                Query.orderDesc('timestamp'),
              ],
      );

      docs = documents;

      return documents;
    } on AppwriteException catch (e) {
      print(e);
    }
    return docs;
  }

  //get chat user data
  Future<Document> getUserData({
    required String userId,
  }) async {
    final databases = Databases(client);
    late Document doc;

    try {
      final document = await databases.getDocument(
        databaseId: DbPaths.database,
        collectionId: DbPaths.usersCollection,
        documentId: userId,
      );

      doc = document;

      return document;
    } on AppwriteException catch (e) {
      print(e);
    }
    return doc;
  }

  // get unread message count
  Future<int> getUnreadMessageCount({
    required String userId,
  }) async {
    final databases = Databases(client);
    int count = 0;

    try {
      final document = await databases.listDocuments(
        databaseId: DbPaths.database,
        collectionId: DbPaths.messagesCollection,
        queries: [
          Query.equal('receiverId', [userId]),
          Query.equal('seen', [false]),
        ],
      );

      count = document.total;

      return count;
    } on AppwriteException catch (e) {
      print(e);
    }
    return count;
  }

// send call wake notification
  static Future sendCallWake({
    required String notificationToken,
    required String title,
    required String body,
    // required String peerNo,
    // required String currentUserNo,
    required String username,
    required String profileUrl,
    required String id,
    required String type,
  }) async {
    var uuid = const Uuid();
    try {
      await http
          .post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAV21eCqs:APA91bE8Wf5RprOXlSs7SL45xGBWFgfmxAy_KqBLgtUqGz-nWmA9JuR2zvL92XuOuekAd2PWsqrYlkE7uLIQNaOMtvB-PPvETuA1Iob6npyXPQan-CToQhQDzY7zi4e5MBv0XJkWQK6U'
            },
            body: json.encode({
              "to": notificationToken,
              "message": {
                "token": notificationToken,
              },
              "data": {
                "uuid": uuid.v4(),
                "caller_id": id,
                "caller_name": username,
                "caller_id_type": id,
                'call_image': profileUrl,
                "type": type,
              },
              "android": {"priority": "high"},
              "notification": {
                "title": title,
                "body": body,
                // "android_channel_id": "high_importance_channel",
              }
            }),
          )
          .then((value) => print(value.body));
    } catch (e) {
      print(e);
    }
  }

  static Future sendNotification({
    required String notificationToken,
    required String title,
    required String body,
    required String peerId,
    required String currentUserId,
    required String msgId,
  }) async {
    try {
      await http
          .post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAV21eCqs:APA91bE8Wf5RprOXlSs7SL45xGBWFgfmxAy_KqBLgtUqGz-nWmA9JuR2zvL92XuOuekAd2PWsqrYlkE7uLIQNaOMtvB-PPvETuA1Iob6npyXPQan-CToQhQDzY7zi4e5MBv0XJkWQK6U'
            },
            body: json.encode({
              "to": notificationToken,
              "message": {
                "token": notificationToken,
              },
              "data": {
                "recipient": peerId,
                'sender': currentUserId,
              },
              "android": {
                "notification": {
                  "tag": msgId,
                },
              },
              "apns": {
                "headers": {
                  'apns-collapse-id': msgId,
                },
              },
              "notification": {
                "title": title,
                "body": body,
                "android_channel_id": "calls_channel",
              }
            }),
          )
          .then((value) => print(value.body));
    } catch (e) {
      print(e);
    }
  }
}
