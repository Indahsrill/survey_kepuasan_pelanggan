import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kepuasan_pelanggan/views/homepage.dart';

void main() {
  // Setel orientasi aplikasi menjadi landscape
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Upload MySQL',
      home: HomePage(),
    );
  }
}
