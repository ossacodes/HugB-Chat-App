import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/auth/login_screen.dart';
import 'package:hugb/config/db_paths.dart';
import 'package:hugb/screens/call/audio_call.dart';
import 'package:hugb/screens/widgets/chatTile.dart';
import 'package:hugb/screens/widgets/search_delegate.dart';
import 'package:hugb/services/call_service.dart';
import 'package:skeleton_animation/skeleton_animation.dart';
import '../services/app_services.dart';
import '../services/signalling.service.dart';
import 'call/video_call.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var box = Hive.box('myData');
  // signalling server url
  final String websocketUrl = "https://websocket-server.fly.dev/";
  final _firebaseMessaging = FirebaseMessaging.instance;
  dynamic incomingSDPOffer;

  String databaseId = DbPaths.database;
  String collectionId = DbPaths.usersCollection;
  final client = Client()
      .setEndpoint(DbPaths.projectEndPoint) // Your Appwrite Endpoint
      .setProject(DbPaths.project) // Your project ID
      .setSelfSigned();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await FlutterCallkitIncoming.requestNotificationPermission({
      "rationaleMessagePermission":
          "Notification permission is required, to show notification.",
      "postNotificationMessageRequired":
          "Notification permission is required, Please allow notification permission from setting."
    });
  }

  @override
  void initState() {
    super.initState();
    // init signalling service
    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerID: box.get('id'),
    );
    CallService().listenToCallEvents();
    final databases = Databases(client);
    final realtime = Realtime(client);
    _firebaseMessaging.getToken().then((token) async {
      // print('Device Token FCM: $token');
      // print(box.get('id'));

      try {
        final subscription = realtime.subscribe([
          'databases.${DbPaths.database}.collections.${DbPaths.chatsCollection}.documents'
        ]);

        subscription.stream.listen((response) {
          if (response.events
              .contains("databases.*.collections.*.documents.*.update")) {
            setState(() {});
          } else if (response.events
              .contains("databases.*.collections.*.documents.*.delete")) {
            setState(() {});
          } else if (response.events
              .contains("databases.*.collections.*.documents.*.create")) {
            setState(() {});
          }
        });
        await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: box.get('id'),
          data: {
            'notificationToken': token,
          },
        );
      } catch (e) {
        print(e);
      }
    });

    // listen for incoming video call
    // final subscription = realtime.subscribe([
    //   'databases.$databaseId.collections.${DbPaths.makeCallCollection}.documents'
    // ]);

    // subscription.stream.listen((response) {
    //   // print(response.payload);
    //   if (response.events
    //       .contains("databases.*.collections.*.documents.*.create")) {
    //     // print(response.payload);
    //     final data = response.payload;
    //     if (mounted) {
    //       // set SDP Offer of incoming call
    //       setState(() => incomingSDPOffer = data);

    //       if (incomingSDPOffer["calleeId"] != box.get('id')) {
    //         Get.snackbar(
    //           '',
    //           '',
    //           titleText: const SizedBox(),
    //           animationDuration: const Duration(
    //             milliseconds: 200,
    //           ),
    //           messageText: FutureBuilder(
    //               future: AppServices().getUserData(
    //                 userId: incomingSDPOffer["calleeId"],
    //               ),
    //               builder: (context, userSnapshot) {
    //                 if (!userSnapshot.hasData) {
    //                   return Center(
    //                     child: Skeleton(
    //                       width: 100,
    //                       height: 20,
    //                     ),
    //                   );
    //                 }
    //                 return ListTile(
    //                   leading: const CircleAvatar(
    //                     radius: 28,
    //                     child: Icon(
    //                       Icons.person,
    //                       size: 30,
    //                     ),
    //                   ),
    //                   title: Text(
    //                     '${userSnapshot.data!.data['username']}',
    //                     style: const TextStyle(
    //                       fontSize: 16,
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.white,
    //                     ),
    //                   ),
    //                   subtitle: const Text(
    //                     'Incoming Call...',
    //                     style: TextStyle(fontSize: 14, color: Colors.white),
    //                   ),
    //                   trailing: Wrap(
    //                     children: [
    //                       CircleAvatar(
    //                         backgroundColor: Colors.red,
    //                         child: IconButton(
    //                           onPressed: () {
    //                             setState(() => incomingSDPOffer = null);
    //                             Get.back();
    //                           },
    //                           icon: const Icon(
    //                             Icons.call_end,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                       ),
    //                       const SizedBox(
    //                         width: 10,
    //                       ),
    //                       CircleAvatar(
    //                         backgroundColor: Colors.green,
    //                         child: IconButton(
    //                           onPressed: () {
    //                             Get.back();
    //                             if (incomingSDPOffer['call_type'] ==
    //                                 'audio_call') {
    //                               _joinAudioCall(
    //                                 callerId: incomingSDPOffer["calleeId"]!,
    //                                 calleeId: box.get('id'),
    //                                 // offer: incomingSDPOffer["sdpOffer"],
    //                                 offer: {
    //                                   "sdp": incomingSDPOffer["sdp"],
    //                                   "type": incomingSDPOffer["type"],
    //                                 },
    //                               );
    //                             } else {
    //                               _joinCall(
    //                                 callerId: incomingSDPOffer["calleeId"]!,
    //                                 calleeId: box.get('id'),
    //                                 // offer: incomingSDPOffer["sdpOffer"],
    //                                 offer: {
    //                                   "sdp": incomingSDPOffer["sdp"],
    //                                   "type": incomingSDPOffer["type"],
    //                                 },
    //                               );
    //                             }
    //                           },
    //                           icon: const Icon(
    //                             Icons.call,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 );
    //               }),
    //           padding: const EdgeInsets.symmetric(
    //             vertical: 10,
    //           ),
    //           // maxWidth: Get.width * 0.9,
    //           backgroundColor: Colors.black.withOpacity(0.7),
    //           borderRadius: 20,
    //           colorText: Colors.white,
    //           duration: const Duration(
    //             seconds: 10,
    //           ),
    //         );
    //       }
    //     }
    //   }
    // });

    SignallingService.instance.socket!.on("newCall", (data) {
      if (mounted) {
        // set SDP Offer of incoming call
        setState(() => incomingSDPOffer = data);
        if (incomingSDPOffer["callerId"] != box.get('id')) {
          Get.snackbar(
            '',
            '',
            titleText: const SizedBox(),
            animationDuration: const Duration(
              milliseconds: 200,
            ),
            messageText: FutureBuilder(
                future: AppServices().getUserData(
                  userId: incomingSDPOffer["callerId"],
                ),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Center(
                      child: Skeleton(
                        width: 100,
                        height: 20,
                      ),
                    );
                  }
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.person,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      '${userSnapshot.data!.data['username']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: const Text(
                      'Incoming Call...',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    trailing: Wrap(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                            onPressed: () {
                              setState(() => incomingSDPOffer = null);
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                            onPressed: () {
                              Get.back();
                              if (incomingSDPOffer['callType'] ==
                                  'audio_call') {
                                _joinAudioCall(
                                  callerId: userSnapshot.data!.$id,
                                  calleeId: box.get('id'),
                                  offer: incomingSDPOffer["sdpOffer"],
                                  callName: userSnapshot.data!.data['username'], 
                                  // offer: {
                                  //   "sdp": incomingSDPOffer["sdp"],
                                  //   "type": incomingSDPOffer["type"],
                                  // },
                                );
                              } else {
                                _joinCall(
                                  callerId: userSnapshot.data!.$id,
                                  calleeId: box.get('id'),
                                  offer: incomingSDPOffer["sdpOffer"],
                                  // offer: {
                                  //   "sdp": incomingSDPOffer["sdp"],
                                  //   "type": incomingSDPOffer["type"],
                                  // },
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            // maxWidth: Get.width * 0.9,
            backgroundColor: Colors.black.withOpacity(0.7),
            borderRadius: 20,
            colorText: Colors.white,
            duration: const Duration(
              seconds: 10,
            ),
          );
        }
      }
    });
  }

  // Join Audio Call
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
    required String callName,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioCallScreen(
          callerId: callerId,
          calleeId: calleeId,
          offer: offer,
          callName: callName,
        ),
      ),
    );
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   final realtime = Realtime(client);
  //   final subscription = realtime.subscribe(
  //       ['databases.$databaseId.collections.$collectionId.documents']);
  //   subscription.close();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'HugB Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(),
              );
            },
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'Logout') {
                Account account = Account(client);
                await account.deleteSession(sessionId: 'current');
                await box.put('id', null);
                await box.put('isLoggedIn', false);
                Get.offAll(
                  const LoginScreen(),
                );
                // Handle logout action here
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Logout',
                height: 20,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: FutureBuilder<DocumentList>(
              future: AppServices().getChats(userId: box.get('id'), query: ''),
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

                return usersData.isNotEmpty
                    ? ListView.builder(
                        itemCount: usersData.length,
                        itemBuilder: (context, index) {
                          return ChatTile(
                            usersData: usersData[index],
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No chats yet',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey),
                        ),
                      );
              },
            ),
          ),
          // if (incomingSDPOffer != null)
          //   Positioned(
          //     child: ListTile(
          //       title: Text(
          //         "Incoming Call from ${incomingSDPOffer["callerId"]}",
          //       ),
          //       trailing: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           IconButton(
          //             icon: const Icon(Icons.call_end),
          //             color: Colors.redAccent,
          //             onPressed: () {
          //               setState(() => incomingSDPOffer = null);
          //             },
          //           ),
          //           IconButton(
          //             icon: const Icon(Icons.call),
          //             color: Colors.greenAccent,
          //             onPressed: () {
          //               _joinCall(
          //                 callerId: incomingSDPOffer["callerId"]!,
          //                 calleeId: box.get('id'),
          //                 offer: incomingSDPOffer["sdpOffer"],
          //                 // offer: {
          //                 //   "sdp": incomingSDPOffer["sdp"],
          //                 //   "type": incomingSDPOffer["type"],
          //                 // },
          //               );
          //             },
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
