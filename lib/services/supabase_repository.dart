import 'dart:typed_data';

import 'package:supabase_connect/supabase_connect.dart';

import '../supabase_config.dart';

class SupabaseRepository {
  SupabaseRepository._({SupabaseConnect? client})
      : _client = client ?? _createClient();

  final SupabaseConnect _client;

  static SupabaseRepository? _instance;

  static SupabaseRepository get instance {
    return _instance ??= SupabaseRepository._();
  }

  static SupabaseConnect _createClient() {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase credentials were not provided. Use --dart-define to set '
        'SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return SupabaseConnect(
      supabaseUrl: SupabaseConfig.supabaseUrl,
      supabaseKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCompetencias() {
    return _client.select('competencias');
  }

  Future<List<Map<String, dynamic>>> fetchHabilidades() {
    return _client.select('habilidades');
  }

  Future<List<Map<String, dynamic>>> fetchItens() {
    return _client.select('db');
  }

  Future<Uint8List> downloadProva(int idProva) {
    return _client.download('provas', '$idProva.pdf');
  }
}
