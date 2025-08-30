import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'landing_screen.dart';
import 'home.dart';
import 'clinical_history_screen.dart';
import 'medical_story.dart';
import 'patient_info.dart';
import 'add_patient.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocPal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'AvenirArabic',
        scaffoldBackgroundColor: const Color(0xFF0f172a),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0f172a),
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/vitalSigns': (context) => const HomeScreen(),
        '/clinicalHistory': (context) => const ClinicalHistoryScreen(),
        '/clinicalStory': (context) => MedicalHistoryScreen(),
        '/patientInfo': (context) => PatientInfoScreen(),
        '/addPatient': (context) => AddPatientScreen(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', 'AE'), // Arabic, United Arab Emirates
      ],
      locale: Locale('ar', 'AE'),
    );
  }
}