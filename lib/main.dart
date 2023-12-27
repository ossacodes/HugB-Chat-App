import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/screens/wrapper/wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';

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
      .setEndpoint('https://exwoo.com/v1')
      .setProject('6587168cbc8a1e9b32bb')
      .setSelfSigned(status: true);
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
