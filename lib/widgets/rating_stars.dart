import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final int maxStars;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 18,
    this.color = Colors.amber,
    this.maxStars = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        // Full star
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: color);
        }
        // Half star
        else if (index == rating.floor() && rating - rating.floor() >= 0.5) {
          return Icon(Icons.star_half, size: size, color: color);
        }
        // Empty star
        else {
          return Icon(Icons.star_outline, size: size, color: color);
        }
      }),
    );
  }
}
