import 'package:flutter/material.dart';

class TeamLeaves extends StatefulWidget {
  const TeamLeaves({super.key});

  @override
  State<TeamLeaves> createState() => _TeamLeavesState();
}

class _TeamLeavesState extends State<TeamLeaves> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("Today Leave List"),
      ),
    );
  }
}
