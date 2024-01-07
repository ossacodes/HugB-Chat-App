import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/config/db_paths.dart';
import 'package:hugb/services/app_services.dart';

import '../chat_screen.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({
    super.key,
    required this.usersData,
    required this.docId,
  });

  final Document usersData;
  final String docId;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  var box = Hive.box('myData');
  final client = Client()
      .setEndpoint(DbPaths.projectEndPoint) // Your Appwrite Endpoint
      .setProject(DbPaths.project) // Your project ID
      .setSelfSigned();

  @override
  void initState() {
    super.initState();
    final realtime = Realtime(client);
    final chatSubscription = realtime.subscribe([
      'databases.${DbPaths.database}.collections.${DbPaths.chatsCollection}.documents.${widget.docId}'
    ]);

    chatSubscription.stream.listen((response) {
      if (response.events
          .contains("databases.*.collections.*.documents.*.update")) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final payload = response.payload;
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AppServices().getUnreadMessageCount(
          docId: widget.docId,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
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
            trailing: snapshot.data!.data['unreadCount'] != null
                ? Visibility(
                    visible: snapshot.data!.data['unreadCount'] > 0,
                    child: CircleAvatar(
                      radius: 16,
                      child: Text(
                        snapshot.data!.data['unreadCount'].toString(),
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            onTap: () {
              Get.to(
                ChatScreen(
                  username: widget.usersData.data['username'],
                  avatar: '',
                  userId: widget.usersData.data['userId'],
                  email: widget.usersData.data['email'],
                  docId: widget.usersData.$id,
                  unreadMessages: snapshot.data!.data['unreadCount'] ?? 0,
                ),
              )!
                  .then((value) {
                setState(() {});
              });
            },
          );
        });
  }
}
