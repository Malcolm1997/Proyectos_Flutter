import 'package:flutter/material.dart';
import '../core/app_colors.dart';

import '../models/device.dart';

Future<void> showDeviceModal(BuildContext context, Device device, {required void Function(double intensity, double temperature, double duration) onStart}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      double intensity = 50;
      double temperature = 38;
      double duration = 30;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: StatefulBuilder(builder: (ctx, setState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      const SizedBox(width: 44),
                      Expanded(
                        child: Center(
                          child: Text(
                            device.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: Icon(Icons.close, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.wifi, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(device.ip ?? '', style: const TextStyle(color: Colors.black87))),
                      Text(device.version, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Intensidad
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: const [Icon(Icons.bolt, size: 18, color: Colors.black54), SizedBox(width: 8), Text('Intensidad', style: TextStyle(color: Colors.black87))]),
                    Text('${intensity.round()}%', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    thumbColor: Colors.lightBlue,
                    activeTrackColor: Colors.lightBlue,
                    inactiveTrackColor: Colors.black12,
                    overlayColor: Colors.lightBlue.withOpacity(0.18),
                  ),
                  child: Slider(value: intensity, min: 0, max: 100, divisions: 100, onChanged: (v) => setState(() => intensity = v)),
                ),
                const SizedBox(height: 8),

                // Temperatura
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: const [Icon(Icons.thermostat, size: 18, color: Colors.black54), SizedBox(width: 8), Text('Temperatura', style: TextStyle(color: Colors.black87))]),
                    Text('${temperature.round()}°C', style: TextStyle(color: Colors.deepOrange.shade700, fontWeight: FontWeight.w700)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    thumbColor: Colors.deepOrange,
                    activeTrackColor: Colors.deepOrange,
                    inactiveTrackColor: Colors.black12,
                    overlayColor: Colors.deepOrange.withOpacity(0.18),
                  ),
                  child: Slider(value: temperature, min: 20, max: 45, divisions: 25, onChanged: (v) => setState(() => temperature = v)),
                ),
                const SizedBox(height: 8),

                // Duración
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: const [Icon(Icons.timer, size: 18, color: Colors.black54), SizedBox(width: 8), Text('Duración', style: TextStyle(color: Colors.black87))]),
                    Text('${duration.round()} min', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    thumbColor: AppColors.accent,
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: Colors.black12,
                    overlayColor: AppColors.accent.withOpacity(0.18),
                  ),
                  child: Slider(value: duration, min: 0, max: 120, divisions: 24, onChanged: (v) => setState(() => duration = v)),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.black12),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          onStart(intensity, temperature, duration);
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      );
    },
  );
}
