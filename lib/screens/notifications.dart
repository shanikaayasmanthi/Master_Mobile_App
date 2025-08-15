import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("All Notification"),
        automaticallyImplyLeading: true,
      ),
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: (){
                  print("Cleared all notifications");
                },
                child: Text("Clear All",style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                ),),
              )
            ],
          )
        ],
      ),),
    );
  }
}
