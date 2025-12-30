import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String title;
  final String sn;
  final String status;
  final String version;
  final IconData icon;
  final Color statusColor;
  final Color background;
  final Color borderColor;
  final Color primaryText;
  final bool expanded;
  final String? location;
  final VoidCallback? onTap;

  const DeviceCard({
    super.key,
    required this.title,
    required this.sn,
    required this.status,
    required this.version,
    required this.icon,
    required this.statusColor,
    required this.background,
    required this.borderColor,
    required this.primaryText,
    this.expanded = false,
    this.location,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'S/N: $sn',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryText.withOpacity(0.65),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            version,
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryText.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: primaryText.withOpacity(0.6)),
              ],
            ),
            if (expanded && (location != null && location!.isNotEmpty)) ...[
              const SizedBox(height: 12),
              Text(
                'Ubicación: $location',
                style: TextStyle(
                  fontSize: 12,
                  color: primaryText.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
