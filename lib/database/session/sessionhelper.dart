import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:flutter/material.dart';

import 'null_check_oprations.dart';
import 'sessionmanager.dart';

class SessionHelper {
  SessionHelper._();

  static final SessionHelper _instance = SessionHelper._();

  factory SessionHelper() {
    return _instance;
  }

  static final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

  Future<void> setLoginData(LoginData loginResponse) async {
    await SessionManager.setStringValue(
        SpString.spLogin, jsonEncode(loginResponse.toJson()));
    loginSavedData = loginResponse;
    isLoggedIn.value = true;
  }

  static LoginData? loginSavedData;

  Future<LoginData?> getLoginData() async {
    String response = await SessionManager.getStringValue(SpString.spLogin);
    if (CheckNullData.checkNullOrEmptyString(response)) {
      loginSavedData = null;
      isLoggedIn.value = false; 
      return null;
    } else {
      loginSavedData = LoginData.fromJson(jsonDecode(response));
      isLoggedIn.value = true; 
      return loginSavedData;
    }
  }

  Future<void> clearAll() async {
    await SessionManager.clearData();
    loginSavedData = null;
    loginSavedData?.salesmanId==null;
    isLoggedIn.value = false;
  }
}
