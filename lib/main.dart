import 'package:dudung_first/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

//key password : havefun

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();

  runApp(MaterialApp(home: HomeScreen(),));
}

