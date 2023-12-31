import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hugb/config/db_paths.dart';
// import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:hugb/screens/widgets/message_bubble.dart';
import 'package:hugb/services/app_services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.username,
    required this.avatar,
    required this.userId,
    required this.email,
    required this.docId,
  });

  final String username;
  final String avatar;
  final String userId;
  final String email;
  final String docId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String textMessage = '';
  var box = Hive.box('myData');
  String chatId = '';
  final client = Client()
      .setEndpoint('https://exwoo.com/v1') // Your Appwrite Endpoint
      .setProject('6587168cbc8a1e9b32bb') // Your project ID
      .setSelfSigned();
  Stream<RealtimeMessage> messageStream = const Stream.empty();
  late RealtimeSubscription subscription;

  // realTimeStream() {
  //   final realtime = Realtime(client);
  //   final subscription = realtime.subscribe([
  //     'databases.${DbPaths.database}.collections.${DbPaths.messagesCollection}.documents'
  //   ]);

  //   return subscription.stream;
  // }

  @override
  void initState() {
    super.initState();
    chatId = AppServices.getChatId(
      box.get('id'),
      widget.userId,
    );
    final realtime = Realtime(client);
    subscription = realtime.subscribe([
      'databases.${DbPaths.database}.collections.${DbPaths.messagesCollection}.documents'
    ]);

    subscription.stream.listen((response) {
      print(response.payload);
      if (response.events
          .contains("databases.*.collections.*.documents.*.update")) {
        print(response.payload);
      }
    });

    messageStream = subscription.stream;
  }

  Stream<List<MessageBubble>> messagesStream() async* {
    // messageBubbles.clear();
    final messagesData = await AppServices().getMessages(
      chatId: chatId,
      userId: box.get('id'),
    );

    List<MessageBubble> messageBubbles = [];

    for (var element in messagesData.documents) {
      if (element.data['senderId'] == box.get('id') &&
          element.data['receiverId'] == widget.userId) {
        // print(element.$createdAt);
        messageBubbles.add(
          MessageBubble(
            isMe: true,
            message: element.data['message'],
            seen: element.data['seen'],
            time: element.$createdAt,
          ),
        );
      } else if (element.data['senderId'] == widget.userId &&
          element.data['receiverId'] == box.get('id')) {
        messageBubbles.add(
          MessageBubble(
            isMe: false,
            message: element.data['message'],
            seen: element.data['seen'],
            time: element.$createdAt,
          ),
        );
      }
    }

    yield messageBubbles;

    await for (final data in messageStream) {
      if (data.events
          .contains("databases.*.collections.*.documents.*.create")) {
        final payload = data.payload;
        if (payload['senderId'] == box.get('id') &&
            payload['receiverId'] == widget.userId) {
          // print(data.timestamp);
          messageBubbles.add(
            MessageBubble(
              isMe: true,
              message: payload['message'],
              seen: payload['seen'],
              time: data.timestamp,
            ),
          );
        } else if (payload['senderId'] == widget.userId &&
            payload['receiverId'] == box.get('id')) {
          messageBubbles.add(
            MessageBubble(
              isMe: false,
              message: payload['message'],
              seen: payload['seen'],
              time: data.timestamp,
            ),
          );
        }
      }

      yield messageBubbles;
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   subscription.close();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
            const SizedBox(width: 10.0),
            const CircleAvatar(
              radius: 20,
              child: Icon(
                Icons.person,
                size: 25,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              widget.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: AppServices().getUserData(
              userId: widget.userId,
            ),
            builder: (context, userSnapshot) {
              // if (!userSnapshot.hasData) {
              //   return const Center(
              //     child: CircularProgressIndicator(),
              //   );
              // }
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StreamBuilder<List<MessageBubble>>(
                      stream: messagesStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final messageBubbles = snapshot.data;

                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 20.0,
                          ),
                          itemCount: messageBubbles!.length,
                          itemBuilder: (context, index) {
                            return messageBubbles.reversed.toList()[index];
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    // height: 60.0,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, 0.1),
                          blurRadius: 5.0,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                20.0,
                              ),
                              child: Container(
                                color: Colors.grey[200],
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.emoji_emotions_outlined,
                                      ),
                                    ),
                                    Flexible(
                                      child: TextField(
                                        controller: _messageController,
                                        maxLines: null,
                                        onTap: () {},
                                        onChanged: (value) {
                                          setState(() {
                                            // if (value.trim() !=
                                            //     '') {
                                            //   isWriting = true;
                                            // } else {
                                            //   isWriting = false;
                                            // }

                                            textMessage = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Type a message',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        _messageController.clear();

                                        if (textMessage.trim() != '') {
                                          // await AppServices().sendMessages(
                                          //   chatId: chatId,
                                          //   userId: widget.userId,
                                          //   receiverId: box.get('id'),
                                          //   message: textMessage,
                                          //   seen: false,
                                          // );
                                          await AppServices().sendMessages(
                                            chatId: chatId,
                                            userId: box.get('id'),
                                            receiverId: widget.userId,
                                            username: box.get('username'),
                                            message: textMessage,
                                            seen: false,
                                            notificationToken: userSnapshot
                                                .data!
                                                .data['notificationToken'],
                                          );
                                          await AppServices().createChat(
                                            chatOwnerId: box.get('id'),
                                            userId: widget.userId,
                                            currentMessage: textMessage,
                                            username: widget.username,
                                            email: widget.email,
                                            profileUrl: null,
                                          );
                                          await AppServices().createChat(
                                            chatOwnerId: widget.userId,
                                            userId: box.get('id'),
                                            currentMessage: textMessage,
                                            username: box.get('username'),
                                            email: box.get('email'),
                                            profileUrl: null,
                                          );
                                          // AppServices().createMessage(
                                          //   chatId: chatId,
                                          //   message: textMessage,
                                          //   senderId: box.get('id'),
                                          //   receiverId: widget.userId,
                                          //   senderName: box.get('username'),
                                          //   receiverName: widget.username,
                                          //   senderEmail: box.get('email'),
                                          //   receiverEmail: widget.email,
                                          // );

                                          // final timeStamp =
                                          //     DateTime.now().millisecondsSinceEpoch;
                                          // final collection = client
                                          //     .getDatabase('hugb-db')
                                          //     .getCollection('chats');
                                          // await collection.insertOne(
                                          //   MongoDocument(
                                          //     {
                                          //       'chatOwnerId': '',
                                          //       'userId': widget.userId,
                                          //       'currentMessage': textMessage,
                                          //       'username': widget.username,
                                          //       'email': widget.email,
                                          //     },
                                          //   ),
                                          // );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.send,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}
