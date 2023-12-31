import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hugb/auth/signup_screen.dart';
import '../../config/loader.dart';
import '../../config/palette.dart';
import '../screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var box = Hive.box('myData');
  Client client = Client();

  String email = '';

  String password = '';

  bool load = false;

  Future<void> login(String email, String password) async {
    client
        .setEndpoint('https://exwoo.com/v1') // Your Appwrite Endpoint
        .setProject('6587168cbc8a1e9b32bb') // Your project ID
        .setSelfSigned();
    Account account = Account(client);
    await account.createEmailSession(email: email, password: password);
    final user = await account.get();
    box.put('id', user.$id);
    box.put('isLoggedIn', true);
    Get.offAll(
      const HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: load
          ? const Loader()
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/f17a9c7f-9702-4e50-b460-2b77818450f9/width=450/09492-387303212-Made_of_pieces_broken_glass%20solo,wings,blurry,no%20humans,bird,animal%20focus,debris,beak,shards,%20bright%20colors,%20glowing,%20electric%20w.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      // color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            cursorColor: Palette.appColor,
                            validator: (value) =>
                                value!.isEmpty ? 'Email required!' : null,
                            onChanged: (value) {
                              email = value;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                              ),
                              // fillColor: Colors.blue[50],
                              filled: true,
                              hintText: 'Email',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              focusColor: Palette.appColor,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Palette.appColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            obscureText: true,
                            cursorColor: Palette.appColor,
                            validator: (value) =>
                                value!.isEmpty ? 'Password is required!' : null,
                            onChanged: (value) {
                              password = value;
                            },
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                              ),
                              // fillColor: Colors.blue[50],
                              filled: true,
                              hintText: 'Password',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              focusColor: Palette.appColor,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Palette.appColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Palette.appColor,
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Get.isDarkMode
                                      ? const Color.fromARGB(255, 37, 49, 55)
                                      : Palette.appColor,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    load = true;
                                  });

                                  try {
                                    // await _auth
                                    //     .signInWithEmailAndPassword(
                                    //         email: email, password: password)
                                    //     .then((data) {
                                    //   if (data.user != null) {
                                    //     box.write('id', data.user!.uid);
                                    //     box.write('isLoggedIn', true);
                                    //     Get.offAll(
                                    //       const HomeScreen(),
                                    //     );
                                    //   }
                                    // });
                                    try {
                                      client
                                          .setEndpoint(
                                              'https://exwoo.com/v1') // Your Appwrite Endpoint
                                          .setProject(
                                              '6587168cbc8a1e9b32bb') // Your project ID
                                          .setSelfSigned();
                                      Account account = Account(client);
                                      await account.createEmailSession(
                                        email: email,
                                        password: password,
                                      );
                                      final user = await account.get();
                                      box.put('id', user.$id);
                                      box.put('username', user.name);
                                      box.put('email', user.email);
                                      box.put('isLoggedIn', true);
                                      Get.offAll(
                                        const HomeScreen(),
                                      );
                                    } catch (e) {
                                      Get.rawSnackbar(
                                        message: 'Wrong email or password!',
                                        backgroundColor: Palette.appColor,
                                        snackPosition: SnackPosition.BOTTOM,
                                        margin: const EdgeInsets.all(8.0),
                                        borderRadius: 8.0,
                                        duration: const Duration(seconds: 2),
                                        forwardAnimationCurve:
                                            Curves.easeOutBack,
                                      );
                                    }
                                  } on AppwriteException catch (e) {
                                    print(e.message);
                                  }

                                  setState(() {
                                    load = false;
                                  });
                                }
                              },
                              child: const Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: [
                              Container(
                                color: Colors.grey,
                                height: 1.0,
                                width: MediaQuery.of(context).size.width * 0.4,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              const Text("or"),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Container(
                                color: Colors.grey,
                                height: 1.0,
                                width: MediaQuery.of(context).size.width * 0.4,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(
                                color: Palette.appColor,
                              ),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Get.isDarkMode
                                      ? Colors.white
                                      : Palette.appColor,
                                ),
                              ),
                              onPressed: () {
                                Get.to(
                                  const SignupScreen(),
                                );
                              },
                              child: Center(
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Get.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
