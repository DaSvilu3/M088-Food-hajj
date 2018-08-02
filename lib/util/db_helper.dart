
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';

abstract class DBHelperBase {
  String convertMapToJSON(Map map);
  String generateKey(String base_key);
  String generateKeyForSaveList(String id );
  Future<int> saveJSON(String key, String json);
  Future<List<String>> getKeys (String base_key);
  Future<String> getJSONFromDB(String key);
  Map convertJsonToMap(String json);
  String randomString(int length);
  Future<int> delete_section(String base_key);

  void removeKey(String key);
}

class LocalDBHelper implements DBHelperBase {
  @override
  Map convertJsonToMap(String json)  {
    // TODO: implement convertJsonToMap
    try{
      Map map = jsonDecode(json);
      return map;
    }catch(e) {
      print(e.toString());
      try{
        List<Map> list = jsonDecode(json);
        return list[0];
      }catch(er) {
        print(er.toString());
      }

    }
  }



  @override
  String convertMapToJSON(Map map) {
    // TODO: implement convertMapToJSON
    print("json : " + jsonEncode(map));
    return jsonEncode(map);
  }

  @override
  String generateKey(String base_key) {
    // TODO: implement generateKey
    var uuid = new Uuid();
    String rand = uuid.v1();
    String final_key = base_key+"-"+rand+randomString(5);
    print("final key : " + final_key);
    return final_key;
  }

  @override
  String generateKeyForSaveList(String id) {
    // TODO: implement generateKeyForSaveList
    String key = "save-" +id;
    print("generated key =  " +key);
    return key;
  }

  @override
  Future<String> getJSONFromDB(String key) async  {
    // TODO: implement getJSONFromDB
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String string = await preferences.get(key);
    print("json from db : " + string);
    return string;
  }

  @override
  Future<List<String>> getKeys(String base_key) async {
    // TODO: implement getKeys
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Set<String> list = sharedPreferences.getKeys() ;
    print("list of keys from db : ");
    print(list);
    List<String> result = [];
    result.addAll(list);

    return result;
  }

  @override
  Future<int> saveJSON(String key, String json) async  {
    // TODO: implement saveJSON
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(key, json);

    print("done saving - key : " + key + " - value : " + json );
    getKeys("").then((list) {
      print("keys of list" + list.toString());
    });
    return 1;
  }

  @override
  String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(
        length,
            (index){
          return rand.nextInt(33)+89;
        }
    );

    return new String.fromCharCodes(codeUnits);
  }

  @override
  void removeKey(String key) async {
    // TODO: implement removeKey
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(key);

  }

  @override
  Future<int> delete_section(String base_key) async {
    // TODO: implement delete_section

    List<String> keys = await getKeys(base_key);

    for(String key in keys){
      if (key.startsWith(base_key)) {
        removeKey(key);
        print("key: " + key + " removed");
      }

    }
    return 0;
  }



}