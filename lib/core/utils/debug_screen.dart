import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/alarm/alarm_service.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛠 Debug Tool")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            title: const Text("Test Alarm Instan"),
            subtitle: const Text("Alarm bunyi sekarang juga"),
            leading: const Icon(Icons.notifications_active),
            onTap: () async {
              // Kirim alarm ID 999 untuk tes
              await AlarmService.scheduleAlarm(DateTime.now().add(const Duration(seconds: 5)), 999);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alarm bunyi dalam 5 detik")));
            },
          ),
          const Divider(),
          const ListTile(
            title: Text("Info"),
            subtitle: Text("Gunakan layar ini untuk memanipulasi state tanpa nunggu waktu nyata."),
          ),
        ],
      ),
    );
  }
}