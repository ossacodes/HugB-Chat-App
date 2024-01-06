import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/config/db_paths.dart';
import 'package:hugb/screens/wrapper/wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';
import 'services/call_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  await Hive.openBox('myData');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Client client = Client();
  client
      .setEndpoint(DbPaths.projectEndPoint)
      .setProject(DbPaths.project)
      .setSelfSigned(status: true);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final box = Hive.box('myData');

  // generate callerID of local user
  final String selfCallerID =
      Random().nextInt(999999).toString().padLeft(6, '0');

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (child, x) {
        return GetMaterialApp(
          title: 'HugB',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const Wrapper(),
        );
      },
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  await Hive.openBox('myData');
  print("Handling a background message: ${message.messageId}");
  // await CallService().listenToCallEvents();
  CallService().listenToCallEvents();

  if (message.data['type'] == 'audio_call') {
    CallService.receiveCall(
      userId: message.data['caller_id'],
      profileUrl: message.data['call_image'],
      username: message.data['caller_name'],
      type: 'audio_call',
    );
  } else if (message.data['type'] == 'video_call') {
    CallService.receiveCall(
      userId: message.data['caller_id'],
      profileUrl: message.data['call_image'],
      username: message.data['caller_name'],
      type: 'video_call',
    );
  }
}

class Config extends ChangeNotifier {
  late String appId;
  late String atlasUrl;
  late Uri baseUrl;

  Config._create(dynamic realmConfig) {
    appId = realmConfig['appId'];
    atlasUrl = realmConfig['dataExplorerLink'];
    baseUrl = Uri.parse(realmConfig['baseUrl']);
  }

  static Future<Config> getConfig(String jsonConfigPath) async {
    dynamic realmConfig =
        json.decode(await rootBundle.loadString(jsonConfigPath));

    var config = Config._create(realmConfig);

    return config;
  }
}
