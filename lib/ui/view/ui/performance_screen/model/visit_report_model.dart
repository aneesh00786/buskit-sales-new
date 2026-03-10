class VisitReportModel {
  DateTime? date;
  int visited, missed, total;
  final String eventIds;
  final String missedEventIds;
  final String totalEventIds;
  VisitReportModel({
    this.date, 
    this.visited = 0, 
    this.missed = 0, 
    this.total = 0,
    required this.eventIds,
    required this.missedEventIds,
    required this.totalEventIds,
  });

  factory VisitReportModel.fromJson(Map<String, dynamic> json) {
    // 1. Get the 'counts' object safely
    var counts = json['counts'] ?? {};

    return VisitReportModel(
      date: json["start"] != null ? DateTime.tryParse(json["start"]) : null,
      visited: counts["visited"] ?? 0,
      missed: counts["missed"] ?? 0,
      total: counts["total_visit"] ?? 0,
      eventIds: counts['visited_event_ids'] ?? '', 
      missedEventIds: counts['missed_event_ids'] ?? '',
      totalEventIds: counts['total_visited_event_id'] ?? '',
    );
  }
}