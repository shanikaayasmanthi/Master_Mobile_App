class LeaveModel{
  String?leaveId;
  String? name;
  DateTime fromDate;
  DateTime toDate;
  String leaveType;
  String? considerBy;
  String? status;
  String? requestedFrom;
  String? reason;

  LeaveModel({
    this.leaveId,
    this.name,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    this.considerBy,
    this.requestedFrom,
    this.status,
    this.reason

});
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      leaveId: json['leave_id'] as String?,
      name: json['name'] as String?,
      fromDate: DateTime.parse(json['from_date'] as String),
      toDate: DateTime.parse(json['to_date'] as String),
      leaveType: json['leave_type_name'] as String,
      considerBy: json['consider_by'] as String?,
      status: json['status'] as String?,
      requestedFrom: json['requested_from'] as String?,
      reason: json['reason'] as String?,
    );
  }
}