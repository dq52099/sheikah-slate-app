import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/botw_theme.dart';
import '../../core/providers.dart';

class MaterializerScreen extends ConsumerStatefulWidget {
  const MaterializerScreen({super.key});

  @override
  ConsumerState<MaterializerScreen> createState() => _MaterializerScreenState();
}

class _MaterializerScreenState extends ConsumerState<MaterializerScreen> {
  final TextEditingController _runeController = TextEditingController();

  @override
  void dispose() {
    _runeController.dispose();
    super.dispose();
  }

  void _handleMaterialize() async {
    final runes = _runeController.text.trim();
    if (runes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入古老符文咒语')),
      );
      return;
    }

    final energy = ref.read(energyCellsProvider);
    if (energy <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('能量电池耗尽，请等待恢复')),
      );
      return;
    }

    await ref.read(materializeProvider.notifier).materialize(runes, 1, '1024x1024');
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors
    ref.listen(materializeProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('具现化失败: ${next.error}')),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // --- 背景点阵装饰 ---
          _buildBackgroundGrid(),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildEnergyBattery(),
                  const SizedBox(height: 30),
                  _buildRuneInput(),
                  const SizedBox(height: 30),
                  _buildActionControls(),
                  const SizedBox(height: 30),
                  _buildMaterializeResult(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SHEIKAH SLATE', style: TextStyle(color: BotwTheme.sheikahBlue.withOpacity(0.5), fontSize: 10, letterSpacing: 4)),
            const Text('图像具现化终端', style: TextStyle(color: BotwTheme.sheikahBlue, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const Icon(Icons.settings_input_component, color: BotwTheme.sheikahBlue, size: 32),
      ],
    );
  }

  Widget _buildEnergyBattery() {
    final energyCount = ref.watch(energyCellsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ENERGY CELLS (能量电池)', style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(8, (index) => Container(
            width: 30,
            height: 14,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: index < energyCount ? BotwTheme.energyGreen : Colors.transparent,
              border: Border.all(color: BotwTheme.energyGreen.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(2),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildRuneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INPUT ANCIENT RUNES (古老符文咒语)', style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 12),
        TextField(
          controller: _runeController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: '描述你想要具现化的影像描述...',
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: ['#林克', '#海拉鲁', '#大师剑', '#写实'].map((tag) => InkWell(
            onTap: () {
              setState(() {
                _runeController.text = '${_runeController.text} $tag'.trim();
              });
            },
            child: Chip(
              label: Text(tag, style: const TextStyle(fontSize: 11, color: BotwTheme.sheikahBlue)),
              backgroundColor: BotwTheme.sheikahBlue.withOpacity(0.1),
              side: const BorderSide(color: BotwTheme.sheikahBlue, width: 0.5),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMaterializeResult() {
    final materializeState = ref.watch(materializeProvider);
    
    return materializeState.when(
      data: (urls) {
        if (urls.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('具现化结果', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 12),
            ...urls.map((url) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: BotwTheme.sheikahBlue, width: 1),
              ),
              child: Image.network(
                url,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: BotwTheme.sheikahBlue,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('图片加载失败', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            )).toList(),
          ],
        );
      },
      loading: () => const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: BotwTheme.sheikahBlue),
            SizedBox(height: 16),
            Text('正在具现化影像...', style: TextStyle(color: BotwTheme.sheikahBlue)),
          ],
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(), // Handled via ref.listen
    );
  }

  Widget _buildActionControls() {
    final isLoading = ref.watch(materializeProvider).isLoading;

    return Center(
      child: Column(
        children: [
          // 模拟希卡之石的中心圆环
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: BotwTheme.sheikahBlue, width: 2),
              boxShadow: [
                BoxShadow(color: BotwTheme.sheikahBlue.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: IconButton(
              icon: isLoading 
                ? const CircularProgressIndicator(color: BotwTheme.sheikahBlue)
                : const Icon(Icons.fingerprint, size: 64, color: BotwTheme.sheikahBlue),
              onPressed: isLoading ? null : _handleMaterialize,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isLoading ? '具现化序列运行中...' : '长按开启具现化序列', 
            style: const TextStyle(color: BotwTheme.sheikahBlue, fontSize: 14, letterSpacing: 1)
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGrid() {
    return Opacity(
      opacity: 0.05,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
        itemBuilder: (c, i) => Container(
          decoration: BoxDecoration(border: Border.all(color: BotwTheme.sheikahBlue, width: 0.5)),
        ),
      ),
    );
  }
}
