import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselBanner extends StatelessWidget {
  final images = ["assets/banner1.jpg", "assets/banner2.jpg"];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: images
          .map(
            (img) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          )
          .toList(),
      options: CarouselOptions(
        autoPlay: true,
        height: 180,
        enlargeCenterPage: true,
      ),
    );
  }
}
