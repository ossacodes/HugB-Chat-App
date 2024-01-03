import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hugb/screens/call/call_page.dart';
import 'package:hugb/screens/call/video_call.dart';
import 'package:hugb/screens/home_screen.dart';
import 'package:uuid/uuid.dart' as uuid;

class CallService {
  final box = Hive.box('myData');
  Future<void> listenToCallEvents() async {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          // TODO: received an incoming call
          Get.to(
            const HomeScreen(),
          );
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          Get.to(
            const HomeScreen(),
          );
          break;
        case Event.actionCallAccept:
          if (event.body['type'] == 0) {
            Get.to(
              const CallPage(),
            );
            // Get.to(
            //   AudioCallScreen(
            //     receiverName: event.body['nameCaller'],
            //     receiverPhone: event.body['number'],
            //     receiverImageURL: event.body['avatar'],
            //   ),
            // );
          } else if (event.body['type'] == 1) {
            Get.to(
              const CallPage(),
            );
            // Get.to(
            //   VideoCallScreen(
            //     receiverName: event.body['nameCaller'],
            //     receiverPhone: event.body['number'],
            //     receiverImageURL: event.body['avatar'],
            //   ),
            // );
          }
          break;
        case Event.actionCallDecline:
          // declined an incoming call

          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
          break;
        case Event.actionCallTimeout:
          // missed an incoming call

          break;
        case Event.actionCallCallback:
          // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
          // TODO: only iOS
          break;
        case Event.actionCallToggleMute:
          // TODO: only iOS
          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: only iOS
          break;
        case Event.actionCallCustom:
          // TODO: for custom action
          break;
      }
    });
  }

  static void receiveCall({
    required String username,
    required String userId,
    required String profileUrl,
    required String type,
  }) async {
    final currentUuid = const uuid.Uuid().v4();

    // Show callkit incoming
    CallKitParams callKitParams = CallKitParams(
      id: currentUuid,
      nameCaller: username,
      appName: 'Callkit',
      avatar: profileUrl,
      handle: userId,
      type: type == 'audio_call' ? 0 : 1,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: 30000,
      extra: <String, dynamic>{'userId': userId},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: profileUrl,
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
}
