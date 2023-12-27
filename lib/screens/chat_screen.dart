import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

  List<Widget> messageBubbles = const [
    MessageBubble(
      isMe: true,
      message: 'Hi',
      unread: false,
    ),
    MessageBubble(
      isMe: false,
      message: 'Hey',
      unread: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    chatId = AppServices.getChatId(
      box.get('id'),
      widget.userId,
    );
    print(chatId);
  }

  @override
  Widget build(BuildContext context) {
    // final messageCollection =
    //     client.getDatabase('hugb-db').getCollection('messages');
    // messageCollection.watch().listen((event) {
    //   print('event');
    //   print(event);
    // });
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 20.0,
                ),
                itemCount: messageBubbles.length,
                itemBuilder: (context, index) {
                  // int index2 = messageBubbles.length - index;
                  // return messageBubbles[(messageBubbles.length -1) - index];
                  return messageBubbles.reversed.toList()[index];
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
                                    // setState(() {
                                    //   if (value.trim() !=
                                    //       '') {
                                    //     isWriting = true;
                                    //   } else {
                                    //     isWriting = false;
                                    //   }

                                    //   textMessage = value;
                                    // });
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

                                  if (textMessage.isNotEmpty) {
                                    if (textMessage != ' ') {
                                      await AppServices().createChat(
                                        chatOwnerId: box.get('id'),
                                        userId: widget.userId,
                                        currentMessage: textMessage,
                                        username: widget.username,
                                        email: widget.email,
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
        ),
      ),
    );
  }
}
