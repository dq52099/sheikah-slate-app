import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers.dart';
import '../../core/botw_theme.dart';

class ChronogearScreen extends ConsumerStatefulWidget {
  const ChronogearScreen({super.key});

  @override
  ConsumerState<ChronogearScreen> createState() => _ChronogearScreenState();
}

class _ChronogearScreenState extends ConsumerState<ChronogearScreen> {
  final TextEditingController _spellController = TextEditingController();
  File? _imageFile;
  int _count = 1;
  String _size = '1024x1024';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mana = ref.watch(energyProvider);
    final editQuota = mana['edit'];
    final remain = editQuota['is_unlimited'] == true ? '无限' : '${editQuota['remaining']} / ${editQuota['total']}';
    final materializerState = ref.watch(materializerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('时间回溯 - 改图')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildManaStatus(remain),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: BotwTheme.slateStone.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BotwTheme.sheikahBlue.withOpacity(0.5)),
                ),
                child: _imageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: BotwTheme.sheikahBlue),
                          SizedBox(height: 8),
                          Text('点击选择需要回归的原图'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('修正符文 (Edit Prompt)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _spellController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '描述你想要如何改变这张图...'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: materializerState.isLoading || _imageFile == null ? null : () {
                  ref.read(materializerProvider.notifier).recall(
                    _spellController.text, _imageFile!.path, _count, _size
                  );
                },
                child: materializerState.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('开始时间回溯', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
            materializerState.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox();
                return Column(
                  children: items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(item['url']),
                    ),
                  )).toList(),
                );
              },
              error: (err, _) => Text('回归失败: $err', style: const TextStyle(color: BotwTheme.ancientOrange)),
              loading: () => const Center(child: Text('时间回溯中...')),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildManaStatus(String remain) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BotwTheme.slateStone.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_toggle_off, color: BotwTheme.energyGreen),
          const SizedBox(width: 12),
          Text('改图电池: $remain', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
