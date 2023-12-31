import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugb/config/palette.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../config/db_paths.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.seen,
    required this.time,
    required this.documentID,
  });

  final bool isMe;
  final String message;
  final bool seen;
  final String time;
  final String documentID;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final client = Client()
      .setEndpoint('https://exwoo.com/v1') // Your Appwrite Endpoint
      .setProject(DbPaths.project) // Your project ID
      .setSelfSigned();
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.documentID),
      onVisibilityChanged: (visibilityInfo) {
        final databases = Databases(client);
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 50) {
          if (!widget.isMe) {
            if (widget.seen == false) {
              databases.updateDocument(
                databaseId: DbPaths.database,
                collectionId: DbPaths.messagesCollection,
                documentId: widget.documentID,
                data: {
                  'seen': true,
                },
              );
            }

            // _firestore
            //     .collection('messages')
            //     .doc(widget.receiverID)
            //     .collection(box.read('phone'))
            //     .doc(widget.documentID)
            //     .update({
            //   'unread': false,
            // });
            // _firestore
            //     .collection('messages')
            //     .doc(box.read('phone'))
            //     .collection(widget.receiverID)
            //     .doc(widget.documentID)
            //     .update({
            //   'unread': false,
            // });
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.isMe ? 100.0.w : 0,
          right: widget.isMe ? 0 : 100.0.w,
          top: 3,
          bottom: 3,
        ),
        child: Column(
          crossAxisAlignment:
              widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () async {},
              child: Material(
                borderRadius: widget.isMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(0.0),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                elevation: 3.0,
                color: widget.isMe ? Palette.appColor : const Color(0xffEFF4FF),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: widget.isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            !widget.isMe
                ? Text(
                    DateFormat.jm().format(DateTime.parse(widget.time)),
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Row(
                    mainAxisAlignment: widget.isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.jm().format(DateTime.parse(widget.time)),
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      widget.seen
                          ? Icon(
                              Icons.done_all,
                              color: Palette.appColor,
                              size: 20.0,
                            )
                          : const Icon(
                              Icons.check,
                              color: Colors.grey,
                              size: 20.0,
                            ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
