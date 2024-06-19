import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kepuasan_pelanggan/views/uploadpage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool onLoading = false;
  bool canContinue = false;
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    connectionCheck();
    startClock();
  }

  void startClock() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final now = DateTime.now();
        currentTime = DateFormat('HH:mm:ss')
            .format(now); // Format waktu dengan detik dan hari
      });
    });
  }

  Future<void> connectionCheck() async {
    Uri uri = Uri.parse("http://213.218.240.102/");
    var request = http.MultipartRequest("GET", uri);

    setState(() {
      onLoading = true;
    });
    try {
      var response = await request.send().timeout(const Duration(seconds: 50));
      if (response.statusCode == 200) {
        setState(() {
          canContinue = true;
        });
      } else {
        setState(() {
          canContinue = false;
        });
      }
    } catch (error) {
      setState(() {
        canContinue = false;
      });
    }

    setState(() {
      onLoading = false;
    });
  }

  void _navigateToUploadPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 1),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UploadPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Selamat Datang!",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 251, 255, 255),
          ), // Increase the font size here
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 227, 48, 111),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.3, // Set the opacity to make the image less intense
            child: Image.asset(
              'lib/assets/images/kemenag_ri-kemenag.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'Survey Kepuasan Pelayanan Kemenag',
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: true,
                    totalRepeatCount: 100,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    currentTime,
                    style: const TextStyle(
                      fontSize: 60,
                      color: Color.fromARGB(255, 50, 50, 50),
                    ),
                  ),
                  const SizedBox(height: 80),
                  onLoading
                      ? const SpinKitFadingCircle(
                          color: Color.fromARGB(255, 227, 48, 111),
                          size: 50.0,
                        )
                      : ElevatedButton(
                          onPressed: canContinue
                              ? () => _navigateToUploadPage(context)
                              : connectionCheck,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(300, 100), // Increase button size
                            backgroundColor: canContinue
                                ? Color.fromARGB(255, 227, 48, 111)
                                : Color.fromARGB(255, 227, 48, 111),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5), // Rounded corners with radius 5
                            ),
                          ),
                          child: Text(
                            canContinue ? "Start" : "Try Again",
                            style: const TextStyle(
                              fontSize: 45,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const Spacer(),
                  const Text(
                    '© LPPM UIN Sunan Gunung Djati Bandung 2024',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 50, 50, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
