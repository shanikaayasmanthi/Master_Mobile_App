import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/screens/notifications.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  const UserCard({super.key,
  required this.user});

  final UserModel user;
  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 15,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    child: CircleAvatar(
                      radius: 90.0,
                      backgroundImage: AssetImage('lib/images/profile.jpg'),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.name, style:TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      )),
                      Text(widget.user.company,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 20, // Or use a themed text style like Theme.of(context).textTheme.titleLarge
                            fontWeight: FontWeight.bold,
                          ),),
                      Text(widget.user.designation,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontSize: 20, // Or use a themed text style like Theme.of(context).textTheme.titleLarge
                          fontWeight: FontWeight.w500,
                        ),),

                    ],
                  ),
                ],
              )
            ],
          ),
          Column(
            children: [
              // FloatingActionButton(onPressed: (){},child: Icon(Icons.notifications_active_sharp),),
              IconButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const Notifications()));
              }, icon: Icon(Icons.notifications_active_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shadowColor: Theme.of(context).colorScheme.secondary
                // foregroundColor: Theme.of(context).colorScheme.secondary
              ),)
            ],
          )
        ],
      ),
    );
  }
}
