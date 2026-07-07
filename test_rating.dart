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
    print("Testing insert into barber_reviews...");
    await client.from('barber_reviews').insert({
      'booking_id': '00000000-0000-0000-0000-000000000000',
      'barber_id': '00000000-0000-0000-0000-000000000000',
      'customer_id': '00000000-0000-0000-0000-000000000000',
      'rating': 5,
      'review_text': 'bagus',
    });
    print("Insert into barber_reviews successful (or at least table exists).");
  } catch (e) {
    print("Error on barber_reviews: $e");
  }

  try {
    print("Testing select from bookings is_rated...");
    await client.from('bookings').select('id, is_rated').limit(1);
    print("is_rated column exists in bookings.");
  } catch (e) {
    print("Error on bookings is_rated: $e");
  }

  try {
    print("Testing select from barbers rating, reviews_count...");
    await client.from('barbers').select('id, rating, reviews_count').limit(1);
    print("rating, reviews_count columns exist in barbers.");
  } catch (e) {
    print("Error on barbers rating/reviews_count: $e");
  }
}
