import 'package:flutter/material.dart';
import 'package:mobile_app/core/text_styles.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio', style: TextStyles.title)),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 5.0,
                    bottom: 5.0,
                    top: 20.0,
                  ),

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            "2",
                            style: TextStyles.textBoldTitle,
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            'Dispositivos Conectados',
                            style: TextStyles.text,
                            textAlign: TextAlign.start,
                          ),
                          // Aquí iría la lista de dispositivos conectados
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    right: 10.0,
                    bottom: 5.0,
                    top: 20.0,
                  ),

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            "2",
                            style: TextStyles.textBoldTitle,
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            'Dispositivos en Linea',
                            style: TextStyles.text,
                            textAlign: TextAlign.left,
                          ),
                          // Aquí iría la lista de dispositivos conectados
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
