import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:get/get.dart';

AppBar buildAppBar(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final icon = CupertinoIcons.chat_bubble_fill;

  return AppBar(
    leading: BackButton(),
    backgroundColor: kPrimaryColor,
    elevation: 0,
    actions: [

      IconButton(
        icon: Icon(icon),
        onPressed: () {
          Get.toNamed('/chat');

        },
      ),
    ],
  );
}
