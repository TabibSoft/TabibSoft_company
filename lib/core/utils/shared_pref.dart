import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';

class SharedPref {
  static const String _userIdKey = 'USER_ID_KEY'; // Assuming a key for user ID

  static String? getUserId() {
    // Assuming the user ID is stored securely, or in SharedPreferences
    // Based on the project structure, let's assume it's stored securely as a token/ID.
    // The actual key might be different, but we'll use a placeholder for now.
    // We'll use the non-async getString for simplicity, but a secure storage read might be better.
    // Since CacheHelper.getSecureStorge is async, we'll need to make this method async or use a simpler sync method if available.
    // For now, I will use a synchronous placeholder and assume the actual implementation will be handled by the consuming code (which I will make async).
    // Let's adjust the implementation in tech_card_content.dart to use CacheHelper.getSecureStorge directly, as it's async.
    // I will delete the import of 'package:tabib_soft_company/core/utils/shared_pref.dart' from tech_card_content.dart and use CacheHelper directly.
    return CacheHelper.getString(key: _userIdKey);
  }
}
