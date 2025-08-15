import 'package:av_master_mobile/screens/attendance/executive/exe_layout.dart';
import 'package:av_master_mobile/screens/attendance/technician/tech_layout.dart';
import 'package:flutter/material.dart';

class PortalCard extends StatefulWidget {
  const PortalCard({
    super.key,
    required this.portalName,
    required this.image,
    required this.navigate
  });

  final String portalName;
  final String image;
  final String navigate;
  @override
  State<PortalCard> createState() => _PortalCardState();
}


class _PortalCardState extends State<PortalCard> {

  final user = {
    'name':"Shanika Ayasmanthi",
    'userType':"executive"
  };

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
        child: Column(
          children: [
            InkWell(
              onTap: (){
                print("tapped");
                if(user['userType']=='technician'){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TechLayout(portalName: widget.portalName,)));
                } else if(user['userType']=='executive'){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ExeLayout(portalName: widget.portalName,)));
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width*0.15,
                height: MediaQuery.of(context).size.width*0.15,
                decoration: BoxDecoration(
                    color:Color(0xE4EFE0FF),
                    borderRadius: BorderRadius.circular(5.0)
                ),
                child: Image.asset(widget.image,),
              ),
            ),
            Text(widget.portalName,
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15
              ),)
          ],
        ),
    );
  }
}
