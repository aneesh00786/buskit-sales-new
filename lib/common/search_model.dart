class SearchModel {
  String? searchText;
  String? startDate;
  String? endDate;

  SearchModel({
    this.searchText,
    this.startDate,
    this.endDate,
  });

  SearchModel.fromJson(Map<String, dynamic> json) {
    searchText = json['search_text'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['search_text'] = searchText ?? '';
    data['start_date'] = startDate ?? '';
    data['end_date'] = endDate ?? '';
    return data;
  }
}

/*class SearchModel {
  String searchText;
  String startDate;
  String endDate;

  SearchModel({
    this.searchText,
    this.startDate,
    this.endDate,
  });

  SearchModel.fromJson(Map<String, dynamic> json) {
    searchText = json['search_text'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['search_text'] = searchText.toString();
    data['start_date'] = startDate.toString();
    data['end_date'] = endDate.toString();
    return data;
  }
}*/
