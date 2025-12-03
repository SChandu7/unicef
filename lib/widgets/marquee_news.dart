import 'package:flutter/material.dart';

class NewsMarquee extends StatefulWidget {
  final String text;
  final double speed;

  const NewsMarquee({
    Key? key,
    required this.text,
    this.speed = 40, // higher value => faster scrolling
  }) : super(key: key);

  @override
  _NewsMarqueeState createState() => _NewsMarqueeState();
}

class _NewsMarqueeState extends State<NewsMarquee>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  late double textWidth;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => startScrolling());
  }

  Future<void> startScrolling() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 1000));

      if (!isHovered) {
        await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(seconds: widget.speed.toInt()),
          curve: Curves.linear,
        );
        await Future.delayed(Duration(milliseconds: 500));
        scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        height: 35,
        margin: EdgeInsets.symmetric(horizontal: 12),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xFFDFF0FF), // soft government blue bg
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.campaign, color: Colors.blue.shade800, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  SizedBox(width: 50), // gap to make loop smooth
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
