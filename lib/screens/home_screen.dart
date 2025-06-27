import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodify/models/mood_model.dart';
import 'package:moodify/services/supabase_service.dart';
import 'package:moodify/widgets/mood_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _moodsFuture;

  @override
  void initState() {
    super.initState();
    _moodsFuture = Provider.of<SupabaseService>(
      context,
      listen: false,
    ).fetchMoods();
  }

  // Refresh moods function
  void _refreshMoods() {
    setState(() {
      _moodsFuture = Provider.of<SupabaseService>(
        context,
        listen: false,
      ).fetchMoods();
    });
  }

  // Show moods dialog function
  void _showMoodDialog({Mood? mood}) {
    showDialog(
      context: context,
      builder: (context) => MoodDialog(
        mood: mood,
        onSave: () {
          _refreshMoods();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<SupabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Mood'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Consumer<SupabaseService>(
        builder: (context, supabaseService, child) {
          return FutureBuilder(
            future: _moodsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final moods = supabaseService.moods;

              if (moods.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada catatan mood.\nTekan tombol + untuk memulai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Dismissible(
                      key: ValueKey(mood.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await supabaseService.deleteMood(mood.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${mood.mood} dihapus')),
                        );
                      },
                      child: ListTile(
                        leading: Text(
                          mood.mood,
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(
                          mood.note.isEmpty ? 'Tidak ada catatan' : mood.note,
                          style: TextStyle(
                            fontStyle: mood.note.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                            color: mood.note.isEmpty ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat(
                            'EEEE, dd MMMM yyyy - HH:mm',
                          ).format(mood.createdAt),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showMoodDialog(mood: mood),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMoodDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
