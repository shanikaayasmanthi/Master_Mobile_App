import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:flutter/material.dart';

class LeaveRequestCard extends StatefulWidget {
  const LeaveRequestCard({super.key,required this.leaveRequest});

  final LeaveModel leaveRequest;
  @override
  State<LeaveRequestCard> createState() => _LeaveRequestCardState();
}

class _LeaveRequestCardState extends State<LeaveRequestCard> {

  String formatDate(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        DecoratedBox(decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 15,
                children: [
                  Text(widget.leaveRequest.name!,style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontSize: 16,)),
                  VerticalDivider(width: 8,color: colorScheme.onTertiary,),
                  Text(widget.leaveRequest.leaveType,style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontSize: 16,))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${formatDate(widget.leaveRequest.fromDate)} - ${formatDate(widget.leaveRequest.toDate)}",style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 17,
                  ),),
                ],
              ),
              Divider(height: 8,color: colorScheme.onTertiary,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: (){}, child: Text("Reject",style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),),style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),),
                  ElevatedButton(onPressed: (){}, child: Text("Accept",style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),),style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),)
                ],
              )
            ],
          ),),
        )
      ],
    );
  }
}
