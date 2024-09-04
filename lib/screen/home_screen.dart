import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var safeAreaColor = Colors.white;
  var loadUrl = 'https://dudunglink.com';

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  //https://dudunglink.com/s/link

  var controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setUserAgent('random');
  // ..setNavigationDelegate(
  //   NavigationDelegate(
  //     onNavigationRequest: (request) async {
  //       if (request.url.startsWith('https://dudunglink.com')) {
  //         if (request.url.startsWith('https://dudunglink.com/s/link')) {
  //           return NavigationDecision.navigate;
  //         } else {
  //           return NavigationDecision.navigate;
  //         }
  //       } else {
  //         final Uri url = Uri.parse(request.url);
  //         if (await canLaunchUrl(url)) {
  //           await launchUrl(url);
  //         } else {
  //           throw 'Could not launch ${request.url}';
  //         }
  //         return NavigationDecision.prevent;
  //       }
  //     },
  //     onProgress: (int progress) {
  //       // Update loading bar.
  //     },
  //     onPageStarted: (String url) {},
  //     onPageFinished: (String url) {},
  //     onWebResourceError: (WebResourceError error) {},
  //   ),
  // );
  //..loadRequest(Uri.parse('https://dudunglink.com/'));

  void changeBackgroundColor() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.loadRequest(Uri.parse(loadUrl));
    controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) async {
          debugPrint(request.url);
          if (request.url.startsWith(loadUrl)) {
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
        onPageStarted: (String url) {
          debugPrint('page started $url');
        },
        onPageFinished: (String url) {
          debugPrint('page Finished $url');
        },
        onUrlChange: (urlChange) {
          debugPrint('object${urlChange.url}');

          if (urlChange.url!.contains('https://dudunglink.com/s/link')) {
            if (this.safeAreaColor == Colors.black87) {
            } else {
              setState(() {
                this.safeAreaColor = Colors.black87;
                this.loadUrl = urlChange.url!;
              });
            }
          } else {
            if (this.safeAreaColor == Colors.white) {
            } else {
              setState(() {
                this.safeAreaColor = Colors.white;
                this.loadUrl = urlChange.url!;
              });
            }
          }
        },
        onWebResourceError: (WebResourceError error) {},
      ),
    );

    return PopScope(
      onPopInvoked: (bi) {
        controller.goBack();
        debugPrint('go back');
      },
      child: Scaffold(
        backgroundColor: safeAreaColor,
        extendBodyBehindAppBar: true,
        appBar: null,
        body: SafeArea(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            controller: _refreshController,
            header:  WaterDropHeader(),
            onRefresh: () {
              controller.reload();
              _refreshController.refreshCompleted();
            },
            onLoading: (){
              _refreshController.loadComplete();
            },
            child: WebViewWidget(controller: controller),
          ),
        ),
      ),
    );
  }
}
