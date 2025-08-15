import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:av_master_mobile/screens/attendance/apply_leave.dart';
import 'package:flutter/material.dart';

class LeaveDetailCard extends StatefulWidget {
  const LeaveDetailCard({
    super.key,
    required this.leave
  });

  final LeaveModel leave;

  @override
  State<LeaveDetailCard> createState() => _LeaveDetailCardState();
}

class _LeaveDetailCardState extends State<LeaveDetailCard> {
  
  String formatDate(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  int getNumberOfDays(DateTime fromDate, DateTime toDate){
    return toDate.difference(fromDate).inDays +1;
  }
  
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(
                            color: colorScheme.onTertiary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${formatDate(widget.leave.fromDate)} -  ${formatDate(widget.leave.toDate)}",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        widget.leave.status=="pending"?IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ApplyLeave(leave: widget.leave,)));
                          },
                          icon: Icon(Icons.edit, color: colorScheme.primary),
                          color: colorScheme.primary.withOpacity(0.4),
                        ):SizedBox.shrink(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            widget.leave.status=="pending"?Icons.error_outline:widget.leave.status=="approved"?Icons.check_circle_outline:Icons.do_disturb_rounded,
                            color:widget.leave.status=="pending"?Color(0xFF01601E):widget.leave.status=="approved"?Color(0xFF00C63B):Color(0xFFF90004) ,
                          ),
                          color: Color(0xFF01601E).withOpacity(0.4),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(height: 8, color: colorScheme.onTertiary),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Apply Days",
                            style: TextStyle(
                              color: colorScheme.onTertiary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Reason",
                            style: TextStyle(
                              color: colorScheme.onTertiary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Consider By",
                            style: TextStyle(
                              color: colorScheme.onTertiary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${getNumberOfDays(widget.leave.fromDate, widget.leave.toDate)}",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${widget.leave.leaveType}",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${widget.leave.considerBy}",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
