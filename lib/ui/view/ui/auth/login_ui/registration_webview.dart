import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RegistrationWebView extends StatefulWidget {
  final String url;

  const RegistrationWebView({super.key, required this.url});

  @override
  State<RegistrationWebView> createState() => _RegistrationWebViewState();
}

class _RegistrationWebViewState extends State<RegistrationWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.close,color: Colors.black,),
          onPressed: () => Navigator.of(context).pop(),
          
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            
            
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

           
            // Positioned(
            //   top: 10,
            //   left: 10,
            //   child: Container(
            //     decoration: const BoxDecoration(
            //       color: Colors.white70, 
            //       shape: BoxShape.circle,
            //     ),
            //     child: IconButton(
            //       icon: const Icon(Icons.arrow_back, color: Colors.black87),
            //       onPressed: () {
            //         Navigator.of(context).pop(); 
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}