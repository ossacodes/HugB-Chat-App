import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/screens/chat_screen.dart';
import 'package:hugb/services/app_services.dart';
import 'package:skeleton_animation/skeleton_animation.dart';

class UserSearchDelegate extends SearchDelegate<String> {
  UserSearchDelegate();
  final box = Hive.box('myData');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // final results = users.where((user) => user.contains(query)).toList();

    return FutureBuilder<DocumentList>(
      future: AppServices().getUsers(query: query),
      builder: (context, snapshot) {
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

        return ListView.builder(
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
                // Handle user tap
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<DocumentList>(
      future: AppServices().getUsers(query: query),
      builder: (context, snapshot) {
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

        return ListView.builder(
          itemCount: usersData.length,
          itemBuilder: (context, index) {
            return Visibility(
              visible: box.get('id') != usersData[index].$id,
              child: ListTile(
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
              ),
            );
          },
        );
      },
    );
  }
}
