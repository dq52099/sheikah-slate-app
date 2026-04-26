import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gateway_client.dart';

/// Provider for the GatewayClient to interact with the backend.
final gatewayClientProvider = Provider<GatewayClient>((ref) {
  return GatewayClient(
    baseUrl: 'http://127.0.0.1:8324',
    apiKey: 'placeholder-api-key',
  );
});

/// Provider for "Energy Cells" (mock quota), initially 8.
final energyCellsProvider = StateProvider<int>((ref) => 8);

/// Notifier for image generation state.
class MaterializeNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // Initial state is an empty list of URLs.
    return [];
  }

  /// Calls GatewayClient.materialize and updates state.
  /// Decrements energy cells upon success.
  Future<void> materialize(String runes, int count, String size) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(gatewayClientProvider);
      final urls = await client.materialize(runes, count, size);
      
      // Decrement energy cells on success
      ref.read(energyCellsProvider.notifier).update((current) => current > 0 ? current - 1 : 0);
      
      return urls;
    });
  }
}

/// AsyncNotifierProvider for materializing images.
final materializeProvider = AsyncNotifierProvider<MaterializeNotifier, List<String>>(() {
  return MaterializeNotifier();
});
