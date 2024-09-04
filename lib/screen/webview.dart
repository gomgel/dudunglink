import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';


import '../pull_to_refresh.dart';

class MyWebViewWidget extends StatefulWidget {
  final String initialUrl;

  const MyWebViewWidget({
    Key? key,
    required this.initialUrl,
  }) : super(key: key);

  @override
  State<MyWebViewWidget> createState() => _MyWebViewWidgetState();
}

class _MyWebViewWidgetState extends State<MyWebViewWidget> with WidgetsBindingObserver {
  late WebViewController _controller;
  late DragGesturePullToRefresh dragGesturePullToRefresh; // Here

  @override
  void initState() {
    super.initState();

    dragGesturePullToRefresh = DragGesturePullToRefresh(3000, 100); // Here
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request){
            if (request.url.startsWith("https://dudunglink.com")) {
              return NavigationDecision.navigate;
            } else {
              _doLaunchURL(request.url);
              return NavigationDecision.prevent;
            }
          },
          onPageStarted: (String url) {
            // Don't allow RefreshIndicator if page is loading, but not needed
            dragGesturePullToRefresh.started(); // Here
          },
          onPageFinished: (String url) {
            // Hide RefreshIndicator for page reload if showing
            dragGesturePullToRefresh.finished(); // Here
          },
          onWebResourceError: (WebResourceError error) {
            //debugPrint('MyWebViewWidget:onWebResourceError(): ${error.description}');
            // Hide RefreshIndicator for page reload if showing
            dragGesturePullToRefresh.finished(); // Here
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));

    if (_controller.platform is WebKitWebViewController) {
      (_controller.platform as WebKitWebViewController).setAllowsBackForwardNavigationGestures(true);
    }

    dragGesturePullToRefresh // Here
        .setController(_controller)
        .setDragHeightEnd(200)
        .setDragStartYDiff(30)
        .setWaitToRestart(3000);

    WidgetsBinding.instance.addObserver(this);
  }

  _doLaunchURL(String url) async {
    await launchUrl(Uri.parse(url.toString()));
  }

  @override
  void dispose() {
    // remove listener
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // on portrait / landscape or other change, recalculate height
    //dragGesturePullToRefresh.setHeight(MediaQuery.of(context).size.height); // Here
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          //displacement: 250,
          //backgroundColor: Colors.yellow,
          //color: Colors.red,
          //strokeWidth: 3,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: dragGesturePullToRefresh.refresh, // Here
          child: Builder(
            builder: (context) {
              // IMPORTANT: Use the RefreshIndicator context!
              dragGesturePullToRefresh.setContext(context); // Here

              var verticalGestures = Factory<VerticalDragGestureRecognizer>(() => dragGesturePullToRefresh);
              var gestureSet = {verticalGestures};

              return WebViewWidget(
                controller: _controller,
                gestureRecognizers: gestureSet,
                //gestureRecognizers: {Factory(() => dragGesturePullToRefresh)}, // HERE
              );
            },
          ),
        ),
      ),
    );
  }
}

// PopScope(
// onPopInvoked: (bi) {
// print('onPopInvoked');
// _controller.goBack();
// },
