import 'package:flutter/material.dart';

class AttendanceDataCard extends StatefulWidget {
  const AttendanceDataCard({super.key,
    required this.title,
    required this.icon,
    required this.time,
    required this.description,
    this.subDescription,
    this.descriptionColor,
    this.subDescriptionColor,
  });

  final String title;
  final IconData icon;
  final dynamic time;
  final String description;
  final String? subDescription;
  final Color? descriptionColor;
  final Color? subDescriptionColor;

  @override
  State<AttendanceDataCard> createState() => _AttendanceDataCardState();
}

class _AttendanceDataCardState extends State<AttendanceDataCard> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: MediaQuery.of(context).size.width*0.40,
      width: MediaQuery.of(context).size.width*0.43,
      child:
      DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.035,vertical: MediaQuery.of(context).size.width*0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFFEFE0FF),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "${widget.time}",
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              widget.subDescription != null?Text(
                "${widget.subDescription}",
                style: TextStyle(color: widget.subDescriptionColor!=null?widget.subDescriptionColor:colorScheme.onTertiary, fontSize: 16),
              ):SizedBox.shrink(),
              SizedBox(height: 4,),
              Text(
                widget.description,
                style: TextStyle(color: widget.descriptionColor!=null?widget.descriptionColor:colorScheme.onTertiary, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
