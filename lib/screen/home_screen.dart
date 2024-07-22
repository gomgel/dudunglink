import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setUserAgent('random')
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) async {
          if (request.url.startsWith('https://dudunglink.com')) {
            return NavigationDecision.navigate;
          } else {
            final Uri url = Uri.parse(request.url);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              throw 'Could not launch ${request.url}';
            }
            return NavigationDecision.prevent;
          }
        },
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
      ),
    )
    ..loadRequest(Uri.parse('https://dudunglink.com/'));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // return Scaffold(
    //   body: SafeArea(child: WebViewWidget(controller: controller, )),
    // );

    return PopScope(
      onPopInvoked: (bi) {
        controller.goBack();
        print('go back');
      },
      child: Scaffold(
        backgroundColor: const Color(0x00000000),
        body: SafeArea(
          child: WebViewWidget(
            controller: controller,
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: SafeArea(child: WebViewWidget(controller: controller, )),
    // );
  }

  // launchUrl(String url) async {
  //   final Uri url0 = Uri.parse(url);
  //   if (await canLaunchUrl(url0)) {
  //     await launchUrl(url);
  //   } else {
  //     throw 'Could not launch $url0';
  //   }
  // }
}
