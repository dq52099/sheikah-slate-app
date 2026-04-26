import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gateway_client.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final gatewayClientProvider = Provider<GatewayClient>((ref) {
  return GatewayClient();
});

final authStateProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final energyProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'generate': {'remaining': 0, 'total': 0, 'used': 0},
  'edit': {'remaining': 0, 'total': 0, 'used': 0},
});

final materializerProvider = AsyncNotifierProvider<MaterializerNotifier, List<dynamic>>(() {
  return MaterializerNotifier();
});

class MaterializerNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async => [];

  Future<void> materialize(String runes, int count, String size, String quality, String background) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(gatewayClientProvider);
      final res = await client.materialize(runes, count, size, quality, background);
      ref.read(energyProvider.notifier).state = res['quota_summary'];
      state = AsyncValue.data(res['data']);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recall(String runes, String imagePath, int count, String size) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(gatewayClientProvider);
      final res = await client.recall(runes, imagePath, count, size);
      ref.read(energyProvider.notifier).state = res['quota_summary'];
      state = AsyncValue.data(res['data']);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
