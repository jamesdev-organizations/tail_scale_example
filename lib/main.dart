import 'package:flutter/material.dart';
import 'package:tail_scale_example/screens/docker_run_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailscale Installer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DockerRunScreen(),
    );
  }
}
