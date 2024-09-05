import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MyWebWiew extends StatefulWidget {
  const MyWebWiew({Key? key}) : super(key: key);

  @override
  _MyWebWiewState createState() => _MyWebWiewState();
}

class _MyWebWiewState extends State<MyWebWiew> with WidgetsBindingObserver {
  WebViewController? _webViewController;

  // height of the WebView with the loaded content
  double? _webViewHeight;
  // is true while a page loading is in progress
  bool _isPageLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("https://dudunglink.com")) {
              return NavigationDecision.navigate;
            } else {
              //_doLaunchURL(request.url);
              return NavigationDecision.prevent;
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isPageLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isPageLoading = false;
            });
            // if page load is finished, set height
            _setWebViewHeight();
          },
          onWebResourceError: (WebResourceError error) {
            //debugPrint('MyWebViewWidget:onWebResourceError(): ${error.description}');
            // Hide RefreshIndicator for page reload if showing
          },
        ),
      )
      ..loadRequest(Uri.parse('https://dudunglink.com'));

    if (_webViewController?.platform is WebKitWebViewController) {
      (_webViewController?.platform as WebKitWebViewController).setAllowsBackForwardNavigationGestures(true);
    }

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // remove listener
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // on portrait / landscape or other change, recalculate height
    _setWebViewHeight();
  }

  @override
  Widget build(BuildContext context) {
    // on initial loading, get height using MediaQuery,
    // this will be used until page is loaded
    if (_webViewHeight == null) {
      final initalWebViewHeight = MediaQuery.of(context).size.height;
      print('WebView inital height set to: $initalWebViewHeight');
      _webViewHeight = initalWebViewHeight;
    }

    return RefreshIndicator(
        // reload page
        onRefresh: () => _webViewController!.reload(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: _webViewHeight,
            child: WebViewWidget(
              controller: _webViewController!,
            ),
          ),
        ));
  }

  void _setWebViewHeight() async {
    // we don't update if WebView is not ready yet
    // or page load is in progress
    if (_webViewController == null || _isPageLoading) {
      return;
    }
    // execute JavaScript code in the loaded page
    // to get body height
    // _webViewController!.runJavaScriptReturningResult('document.body.clientHeight').then((documentBodyHeight) {
    //   // set height
    //   setState(() {
    //     print('WebView height set to: $documentBodyHeight');
    //     _webViewHeight = double.parse('2000');
    //   });
    // });

    var x = await _webViewController?.runJavaScriptReturningResult("document.documentElement.scrollHeight");
    double? y = double.tryParse(x.toString());
    _webViewHeight = y;
  }
}
