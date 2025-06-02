import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import "package:http/http.dart" as http;

class StorageService {
  static final _instance = StorageService._init();
  StorageService._init();

  factory StorageService() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<void> uploadImage(String name, Uint8List bytes) async {
    await supabase.storage
        .from("images")
        .uploadBinary(name, bytes, fileOptions: FileOptions(upsert: true));
  }

  Future<Uint8List?> getImage(String name) async {
    final url = supabase.storage.from("images").getPublicUrl(name);
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      return null;
    }
    return resp.bodyBytes;
  }
}
