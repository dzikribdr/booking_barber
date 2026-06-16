import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/style_vault_model.dart';

class StyleVaultProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  List<StyleVaultModel> _styles = [];
  bool _isLoading = false;
  String? _error;

  List<StyleVaultModel> get styles => _styles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStyles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final response = await _supabaseClient
          .from('style_vault')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _styles = (response as List).map((e) => StyleVaultModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadStyleImage(String notes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      
      if (image == null) {
        _isLoading = false;
        notifyListeners();
        return false; // User canceled
      }

      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      // Ensure you have created a bucket named 'style_vault' in Supabase Storage
      await _supabaseClient.storage.from('style_vault').uploadBinary(filePath, bytes);
      
      final imageUrl = _supabaseClient.storage.from('style_vault').getPublicUrl(filePath);

      final insertData = {
        'user_id': user.id,
        'image_url': imageUrl,
        'notes': notes,
      };

      await _supabaseClient.from('style_vault').insert(insertData);
      
      // Refresh list
      await fetchStyles();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteStyle(String id) async {
    try {
      // Opt: also delete from storage if you want, using file path extracted from URL
      await _supabaseClient.from('style_vault').delete().eq('id', id);
      _styles.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
