import 'package:dudung_first/screen/home_screen.dart';
import 'package:dudung_first/screen/inappwebview_screen.dart';
import 'package:dudung_first/screen/test_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

//key password : havefun
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();



  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);



  await Future.delayed(const Duration(milliseconds: 500));
  FlutterNativeSplash.remove();

  if (defaultTargetPlatform == TargetPlatform.android) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    await Permission.camera.request();
    //await Permission.storage.request();
    await Permission.photos.request();
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Permission.camera.request();
    await Permission.photos.request();
  }


  // Future.delayed(const Duration(seconds: 5), () {
  //   SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.manual,
  //     overlays: [
  //       SystemUiOverlay.bottom,
  //       SystemUiOverlay.top,
  //     ],
  //   );
  // });

  // await SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.manual,
  //   overlays: [
  //     SystemUiOverlay.bottom,
  //     SystemUiOverlay.top,
  //   ],
  // );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InAppWebViewScreen(),
    ),
  );
}
