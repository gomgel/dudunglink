import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  const InAppWebViewExampleScreen({Key? key}) : super(key: key);

  @override
  State<InAppWebViewExampleScreen> createState() => _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  final GlobalKey webViewKey = GlobalKey();

  var safeAreaColor = Colors.white;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptCanOpenWindowsAutomatically: true,
        javaScriptEnabled: true,
        useOnDownloadStart: true,
        useOnLoadResource: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        verticalScrollBarEnabled: true,
        userAgent: 'random',
        transparentBackground: true,
      ),
      android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          allowContentAccess: true,
          builtInZoomControls: true,
          thirdPartyCookiesEnabled: true,
          allowFileAccess: true,
          supportMultipleWindows: true),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        allowsBackForwardNavigationGestures: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.grey.withOpacity(.5),
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {

          final refreshUrl = await webViewController?.getUrl();

          setState(
            () {
              webViewController?.scrollTo(x: 0, y: 0);

              webViewController
                  ?.loadUrl(
                    urlRequest: URLRequest(
                      url: Uri.parse('about:blank'),
                    ),
                  )
                  .then(
                    (value) => webViewController?.loadUrl(
                      urlRequest: URLRequest(url: refreshUrl),
                    ),
                  );
            },
          );

          //webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: safeAreaColor,
      resizeToAvoidBottomInset: defaultTargetPlatform == TargetPlatform.android ? true : false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(

                    key: webViewKey,
                    // contextMenu: contextMenu,
                    initialUrlRequest: URLRequest(url: Uri.parse("https://dudunglink.com")),
                    // initialFile: "assets/index.html",
                    initialUserScripts: UnmodifiableListView<UserScript>([]),
                    initialOptions: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                      });
                    },
                    androidOnPermissionRequest: (controller, origin, resources) async {
                      return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                        if (await canLaunch(url)) {
                          // Launch the App
                          await launch(
                            url,
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      if (url!.toString().contains('https://dudunglink.com/s/link')) {
                        if (this.safeAreaColor == Colors.black87) {
                        } else {
                          this.safeAreaColor = Colors.black87;
                        }
                      } else {
                        if (this.safeAreaColor == Colors.white) {
                        } else {
                          this.safeAreaColor = Colors.white;
                        }
                      }

                      setState(() {
                        this.url = url.toString();
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },

                    onCreateWindow: (controller, createWindowAction) async {
                      var url = createWindowAction.request.url;
                      var uri = Uri.parse(url.toString());

                      launchUrl(uri);

                      // return true to tell that we are handling the new window creation action
                      return true;
                    },

                    onReceivedServerTrustAuthRequest: (controller, challenge) async {
                      return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                    },
                  ),
                  //progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
