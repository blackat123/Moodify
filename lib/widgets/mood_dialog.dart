import 'package:flutter/material.dart';
import 'package:moodify/models/mood_model.dart';
import 'package:moodify/services/supabase_service.dart';
import 'package:moodify/utils/constants.dart';
import 'package:provider/provider.dart';

class MoodDialog extends StatefulWidget {
  final Mood? mood;
  final VoidCallback onSave;

  const MoodDialog({super.key, this.mood, required this.onSave});

  @override
  State<MoodDialog> createState() => _MoodDialogState();
}

class _MoodDialogState extends State<MoodDialog> {
  late String _selectedMood;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.mood?.mood ?? moodEmojis[0];
    _noteController.text = widget.mood?.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Submit function
  void _submit() async {
    final service = Provider.of<SupabaseService>(context, listen: false);
    try {
      if (widget.mood == null) {
        await service.addMood(
          mood: _selectedMood,
          note: _noteController.text.trim(),
        );
      } else {
        await service.updateMood(
          id: widget.mood!.id,
          mood: _selectedMood,
          note: _noteController.text.trim(),
        );
      }
      widget.onSave();
      Navigator.of(context).pop();
    } catch (err) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${err.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mood == null ? 'Bagaimana perasaanmu?' : 'Edit Mood'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Mood:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: moodEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = emoji;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedMood == emoji
                          ? Colors.deepPurple.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: _selectedMood == emoji
                            ? Colors.deepPurple
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
