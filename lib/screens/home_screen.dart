import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/auth/login_screen.dart';
import 'package:hugb/realm/realm_services.dart';
import 'package:provider/provider.dart';
import '../models/chats_model.dart';
import '../realm/app_services.dart';
import 'chat_screen.dart';
import 'widgets/search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var box = Hive.box('myData');

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

  @override
  Widget build(BuildContext context) {
    final appServices = Provider.of<AppServices>(context, listen: false);
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'HugB Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              realmServices.createUser(
                'xd',
                '123',
                'xd@gmail.com',
              );
              print('added');
              // showSearch(
              //   context: context,
              //   delegate: UserSearchDelegate(users),
              // );
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
                // app.logout();
                appServices.logOut();
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
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Get.to(
                  ChatScreen(
                    username: chats[index].username,
                    avatar: chats[index].avatar,
                    userId: '',
                    email: '',
                    docId: '',
                  ),
                );
              },
              leading: const CircleAvatar(
                radius: 25,
                child: Icon(
                  Icons.person,
                  size: 30,
                ),
              ),
              title: Text(chats[index].username),
              subtitle: Text(chats[index].recentMessage),
              trailing: chats[index].unreadMessagesCount > 0
                  ? CircleAvatar(
                      radius: 10.0,
                      child: Text(
                        '${chats[index].unreadMessagesCount}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
