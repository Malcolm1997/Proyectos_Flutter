import 'package:flutter/material.dart';

abstract class AppColors {
  // --- Estados Principales ---
  static const Color statusSuccess = Color(0xFF2E7D32); // Verde fuerte
  static const Color statusWarning = Color(0xFFED6C02); // Naranja alerta
  static const Color statusError   = Color(0xFFD32F2F); // Rojo material
  
  // --- Estados de Máquina ---
  static const Color statusMaintenance = Color(0xFF9C27B0); // Púrpura (Distinto a alertas)
  static const Color statusIdle        = Color(0xFF607D8B); // Azul Gris (Neutro)
  
  // --- Conectividad (IoT) ---
  static const Color connectionLost    = Color(0xFFB0BEC5); // Gris pálido
  static const Color connectionActive  = Color(0xFF0288D1); // Azul Wi-Fi
  
  // --- Texto sobre colores (Contraste) ---
  // Úsalos cuando pongas texto ENCIMA de los colores anteriores
  static const Color onStatus = Colors.white; 
}