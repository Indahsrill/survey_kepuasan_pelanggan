import 'package:flutter/material.dart';
//import 'package:kepuasan_pelanggan/views/UploadPage.dart';
import 'package:kepuasan_pelanggan/views/homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Upload MySQL',
      home: HomePage(),
    );
  }
}
