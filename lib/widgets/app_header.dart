import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          radius: 20,
          child: Icon(Icons.person),
        ),
        SizedBox(width: 10),
        Image.asset("assets/logo.png", height: 45), // your gov logo
        Spacer(),
        Icon(Icons.notifications_none, size: 28),
        SizedBox(width: 10),
      ],
    );
  }
}
