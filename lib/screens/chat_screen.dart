import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hive/hive.dart';
import 'package:hugb/config/db_paths.dart';
import 'package:hugb/screens/call/audio_call.dart';
import 'package:hugb/screens/call/video_call.dart';
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
  String? myChatId;
  final client = Client()
      .setEndpoint(DbPaths.projectEndPoint) // Your Appwrite Endpoint
      .setProject(DbPaths.project) // Your project ID
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
      if (response.events
          .contains("databases.*.collections.*.documents.*.update")) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });

    getMyChatId();

    messageStream = subscription.stream;
  }

  Future getMyChatId() async {
    final database = Databases(client);
    final documents = await database.listDocuments(
      databaseId: DbPaths.database,
      collectionId: DbPaths.chatsCollection,
      queries: [
        Query.equal('userId', box.get('id')),
      ],
    );

    if (documents.documents.isEmpty) {
      myChatId = null;
    }

    try {
      myChatId = documents.documents[0].$id;

      await database.updateDocument(
        databaseId: DbPaths.database,
        collectionId: DbPaths.chatsCollection,
        documentId: documents.documents[0].$id,
        data: {
          'isTyping': false,
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
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
            documentID: element.$id,
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
            documentID: element.$id,
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
          print(payload['\$id']);
          messageBubbles.add(
            MessageBubble(
              isMe: true,
              message: payload['message'],
              seen: payload['seen'],
              time: data.timestamp,
              documentID: payload['\$id'],
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
              documentID: payload['\$id'],
            ),
          );
        }
      }

      yield messageBubbles;
    }
  }

  // join Call
  _joinCall({
    required String callerId,
    required String calleeId,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          callerId: callerId,
          calleeId: calleeId,
          offer: offer,
        ),
      ),
    );
  }

  // Join Audio Call
  _joinAudioCall({
    required String callerId,
    required String calleeId,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioCallScreen(
          callerId: callerId,
          calleeId: calleeId,
          offer: offer,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    getMyChatId();
    // subscription.close();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AppServices().getUserData(
          userId: widget.userId,
        ),
        builder: (context, userSnapshot) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      ActivityWidget(
                        userId: widget.userId,
                        docId: widget.docId,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Video Call'),
                          content:
                              const Text('Do you want to start a video call?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Start'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Handle start video call action
                                AppServices.sendCallWake(
                                  title: '${box.get('username')} is calling',
                                  body: 'Tap to join the call',
                                  id: box.get('id'),
                                  notificationToken: userSnapshot
                                      .data!.data['notificationToken'],
                                  profileUrl: '',
                                  type: 'video_call',
                                  username: box.get('username'),
                                );
                                _joinCall(
                                  callerId: box.get('id'),
                                  calleeId: widget.userId,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.video_call),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Video Call'),
                          content:
                              const Text('Do you want to start a video call?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Start'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Handle start video call action

                                _joinAudioCall(
                                  callerId: box.get('id'),
                                  calleeId: widget.userId,
                                );

                                AppServices.sendCallWake(
                                  title: '${box.get('username')} is calling',
                                  body: 'Tap to join the call',
                                  id: box.get('id'),
                                  notificationToken: userSnapshot
                                      .data!.data['notificationToken'],
                                  profileUrl: '',
                                  type: 'audio_call',
                                  username: box.get('username'),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
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
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    // IconButton(
                                    //   onPressed: () {},
                                    //   icon: const Icon(
                                    //     Icons.emoji_emotions_outlined,
                                    //   ),
                                    // ),
                                    Flexible(
                                      child: TextField(
                                        controller: _messageController,
                                        maxLines: null,
                                        onTap: () {},
                                        onChanged: (value) async {
                                          final database = Databases(client);
                                          bool isTyping = true;
                                          if (isTyping) {
                                            if (myChatId != null) {
                                              await database.updateDocument(
                                                databaseId: DbPaths.database,
                                                collectionId:
                                                    DbPaths.chatsCollection,
                                                documentId: myChatId!,
                                                data: {
                                                  'isTyping': true,
                                                },
                                              );
                                            }
                                          }

                                          Timer.periodic(
                                              const Duration(
                                                seconds: 5,
                                              ), (timer) async {
                                            if (myChatId != null) {
                                              await database.updateDocument(
                                                databaseId: DbPaths.database,
                                                collectionId:
                                                    DbPaths.chatsCollection,
                                                documentId: myChatId!,
                                                data: {
                                                  'isTyping': false,
                                                },
                                              );
                                            }
                                            if (mounted) {
                                              setState(() {
                                                isTyping = false;
                                              });
                                            }
                                            timer.cancel();
                                          });

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
              ),
            ),
          );
        });
  }
}

class ActivityWidget extends StatefulWidget {
  const ActivityWidget({
    super.key,
    required this.userId,
    required this.docId,
  });

  final String userId;
  final String docId;

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  final client = Client()
      .setEndpoint('https://exwoo.com/v1')
      .setProject(DbPaths.project)
      .setSelfSigned();
  bool isTyping = false;
  late RealtimeSubscription subscription;

  @override
  void initState() {
    super.initState();
    final realtime = Realtime(client);
    subscription = realtime.subscribe([
      'databases.${DbPaths.database}.collections.${DbPaths.chatsCollection}.documents.${widget.docId}'
    ]);

    subscription.stream.listen((response) {
      if (response.events
          .contains("databases.*.collections.*.documents.*.update")) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final payload = response.payload;
          if (mounted) {
            setState(() {
              isTyping = payload['isTyping'];
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    subscription.close(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isTyping,
      child: const Text(
        'Typing...',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
