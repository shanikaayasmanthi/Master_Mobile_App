import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ApplyLeave extends StatefulWidget {
   ApplyLeave({super.key, this.leave});

  final LeaveModel? leave;

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  final RxString leaveType = 'Leave Type'.obs;
  final RxString requestFrom = 'Select Approver'.obs;
  TextEditingController reason = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late String title;

  final List<String> leaveTypes = [
    'Leave Type',
    'Medical Leave',
    'Annual Leave',
    'Casual Leave',
  ];

  final List<String> approvers = [
    'Select Approver',
    'Rajitha Mihiranga',
    'Nuwan Prasanna',
    'Ishan Kumara',
    'Supun Wijesiri',
  ];

  DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy.MM.dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  void applyLeave() {
    if (formKey.currentState!.validate()) {
      print('applied!');
    }
  }

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(
        DateTime.now().year + 5,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy.MM.dd').format(picked);
      controller.text = formattedDate;
    }
  }

  void loadLeaveToEdit() {
    if (widget.leave != null) {
      final formattedFromDate = DateFormat(
        'yyyy.MM.dd',
      ).format(widget.leave!.fromDate);
      final formattedToDate = DateFormat(
        'yyyy.MM.dd',
      ).format(widget.leave!.toDate);

      fromDateController.text = formattedFromDate;
      toDateController.text = formattedToDate;
      leaveType.value = widget.leave!.leaveType;
      requestFrom.value = widget.leave!.requestedFrom!;
      reason.text = widget.leave!.reason??'';
      title = "Edit Leave";
    }else{
      title = "Apply Leave";
    }
  }

  @override
  void initState() {
    super.initState();
    loadLeaveToEdit();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              //from date
              Text(
                "From Date",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: fromDateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Start Date",
                      suffixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                    validator: (value) {
                      if (value == '') {
                        return 'Required*';
                      } else {
                        if (toDateController.text != '') {
                          final from = parseDate(value.toString());
                          final to = parseDate(toDateController.text);

                          if (to!.isBefore(from!)) {
                            return 'End date cannot be before start date';
                          }
                        }
                      }
                    },
                  ),
                ),
                onTap: () {
                  selectDate(context, fromDateController);
                },
              ),
              SizedBox(height: 20),
              //to Date
              Text(
                "To Date",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: toDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: "Start Date",
                      suffixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                    validator: (value) {
                      if (value == '') {
                        return 'Required*';
                      } else {
                        if (fromDateController.text != '') {
                          final from = parseDate(fromDateController.text);
                          final to = parseDate(value.toString());
                          if (from!.isAfter(to!)) {
                            return "Start Date cannot be after End Date";
                          }
                        }
                      }
                    },
                  ),
                ),
                onTap: () {
                  selectDate(context, toDateController);
                },
              ),
              SizedBox(height: 20),
              //leave type
              Text(
                "To Date",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: leaveType.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: leaveTypes.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == 'Leave Type') {
                      return "Select the leave type";
                    }
                  },
                  onChanged: (value) {
                    leaveType.value = value.toString();
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Request From",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  value: requestFrom.value,
                  items: approvers.map((String approver) {
                    return DropdownMenuItem(
                      value: approver,
                      child: Text(approver),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == 'Select Approver') {
                      return 'Select your supervisor to approve';
                    }
                  },
                  onChanged: (value) {
                    requestFrom.value = value.toString();
                  },
                ),
              ),
              SizedBox(height: 20),
              //reason
              Text(
                "Reason",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                controller: reason,
                maxLines: 2,
                decoration: InputDecoration(hintText: 'reason'),
              ),
              SizedBox(height: 25),
              widget.leave != null
                  ? Row(
                spacing: 20,
                children: [
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onTertiary,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: (){},
                    child: Text(
                      "Remove Leave",
                      style: TextStyle(
                        color: colorScheme.tertiary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )),
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: applyLeave,
                    child: Text(
                      "Save Changes",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ))
                ],
              )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: applyLeave,
                      child: Text(
                        "Apply Leave",
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
