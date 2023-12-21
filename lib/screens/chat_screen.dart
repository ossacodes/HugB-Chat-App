import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.username,
    required this.avatar,
  });

  final String username;
  final String avatar;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String textMessage = '';
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
            CircleAvatar(
              radius: 20.0,
              backgroundImage: CachedNetworkImageProvider(
                widget.avatar,
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
              child: Container(),
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
                                      // final timeStamp =
                                      //     DateTime.now().millisecondsSinceEpoch;
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
