import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  double progress = 0;
  var urlController = TextEditingController();
  var initialUrl = "https://tdbsewallet.com/";
  bool inLoading = false;

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(true);
    }
  }

  @override
  void initState() {
    super.initState();
    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
          color: Colors.white,
          backgroundColor: Colors.blue,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _goBack(context);
      },
      child: Scaffold(
        /*appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("TDBSE"),
                Text(
                  "WALLET",
                  style: TextStyle(color: Color(0xff9c27b0)),
                )
              ],
            ),
          ),
          leading: IconButton(
            onPressed: () async {
              if (await webViewController!.canGoBack()) {
                webViewController!.goBack();
              }
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  webViewController!.reload();
                },
                icon: const Icon(Icons.refresh))
          ],
        ),*/
        body: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InAppWebView(
                    onLoadStart: (controller, url){
                      setState(() {
                        inLoading=true;
                      });
                    },
                    onLoadStop: (controller, url) {
                      refreshController!.endRefreshing();
                      setState(() {
                        inLoading=false;
                      });
                    },
                    onProgressChanged: (controller, progress){
                      if(progress == 100){
                        refreshController!.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress /100;
                      });
                    },
                    pullToRefreshController: refreshController,
                    onWebViewCreated: (controller) =>
                        webViewController = controller,
                    initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                  ),
                   Visibility(
                    visible: inLoading,
                      child:  CircularProgressIndicator(
                        value: progress,
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
