import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String? url;
  String? key;
  for (var line in lines) {
    if (line.startsWith('SUPABASE_URL=')) {
      url = line.split('=')[1];
    } else if (line.startsWith('SUPABASE_ANON_KEY=')) {
      key = line.split('=')[1];
    }
  }

  if (url == null || key == null) {
    print("Could not find Supabase credentials");
    return;
  }

  final client = SupabaseClient(url, key);
  
  try {
    print("Checking services table...");
    final response = await client.from('services').select('id, name, image_url').eq('name', 'wolfcut');
    print("Result for wolfcut: $response");
  } catch (e) {
    print("Error querying services: $e");
  }
}
