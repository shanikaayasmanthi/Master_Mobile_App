import 'package:flutter/material.dart';

class DateCard extends StatefulWidget {
  const DateCard({super.key, required this.date, required this.day, required this.bgColor, required this.dateColor});

  final String date;
  final String day;
  final Color bgColor;
  final Color dateColor;
  @override
  State<DateCard> createState() => _DateCardState();
}

class _DateCardState extends State<DateCard> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 90,
      width: 80,
      child: Container(
        // margin: EdgeInsets.all(0),
        // padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.date,
                style: TextStyle(
                  color: widget.dateColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.day,
                style: TextStyle(
                  color: colorScheme.onTertiary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
