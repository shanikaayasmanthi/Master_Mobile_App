import 'package:flutter/material.dart';

class LeaveCard extends StatefulWidget {
  const LeaveCard({super.key,required this.leaveType,required this.leaveCount,required this.color});

  final String leaveType;
  final int leaveCount;
  final Color color;
  @override
  State<LeaveCard> createState() => _LeaveCardState();
}

class _LeaveCardState extends State<LeaveCard> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: MediaQuery.of(context).size.width*0.28,
      width: MediaQuery.of(context).size.width*0.4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: widget.color.withOpacity(0.5),
            width: 2.0
          )
        ),
        child: Padding(padding: EdgeInsets.symmetric(vertical: 0,horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 7,
          children: [
            Text("${widget.leaveType}",style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 23
            ),),
            Text("${widget.leaveCount}",style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.w800,
              fontSize: 24
            ),)
          ],
        ),),),
    );
  }
}
