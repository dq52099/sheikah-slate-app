import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/botw_theme.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _urlController = TextEditingController(text: 'http://10.0.1.70:8324');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSavedAuth();
  }

  Future<void> _checkSavedAuth() async {
    final prefs = ref.read(sharedPrefsProvider);
    final savedUrl = prefs.getString('server_url');
    if (savedUrl != null) {
      _urlController.text = savedUrl;
    }
    
    setState(() => _isLoading = true);
    try {
      final client = ref.read(gatewayClientProvider);
      await client.init(_urlController.text);
      final auth = await client.checkAuth();
      ref.read(authStateProvider.notifier).state = auth;
      ref.read(energyProvider.notifier).state = auth['quota_summary'];
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      // Not logged in or server unreachable
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final url = _urlController.text.trim();
      final client = ref.read(gatewayClientProvider);
      await client.init(url);
      final res = await client.login(_usernameController.text.trim(), _passwordController.text);
      
      final prefs = ref.read(sharedPrefsProvider);
      await prefs.setString('server_url', url);
      
      ref.read(authStateProvider.notifier).state = res['user'];
      ref.read(energyProvider.notifier).state = res['user']['quota_summary'];
      
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('登录失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 80, color: BotwTheme.sheikahBlue),
              const SizedBox(height: 20),
              const Text('连接至控制台网关', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: '网关地址 (Server URL)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '称呼 (Username)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '真名 (Password)'),
              ),
              const SizedBox(height: 32),
              _isLoading 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('缔结契约 (Login)'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
