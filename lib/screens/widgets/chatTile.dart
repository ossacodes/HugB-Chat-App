import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/services/app_services.dart';

import '../chat_screen.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({
    super.key,
    required this.usersData,
  });

  final Document usersData;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  var box = Hive.box('myData');
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(
        widget.usersData.data['username'],
      ),
      subtitle: Text(
        widget.usersData.data['currentMessage'],
      ),
      trailing: FutureBuilder(
        future: AppServices().getUnreadMessageCount(
          userId: box.get('id'),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          return  Visibility(
            visible: snapshot.data != 0,
            child: CircleAvatar(
              radius: 16,
              child: Text(
                snapshot.data.toString(),
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
      onTap: () {
        Get.to(
          ChatScreen(
            username: widget.usersData.data['username'],
            avatar: '',
            userId: widget.usersData.data['userId'],
            email: widget.usersData.data['email'],
            docId: widget.usersData.$id,
          ),
        )!.then((value) {
          setState(() {});
        });
      },
    );
  }
}
