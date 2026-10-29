import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final List<Color> gradientColors;

  const NeonCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.6),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(icon, color: Colors.white),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: amount < 0 ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
