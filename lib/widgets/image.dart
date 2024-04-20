// widgets/image.dart

import 'package:flutter/material.dart';

class PlaceholderImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.grey,
      child: Icon(
        Icons.photo,
        size: 50,
        color: Colors.grey,
      ),
      alignment: Alignment.center,
    );
  }
}