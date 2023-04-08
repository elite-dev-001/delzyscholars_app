import 'dart:async';

import 'package:delzyscholars/pages/carousel_page.dart';
// import 'package:delzyscholars/pages/categories.dart';
// import 'package:delzyscholars/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Color(0xffe7f8ee), body: SplashScreen()),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void nextPage() => Timer(
      const Duration(seconds: 4),
      () => Navigator.push(
          context, MaterialPageRoute(builder: (builder) => const MyCarousel())));


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nextPage();
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo2.png'),
          ],
        ));
  }
}
