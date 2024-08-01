import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap : (){setState(() {
      FlutterNativeSplash.remove();
    });}, child: Scaffold(backgroundColor : Colors.yellow, body: SafeArea(child: Center(child: Text('test'),),),));
  }
}
