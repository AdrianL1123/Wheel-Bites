import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_spin_to_eat/data/model/user.dart';

class UserRepo {
  static final UserRepo _instance = UserRepo._init();

  UserRepo._init();
  factory UserRepo() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<AppUser> getUserDetails() async {
    final userId = supabase.auth.currentUser!.id;
    final resp =
        await supabase
            .from("users")
            .select('username, email')
            .eq("id", userId)
            .single();
    return AppUser.fromMap(resp);
  }
}
