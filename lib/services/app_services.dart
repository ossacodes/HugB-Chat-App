import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:hugb/config/db_paths.dart';

class AppServices {
  final client = Client()
      .setEndpoint('https://exwoo.com/v1') // Your Appwrite Endpoint
      .setProject('6587168cbc8a1e9b32bb') // Your project ID
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
          Query.equal('senderId', [userId]),
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
              ],
      );

      docs = documents;

      return documents;
    } on AppwriteException catch (e) {
      print(e);
    }
    return docs;
  }
}
