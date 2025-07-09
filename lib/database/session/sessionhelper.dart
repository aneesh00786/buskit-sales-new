import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
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
  static LoginData? loginSavedData;
  static List<AllCompanySettingsData>? settingsData;

  static LoginData? backupLoginData; // Alternate for loginSavedData

  // Create backup of current login data
  void createLoginDataBackup() {
    if (loginSavedData != null) {
      backupLoginData = loginSavedData;
      log('Login data backup created: ${backupLoginData!.company_id}');
    }
  }

  // Get backup login data
  LoginData? getBackupLoginData() {
    return backupLoginData;
  }

  // Clear backup login data
  void clearBackupLoginData() {
    backupLoginData = null;
    log('Backup login data cleared.');
  }

  // Clear original login data but keep backup
  Future<void> clearLoginDataKeepBackup() async {
    await SessionManager.clearData();
    loginSavedData = null;
    log('Original login data cleared, backup preserved.');
  }

  Future<void> setLoginData(LoginData loginResponse) async {
    await SessionManager.setStringValue(
        SpString.spLogin, jsonEncode(loginResponse.toJson()));
    loginSavedData = loginResponse;
    isLoggedIn.value = true;
  }
  Future<void> setSettingsData(
      List<AllCompanySettingsData> settingsList) async {
    List<Map<String, dynamic>> jsonList =
        settingsList.map((e) => e.toJson()).toList();
    await SessionManager.setStringValue(
      SpString.settingsKey,
      jsonEncode(jsonList),
    );
    settingsData = settingsList;
  }

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

  Future<List<AllCompanySettingsData>?> getSettingsData() async {
    String response = await SessionManager.getStringValue(SpString.settingsKey);
    if (CheckNullData.checkNullOrEmptyString(response)) {
      log('No settings data found in storage.');
      return null;
    } else {
      try {
        List<dynamic> jsonList = jsonDecode(response);
        List<AllCompanySettingsData> settingsList = jsonList
            .map((item) => AllCompanySettingsData.fromJson(item))
            .toList();
        log('Fetched settings data: $settingsList');
        return settingsList;
      } catch (e) {
        log('Error decoding settings data: $e');
        return null;
      }
    }
  }

  Future<void> clearAll() async {
    await SessionManager.clearData();
    loginSavedData = null;
    settingsData = null;
    isLoggedIn.value = false;
    log('All session data cleared.');
  }
  Future<void> clearSettingsData() async {
    await SessionManager.deleteData(SpString.settingsKey);
    settingsData = null;
    log('Settings data cleared.');
  }
}
