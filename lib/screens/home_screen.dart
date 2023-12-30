import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/auth/login_screen.dart';
import 'package:hugb/config/db_paths.dart';
import 'package:hugb/screens/widgets/search_delegate.dart';
import 'package:skeleton_animation/skeleton_animation.dart';
import '../models/chats_model.dart';
import '../services/app_services.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var box = Hive.box('myData');

  final _firebaseMessaging = FirebaseMessaging.instance;

  List<ChatsModel> chats = [
    ChatsModel(
      avatar:
          'https://images.unsplash.com/photo-1681640779209-23a76697fd1e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDJ8dG93SlpGc2twR2d8fGVufDB8fHx8fA%3D%3D',
      username: 'Jane Doe',
      recentMessage: 'Hello',
      unreadMessagesCount: 2,
    ),
    ChatsModel(
      avatar:
          'https://images.unsplash.com/photo-1700504312241-d6ef93ce35f1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDh8dG93SlpGc2twR2d8fGVufDB8fHx8fA%3D%3D',
      username: 'John Brad',
      recentMessage: 'Hi',
      unreadMessagesCount: 0,
    ),
    ChatsModel(
      avatar:
          'https://images.unsplash.com/photo-1609505018859-8b7e79ff56c0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDV8dG93SlpGc2twR2d8fGVufDB8fHx8fA%3D%3D',
      username: 'Alice Lane',
      recentMessage: 'Hello',
      unreadMessagesCount: 0,
    ),
    // Add more chats here...
  ];

  List<String> users = [
    'Jane Doe',
    'John Brad',
    'Alice Lane',
  ];

  String databaseId = DbPaths.database;
  String collectionId = DbPaths.usersCollection;
  final client = Client()
      .setEndpoint(DbPaths.projectEndPoint) // Your Appwrite Endpoint
      .setProject(DbPaths.project) // Your project ID
      .setSelfSigned();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((token) async {
      print('Device Token FCM: $token');
      print(box.get('id'));
      final databases = Databases(client);
      try {
        await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: box.get('id'),
          data: {
            'notificationToken': token,
          },
        );
      } catch (e) {
        print(e);
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();

  //   final realtime = Realtime(client);
  //   final subscription = realtime.subscribe(
  //       ['databases.$databaseId.collections.$collectionId.documents']);

  //   subscription.stream.listen((response) {
  //     print(response.payload);
  //     if (response.events
  //         .contains("databases.*.collections.*.documents.*.update")) {
  //       print(response.payload);
  //     }
  //   });
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   final realtime = Realtime(client);
  //   final subscription = realtime.subscribe(
  //       ['databases.$databaseId.collections.$collectionId.documents']);
  //   subscription.close();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // leading: const Padding(
        //   padding: EdgeInsets.all(8.0),
        //   child: CircleAvatar(
        //     radius: 10,
        //     child: Icon(
        //       Icons.person,
        //     ),
        //   ),
        // ),
        title: const Text(
          'HugB Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // await AppServices()
              //     .createUser('2131313', '32ed', 'sdcdcs@gmail.com');
              print('added');
              showSearch(
                context: context,
                delegate: UserSearchDelegate(),
              );
              // final collection =
              //     client.getDatabase('hugb-db').getCollection('users');
              // await collection.insertOne(
              //   MongoDocument(
              //     {
              //       'username': 'ossama',
              //       'email': 'ossama@gmail.com',
              //     },
              //   ),
              // );
            },
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'Logout') {
                Account account = Account(client);
                await account.deleteSession(sessionId: 'current');
                await box.put('id', null);
                await box.put('isLoggedIn', false);
                Get.offAll(
                  const LoginScreen(),
                );
                // Handle logout action here
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Logout',
                height: 20,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<DocumentList>(
          future: AppServices().getChats(userId: box.get('id'), query: ''),
          builder: (context, snapshot) {
            print(box.get('id'));
            if (!snapshot.hasData) {
              return ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Colors.transparent,
                    leading: Skeleton(
                      width: 50,
                      height: 50,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    title: Skeleton(
                      width: 100,
                      height: 20,
                    ),
                    onTap: () {
                      // Handle user tap
                    },
                  );
                },
              );
            }

            final usersData = snapshot.data!.documents;

            return usersData.isNotEmpty
                ? ListView.builder(
                    itemCount: usersData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          usersData[index].data['username'],
                        ),
                        onTap: () {
                          Get.to(
                            ChatScreen(
                              username: usersData[index].data['username'],
                              avatar: '',
                              userId: usersData[index].data['userId'],
                              email: usersData[index].data['email'],
                              docId: usersData[index].$id,
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No chats yet',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
