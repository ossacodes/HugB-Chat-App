import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugb/config/palette.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.unread,
  });

  final bool isMe;
  final String message;
  final bool unread;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
              ? const Text(
                  '10:00 am',
                  // DateFormat.jm().format(widget.time.toDate()),
                  style: TextStyle(
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
                    const Text(
                      '10:00 am',
                      // DateFormat.jm().format(widget.time.toDate()),
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    widget.unread
                        ? const Icon(
                            Icons.check,
                            color: Colors.grey,
                            size: 20.0,
                          )
                        : Icon(
                            Icons.done_all,
                            color: Palette.appColor,
                            size: 20.0,
                          ),
                  ],
                ),
        ],
      ),
    );
  }
}
