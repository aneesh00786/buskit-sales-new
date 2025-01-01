import 'package:flutter/material.dart';

class PaginationModel {
  int currentPage = 1;
  int totalPage = 0;
  int limit = 10;
  int? totalItems;

  PaginationModel.mapJson(Map<String, dynamic> json) {
    totalItems = json['pagination']['total_record'];
    totalPage = json['pagination']['total_pages'];
    limit = json['pagination']['per_page'];
  }

  Map<String, dynamic> toMapData() {
    return {"page": currentPage, "limit": limit};
  }

  get nextPage => {
        if (currentPage < totalPage) {currentPage = currentPage + 1} else {}
      };

  PaginationModel(
      {this.currentPage = 1,
      this.totalPage = 0,
      this.limit = 100,
      this.totalItems});

  static bool onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final before = notification.metrics.extentBefore;
      final max = notification.metrics.maxScrollExtent;

      if (before == max) {
        return true;
      }
    }
    return false;
  }
}
