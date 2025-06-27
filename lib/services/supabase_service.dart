import 'package:flutter/material.dart';
import 'package:moodify/main.dart';
import 'package:moodify/models/mood_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends ChangeNotifier {
  List<Mood> _moods = [];

  List<Mood> get moods => _moods;

  // Sign up function
  Future<void> signUp(String email, String password) async {
    try {
      await supabase.auth.signUp(email: email, password: password);
    } on AuthException catch (err) {
      throw Exception('Gagal mendaftar: ${err.message}');
    } catch (err) {
      throw Exception('Terjadi kesalahan yang tidak terduga.');
    }
  }

  // Sign in function
  Future<void> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (err) {
      throw Exception('Gagal login: ${err.message}');
    } catch (err) {
      throw Exception('Terjadi kesalahan yang tidak terduga.');
    }
  }

  // Sign out function
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      _moods = [];
      notifyListeners();
    } catch (err) {
      throw Exception('Gagal logout.');
    }
  }

  // Read mood from supabase
  Future<void> fetchMoods() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in.');

      final data = await supabase
          .from('moods')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _moods = data.map((item) => Mood.fromJson(item)).toList();
      notifyListeners();
    } catch (err) {
      throw Exception('Gagal membuat data mood: ${err.toString()}');
    }
  }

  // Create mood
  Future<void> addMood({required String mood, required String note}) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in.');

      await supabase.from('moods').insert({
        'user_id': userId,
        'mood': mood,
        'note': note,
      });
      await fetchMoods();
    } catch (err) {
      throw Exception('Gagal menambah mood: ${err.toString()}');
    }
  }

  // Update mood
  Future<void> updateMood({
    required int id,
    required String mood,
    required String note,
  }) async {
    try {
      await supabase
          .from('moods')
          .update({'mood': mood, 'note': note})
          .eq('id', id);
      await fetchMoods();
    } catch (err) {
      throw Exception('Gagal update mood: ${err.toString()}');
    }
  }

  // Delete mood
  Future<void> deleteMood(int id) async {
    try {
      await supabase.from('moods').delete().eq('id', id);
      _moods.removeWhere((mood) => mood.id == id);
      notifyListeners();
    } catch (err) {
      await fetchMoods();
      throw Exception('Gagal menghapus mood: ${err.toString()}');
    }
  }
}
