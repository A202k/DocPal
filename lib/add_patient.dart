import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPatientScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _mainComplaintController = TextEditingController();
  final _durationController = TextEditingController();
  final _spreadController = TextEditingController();
  final _inductionController = TextEditingController();
  final _reliefController = TextEditingController();
  final _timeDurationController = TextEditingController();
  final _friendlySymptomsController = TextEditingController();
  final _breathingDifficultyController = TextEditingController();
  final _heartEchoController = TextEditingController();
  final _heartCatheterizationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergicHistoryController = TextEditingController();
  final _medicalInteractionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مريض جديد',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('اسم المريض', _patientNameController),
              _buildTextField('عمر المريض', _patientAgeController),
              _buildTextField('الشكاية الرئيسة', _mainComplaintController),
              _buildTextField('مدة الاستمرار', _durationController),
              _buildTextField('الانتشار', _spreadController),
              _buildTextField('التحريض', _inductionController),
              _buildTextField('التخفيف', _reliefController),
              _buildTextField('مدة زمنية', _timeDurationController),
              _buildTextField('الأعراض الودية', _friendlySymptomsController),
              _buildTextField('زلّة تنفسية جهدية', _breathingDifficultyController),
              _buildTextField('إيكو قلبي', _heartEchoController),
              _buildTextField('قثطرة قلبية', _heartCatheterizationController),
              _buildTextField('سوابق مرضية', _medicalHistoryController),
              _buildTextField('الأدوية', _medicationsController),
              _buildTextField('سوابق تحسسية', _allergicHistoryController),
              _buildTextField('سوابق تداخلات طبية', _medicalInteractionsController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Save data locally
                    await _savePatientData();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3c8ce7),
                ),
                child: Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _savePatientData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patient_name', _patientNameController.text);
    await prefs.setString('patient_age', _patientAgeController.text);
    await prefs.setString('main_complaint', _mainComplaintController.text);
    await prefs.setString('duration', _durationController.text);
    await prefs.setString('spread', _spreadController.text);
    await prefs.setString('induction', _inductionController.text);
    await prefs.setString('relief', _reliefController.text);
    await prefs.setString('time_duration', _timeDurationController.text);
    await prefs.setString('friendly_symptoms', _friendlySymptomsController.text);
    await prefs.setString('breathing_difficulty', _breathingDifficultyController.text);
    await prefs.setString('heart_echo', _heartEchoController.text);
    await prefs.setString('heart_catheterization', _heartCatheterizationController.text);
    await prefs.setString('medical_history', _medicalHistoryController.text);
    await prefs.setString('medications', _medicationsController.text);
    await prefs.setString('allergic_history', _allergicHistoryController.text);
    await prefs.setString('medical_interactions', _medicalInteractionsController.text);
  }
}
