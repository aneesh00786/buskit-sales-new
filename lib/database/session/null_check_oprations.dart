class CheckNullData {
  static bool checkNullOrEmptyString(String str) {
    if (str.isEmpty || str == "") {
      return true;
    } else {
      return false;
    }
  }

  static bool checkLocalOrServerImage(String str) {
    if (str.contains("https://")) {
      return true;
    } else {
      return false;
    }
  }
}
