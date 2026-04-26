import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/providers.dart';
import '../../core/botw_theme.dart';
import '../auth/login_screen.dart';

class SanctuaryScreen extends ConsumerStatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  ConsumerState<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends ConsumerState<SanctuaryScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final client = ref.read(gatewayClientProvider);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(client.baseUrl));
  }

  void _logout() async {
    final client = ref.read(gatewayClientProvider);
    await client.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('控制台 - 管理与个人'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: BotwTheme.ancientOrange),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('退出控制台'),
                  content: const Text('确定要断开连接并退出吗？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(c);
                        _logout();
                      }, 
                      child: const Text('退出', style: TextStyle(color: BotwTheme.ancientOrange))
                    ),
                  ],
                )
              );
            },
          )
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
