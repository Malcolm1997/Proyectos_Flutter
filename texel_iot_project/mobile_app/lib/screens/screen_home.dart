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
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Column(
          children: [
            Row(
              children: [
                panel(
                  "2",
                  Icons.published_with_changes_outlined,
                  "Dispositivos Activos",
                  Colors.green,
                ),
                panel(
                  "2",
                  Icons.event_note_outlined,
                  "Proximas Sesiones",
                  Color(0xffF59E0B),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                bottom: 10.0,
                top: 20.0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.monitor_heart_outlined),
                      Text("Dispositivos Activos", style: TextStyles.textBold),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.book_online),
                                      Text("Preso"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.wifi),
                                      Text("Online"),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("Ver"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded panel(String number, IconData icon, String title, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          bottom: 10.0,
          top: 20.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    SizedBox(width: 10),
                    Text(number, style: TextStyles.textBoldTitle),
                  ],
                ),
                SizedBox(height: 10),
                Row(children: [Text(title, style: TextStyles.text)]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
