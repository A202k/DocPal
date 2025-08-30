import 'package:flutter/material.dart';

class PatientInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات المريض',
            style: TextStyle(fontSize: 22, color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00EAFF), Color(0xFF3c8ce7)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'محتوى معلومات المريض هنا',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
