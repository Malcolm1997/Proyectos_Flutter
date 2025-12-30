import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String value;
  final String label;
  final Color background;
  final Color borderColor;
  final Color valueColor;

  const InfoCard({
    super.key,
    required this.value,
    required this.label,
    required this.background,
    required this.borderColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
