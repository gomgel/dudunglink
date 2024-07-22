import 'package:dudung_first/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';

//key password : havefun

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();




  runApp(MaterialApp(home: HomeScreen(),));
}

