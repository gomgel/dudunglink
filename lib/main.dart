import 'package:dudung_first/screen/home_screen.dart';
import 'package:dudung_first/screen/inappwebview_screen.dart';
import 'package:dudung_first/screen/test_screen.dart';
import 'package:dudung_first/screen/webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
    //await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    await Permission.camera.request();
    await Permission.photos.request();
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Permission.photos.request();
    await Permission.camera.request();
    await Permission.microphone.request();
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
    //  home: HomeScreen(),
      home: MyWebViewWidget( initialUrl: 'https://dudunglink.com',),
    ),
  );
}

/*
* iOS 빌드 캐시 삭제
      cd ios
      rm Podfile.lock
      rm Podfile
      rm -rf Pods

      pod cache clean --all

*flutter 캐시 삭제 및 dependency 재설치
      cd .. (상위 폴더로 되돌아가기)
      flutter clean
      flutter pub get

*pod 재설치
    cd ios
    pod install
*
* */
