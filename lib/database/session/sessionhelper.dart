import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';

import 'null_check_oprations.dart';
import 'sessionmanager.dart';

class SessionHelper {
  SessionHelper._();

  static final SessionHelper _instance = SessionHelper._();

  factory SessionHelper() {
    return _instance;
  }

  // Todo:Difficulty Level

  Future<void> setLoginData(LoginData loginResponce) async {
    await SessionManager.setStringValue(
        SpString.spLogin, jsonEncode(loginResponce.toJson()));
  }

  static LoginData? loginSavedData;

  Future<LoginData?> getLoginData() async {
    String response = await SessionManager.getStringValue(SpString.spLogin);
    if (CheckNullData.checkNullOrEmptyString(response)) {
      return null;
    } else {
      log(response);
      //String data = json.decode(response);
      return LoginData.fromJson(jsonDecode(response));
    }
  }
}
