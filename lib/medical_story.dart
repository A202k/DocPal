import 'package:flutter/material.dart';

class MedicalHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سيرة مرضية',
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
          'لا توجد بيانات حالياً. اضغط على الزر لإضافة مريض جديد.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addPatient');
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF3c8ce7),
      ),
    );
  }
}
