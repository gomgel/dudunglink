import 'package:dudung_first/screen/home_screen.dart';
import 'package:dudung_first/screen/inappwebview_screen.dart';
import 'package:dudung_first/screen/test_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';

//key password : havefun
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);



  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.bottom,
      SystemUiOverlay.top,
    ],
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InAppWebViewScreen(),
    ),
  );
}
