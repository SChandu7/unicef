import 'package:flutter/material.dart';

class CategoriesGrid extends StatelessWidget {
  final items = [
    {"icon": Icons.people, "label": "Citizens"},
    {"icon": Icons.school, "label": "Students"},
    {"icon": Icons.agriculture, "label": "Farmers"},
    {"icon": Icons.health_and_safety, "label": "Health"},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      children: items
          .map(
            (item) => Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Icon(item['icon'] as IconData?, size: 30),
                ),
                SizedBox(height: 4),
                Text(item['label'] as String, style: TextStyle(fontSize: 12)),
              ],
            ),
          )
          .toList(),
    );
  }
}
