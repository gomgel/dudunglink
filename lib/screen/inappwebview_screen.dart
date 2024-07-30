import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewScreen extends StatefulWidget {
  const InAppWebViewScreen({Key? key}) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  var safeAreaColor = Colors.white;
  var currentUrl = "https://dudunglink.com/";

  final GlobalKey webViewKey = GlobalKey();

  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();

    // Future.delayed(const Duration(seconds: 5), () {
    //   SystemChrome.setEnabledSystemUIMode(
    //     SystemUiMode.manual,
    //     overlays: [
    //       //SystemUiOverlay.bottom,
    //       SystemUiOverlay.top,
    //     ],
    //   );
    // });

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(
              color: Colors.grey.withOpacity(.5),
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));
              }
            },
          ))!;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SafeArea(
  //         child: Center(
  //       child: Text('test'),
  //     )),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Uri myUrl = Uri.parse(currentUrl);

    return Scaffold(
      backgroundColor: safeAreaColor,
      floatingActionButton: FloatingActionButton(onPressed: () {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [
            //SystemUiOverlay.bottom,
            SystemUiOverlay.top,
          ],
        );
      },
      child: Icon(Icons.add),),
      body: SafeArea(
        child: PopScope(
          onPopInvoked: (bi) => _goBack(context),
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: myUrl),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptCanOpenWindowsAutomatically: true,
                    javaScriptEnabled: true,
                    useOnDownloadStart: true,
                    useOnLoadResource: true,
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: true,
                    allowFileAccessFromFileURLs: true,
                    allowUniversalAccessFromFileURLs: true,
                    verticalScrollBarEnabled: true,
                    userAgent: 'random',
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
                  ),
                ),
                pullToRefreshController: pullToRefreshController,
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  debugPrint('onupdate');
                  debugPrint(url!.toString());

                  if (url!.toString().contains('https://dudunglink.com/s/link')) {
                    debugPrint('true');
                    if (this.safeAreaColor == Colors.black87) {
                    } else {
                      debugPrint('color changed...');
                      setState(() {
                        this.safeAreaColor = Colors.black87;
                        this.currentUrl = url.host;
                      });
                    }
                  } else {
                    debugPrint('false');

                    if (this.safeAreaColor == Colors.white) {
                    } else {
                      setState(() {
                        this.safeAreaColor = Colors.white;
                        this.currentUrl = url.host;
                      });
                    }
                  }

                  return;
                },
                onLoadStart: (InAppWebViewController controller, uri) {
                  setState(() {
                    myUrl = uri!;
                  });
                },
                onLoadStop: (InAppWebViewController controller, uri) {
                  setState(() {
                    myUrl = uri!;
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                androidOnPermissionRequest: (controller, origin, resources) async {
                  return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                },
                onWebViewCreated: (InAppWebViewController controller) {
                  webViewController = controller;
                },
                onCreateWindow: (controller, createWindowAction) async {
                  var url = createWindowAction.request.url;
                  var uri = Uri.parse(url.toString());

                  launchUrl(uri);

                  // return true to tell that we are handling the new window creation action
                  return true;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //   return Scaffold(
  //     backgroundColor: safeAreaColor,
  //     body: SafeArea(
  //       child: PopScope(
  //         onPopInvoked: (bi) => _goBack(context),
  //         child: Column(
  //           children: <Widget>[
  //             //progress < 1.0 ? LinearProgressIndicator(value: progress, color: Colors.blue) : Container(),
  //             Expanded(
  //               child: Stack(
  //                 children: [
  //                   InAppWebView(
  //                     key: webViewKey,
  //                     initialUrlRequest: URLRequest(url: myUrl),
  //                     initialOptions: InAppWebViewGroupOptions(
  //                       crossPlatform: InAppWebViewOptions(
  //                         javaScriptCanOpenWindowsAutomatically: true,
  //                         javaScriptEnabled: true,
  //                         useOnDownloadStart: true,
  //                         useOnLoadResource: true,
  //                         useShouldOverrideUrlLoading: true,
  //                         mediaPlaybackRequiresUserGesture: true,
  //                         allowFileAccessFromFileURLs: true,
  //                         allowUniversalAccessFromFileURLs: true,
  //                         verticalScrollBarEnabled: true,
  //                         userAgent: 'random',
  //                       ),
  //                       android: AndroidInAppWebViewOptions(
  //                           useHybridComposition: true,
  //                           allowContentAccess: true,
  //                           builtInZoomControls: true,
  //                           thirdPartyCookiesEnabled: true,
  //                           allowFileAccess: true,
  //                           supportMultipleWindows: true),
  //                       ios: IOSInAppWebViewOptions(
  //                         allowsInlineMediaPlayback: true,
  //                         allowsBackForwardNavigationGestures: true,
  //                       ),
  //                     ),
  //                     pullToRefreshController: pullToRefreshController,
  //                     onUpdateVisitedHistory: (controller, url, androidIsReload) {
  //                       debugPrint('onupdate');
  //                       debugPrint(url!.toString());
  //
  //                       if (url!.toString().contains('https://dudunglink.com/s/link')) {
  //                         debugPrint('true');
  //                         if (this.safeAreaColor == Colors.black87) {
  //                         } else {
  //                           debugPrint('color changed...');
  //                           setState(() {
  //                             this.safeAreaColor = Colors.black87;
  //                             this.currentUrl = url.host;
  //                           });
  //                         }
  //                       } else {
  //                         debugPrint('false');
  //
  //                         if (this.safeAreaColor == Colors.white) {
  //                         } else {
  //                           setState(() {
  //                             this.safeAreaColor = Colors.white;
  //                             this.currentUrl = url.host;
  //                           });
  //                         }
  //                       }
  //
  //                       return;
  //
  //                     },
  //                     onLoadStart: (InAppWebViewController controller, uri) {
  //                       setState(() {
  //                         myUrl = uri!;
  //                       });
  //                     },
  //                     onLoadStop: (InAppWebViewController controller, uri) {
  //                       setState(() {
  //                         myUrl = uri!;
  //                       });
  //                     },
  //                     onProgressChanged: (controller, progress) {
  //                       if (progress == 100) {
  //                         pullToRefreshController.endRefreshing();
  //                       }
  //                       setState(() {
  //                         this.progress = progress / 100;
  //                       });
  //                     },
  //                     androidOnPermissionRequest: (controller, origin, resources) async {
  //                       return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
  //                     },
  //                     onWebViewCreated: (InAppWebViewController controller) {
  //                       webViewController = controller;
  //                     },
  //                     onCreateWindow: (controller, createWindowAction) async {
  //                       var url = createWindowAction.request.url;
  //                       var uri = Uri.parse(url.toString());
  //
  //                       launchUrl(uri);
  //
  //                       // return true to tell that we are handling the new window creation action
  //                       return true;
  //                     },
  //                   )
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
