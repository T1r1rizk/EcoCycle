import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class PointsDisplay extends StatelessWidget {
  final int points;

  const PointsDisplay({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Adjust the width as needed
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.pointsGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your Points', style: AppStyles.heading2),
          const SizedBox(height: 8), // Adds spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the score
            children: [
              Text(
                points.toString(),
                style: AppStyles.heading1.copyWith(
                  color: const Color.fromARGB(255, 46, 134, 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
