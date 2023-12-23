import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hugb/auth/login_screen.dart';
import 'package:hugb/config/loader.dart';
import 'package:hugb/screens/home_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  var box = Hive.box('myData');

  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // box.put('id', null);
    if (box.get('id') != null) {
      isLoggedIn = true;
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loader()
        : isLoggedIn
            ? const HomeScreen()
            : const LoginScreen();
  }
}
