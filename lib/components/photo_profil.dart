import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:get/get.dart';

class PhotoProfile extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;

  const PhotoProfile({
    Key key,
    this.imagePath,
    this.isEdit = false,
    this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
         // child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  /*Widget buildEditIcon(Color color) => buildCircle(
    color: Colors.white,
    all: 3,
    child: buildCircle(
      color: color,
      all: 8,
      child: Icon(
        isEdit ? Icons.add_a_photo : Icons.edit,
        color: Colors.white,
        size: 20,
      ),
    ),
  );
*/
  Widget buildEditIcon(Color color) => buildCircle(
    color: Colors.white,
    all: 3,
    child: buildCircle(
      color: color,
      all: 3,
      child: IconButton(
        onPressed:(){Get.toNamed('/editprofil');} ,
        icon: Icon(
          Icons.edit,
          color: Colors.white,
          size: 20,
        ),
      ),
    ),
  );

  Widget buildCircle({
    Widget child,
    double all,
    Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
