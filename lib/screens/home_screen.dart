import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/marquee_news.dart';
import '../widgets/carousel_banner.dart';
import '../widgets/horizontal_scheme_cards.dart';
import '../widgets/stats_row.dart';
import '../widgets/categories_grid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final navItems = const [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.list_alt_outlined, 'label': 'Schemes'},
    {'icon': Icons.notifications_outlined, 'label': 'Updates'},
    {'icon': Icons.person_outline, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item['icon'] as IconData),
                label: item['label'] as String,
              ),
            )
            .toList(),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(),
              SizedBox(height: 10),
              CustomSearchField(),
              SizedBox(height: 10),
              NewsMarquee(
                text:
                    "Latest Gov Announcements | New Schemes Launched | Apply Before Deadline",
              ),
              SizedBox(height: 10),
              CarouselBanner(),
              SizedBox(height: 15),
              HorizontalSchemeCards(),
              SizedBox(height: 20),
              StatsRow(),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Explore Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              CategoriesGrid(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
