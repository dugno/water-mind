import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_mind/src/common/constant/strings/shared_preferences.dart';

part 'kv_store.g.dart';

@riverpod
Future<void> kvStoreService(KvStoreServiceRef ref) async {
  return await KVStoreService.init();
}


 class KVStoreService {
  static SharedPreferences? _sharedPreferences;
  static SharedPreferences get sharedPreferences => _sharedPreferences!;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static bool get doneGettingStarted =>
      sharedPreferences.getBool(SharedPreferencesConst.doneGettingStarted) ?? false;
  static Future<void> setDoneGettingStarted(bool value) async =>
      await sharedPreferences.setBool(SharedPreferencesConst.doneGettingStarted, value);


  
}