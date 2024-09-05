import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

// Hi,
// Finally I got a solution.
//
// In manifest file added the following,
// <meta-data android:name="flutterEmbedding" android:value="2" />
//
// And in MainActivity.kt changed into the following,
//
// import androidx.annotation.NonNull;
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugins.GeneratedPluginRegistrant
//
// class MainActivity: FlutterActivity() {
//   override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//     GeneratedPluginRegistrant.registerWith(flutterEngine);
//   }
// }

class InAppWebViewScreen extends StatefulWidget {
  const InAppWebViewScreen({Key? key}) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen>  {

  late final AppLifecycleListener _listener;

  static const _actionTitles = ['do test 01', 'do test 02', 'do test 03'];

  var safeAreaColor = Colors.white;
  var currentUrl = "https://dudunglink.com/";

  var pauseTime = DateTime.now();

  final GlobalKey webViewKey = GlobalKey();

  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;
  double progress = 0;

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onShow: () => _handleTransition('show'),
      onResume: () => _handleTransition('resume'),
      onHide: () => _handleTransition('hide'),
      onInactive: () => _handleTransition('inactive'),
      onPause: () {
        _handleTransition('pause');
        pauseTime = DateTime.now();
      },
      onDetach: () => _handleTransition('detach'),
      onRestart: () async{
        _handleTransition('restart - ${DateTime.now().difference(pauseTime).inMinutes.toString()}');


        //backgroud 로 프로그램을 보내고 재시작 시 10분을 초과 하면 화면 전체를 다시 그려주자..
        if (DateTime.now().difference(pauseTime).inMinutes > 10) {

        }
            _handleTransition('setState()..');
            final refreshUrl = await webViewController.getUrl();

            if (defaultTargetPlatform == TargetPlatform.android) {
              webViewController.reload();
            } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
              //debugPrint('TargetPlatform.iOS');
              //webViewController.loadUrl(urlRequest: URLRequest(url: refreshUrl));

              setState(() {
                webViewController.scrollTo(x: 0, y: 0);

                webViewController
                    .loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')))
                    .then((value) => webViewController.loadUrl(urlRequest: URLRequest(url: refreshUrl)));
              });
        }
      },
      // This fires for each state change. Callbacks above fire only for
      // specific state transitions.
      //onStateChange: _handleStateChange,
    );

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(
              color: Colors.grey.withOpacity(.5),
            ),
            onRefresh: () async {
              final refreshUrl = await webViewController.getUrl();

              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
                debugPrint('TargetPlatform.iOS');
                //webViewController.loadUrl(urlRequest: URLRequest(url: refreshUrl));

                setState(() {
                  webViewController.scrollTo(x: 0, y: 0);

                  webViewController
                      .loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')))
                      .then((value) => webViewController.loadUrl(urlRequest: URLRequest(url: refreshUrl)));
                });
              }
            },
          ))!;
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
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

  void _handleTransition(String name) {
    debugPrint(name);
    // setState(() {
    //   _states.add(name);
    // });
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   duration: const Duration(milliseconds: 200),
    //   curve: Curves.easeOut,
    // );
  }


  @override
  Widget build(BuildContext context) {
    Uri myUrl = Uri.parse(currentUrl);

    return Scaffold(
      backgroundColor: safeAreaColor,
      resizeToAvoidBottomInset: defaultTargetPlatform == TargetPlatform.android ? true : false,
      // floatingActionButton: ExpandableFab(
      //   distance: 112,
      //   children: [
      //     ActionButton(
      //       onPressed: () {
      //         debugPrint('do test 01');
      //       },
      //       icon: const Icon(Icons.format_size),
      //     ),
      //     ActionButton(
      //       onPressed: () {
      //         debugPrint('do test 02');
      //       },
      //       icon: const Icon(Icons.insert_photo),
      //     ),
      //     ActionButton(
      //       onPressed: () {
      //         debugPrint('do test 03');
      //       },
      //       icon: const Icon(Icons.videocam),
      //     ),
      //   ],
      // ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: PopScope(
          onPopInvoked: (bi) => _goBack(context),
          child: Column(
            children: [
              Expanded(
                child: InAppWebView(
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
                    ),
                  ),
                  pullToRefreshController: pullToRefreshController,
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    debugPrint(url!.toString());

                    if (url!.toString().contains('https://dudunglink.com/s/link')) {
                      if (this.safeAreaColor == Colors.black87) {
                      } else {
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
                  shouldOverrideUrlLoading: (controller, action) async {
                    return NavigationActionPolicy.ALLOW;
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

                  onReceivedServerTrustAuthRequest: (controller, challenge) async{
                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0; i < count; i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    super.key,
    required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      height: isBig ? 128 : 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.grey.shade300,
      ),
    );
  }
}
