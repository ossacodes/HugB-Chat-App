import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../config/loader.dart';
import '../../config/palette.dart';
import '../screens/home_screen.dart';
import '../services/app_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  var box = Hive.box('myData');
  Client client = Client();

  String email = '';

  String password = '';

  String? name;

  String? cPassword;

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
                          'https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/7667b0e4-d180-4b4b-aff4-c1b1d98b30cd/width=450/03585.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          cursorColor: Palette.appColor,
                          validator: (value) =>
                              value!.isEmpty ? 'Name is required!' : null,
                          onChanged: (value) {
                            name = value;
                          },
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            prefixIcon: const Icon(
                              Icons.account_circle,
                            ),
                            // fillColor: Colors.blue[50],
                            filled: true,
                            hintText: 'Name',
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
                          cursorColor: Palette.appColor,
                          validator: (value) =>
                              value!.isEmpty ? 'Email is required!' : null,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value;
                          },
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
                            // fillColor:  Colors.blue[50],
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
                        TextFormField(
                          obscureText: true,
                          cursorColor: Palette.appColor,
                          validator: (value) => value!.isEmpty
                              ? 'Confirm password required!'
                              : null,
                          onChanged: (value) {
                            cPassword = value;
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
                            hintText: 'Confirm Password',
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
                        InkWell(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Palette.appColor,
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: const Center(
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              if (cPassword == password) {
                                setState(() {
                                  load = true;
                                });
                                client
                                    .setEndpoint(
                                        'https://exwoo.com/v1') // Your Appwrite Endpoint
                                    .setProject(
                                        '6587168cbc8a1e9b32bb') // Your project ID
                                    .setSelfSigned();
                                Account account = Account(client);

                                try {
                                  await account
                                      .create(
                                    userId: ID.unique(),
                                    email: email,
                                    password: password,
                                    name: name,
                                  )
                                      .then((value) async {
                                    await account
                                        .createEmailSession(
                                            email: email, password: password)
                                        .then((value) async {
                                      await AppServices().createUser(
                                        value.$id,
                                        name!,
                                        email,
                                      );
                                      box.put('id', value.$id);
                                      box.put('isLoggedIn', true);
                                      Get.offAll(
                                        const HomeScreen(),
                                      );
                                    });
                                  });
                                } catch (e) {
                                  Get.rawSnackbar(
                                    message:
                                        'Username or email already exists!',
                                    backgroundColor: Palette.appColor,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(8.0),
                                    borderRadius: 8.0,
                                    duration: const Duration(seconds: 2),
                                    forwardAnimationCurve: Curves.easeOutBack,
                                  );
                                }

                                setState(() {
                                  load = false;
                                });
                              } else {
                                print("Paswords don't match!");
                              }
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
    );
  }
}
