class LeaveModel{
  String? name;
  DateTime fromDate;
  DateTime toDate;
  String leaveType;
  String? considerBy;
  String? status;
  String? requestedFrom;
  String? reason;

  LeaveModel({
    this.name,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    this.considerBy,
    this.requestedFrom,
    this.status,
    this.reason

});
}