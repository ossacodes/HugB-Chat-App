import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../chat_screen.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.usersData,
  });

  final Document usersData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(
        usersData.data['username'],
      ),
      subtitle: Text(
        usersData.data['currentMessage'],
      ),
      onTap: () {
        Get.to(
          ChatScreen(
            username: usersData.data['username'],
            avatar: '',
            userId: usersData.data['userId'],
            email: usersData.data['email'],
            docId: usersData.$id,
          ),
        );
      },
    );
  }
}
