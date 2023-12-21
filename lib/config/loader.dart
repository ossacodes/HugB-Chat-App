import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'palette.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SpinKitThreeBounce(
        color: Get.isDarkMode ?  Colors.white  : Palette.appColor,
        size: 50.0,
      ),
    );
  }
}
