import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ClinicalHistoryScreen extends StatefulWidget {
  const ClinicalHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ClinicalHistoryScreen> createState() => _ClinicalHistoryScreenState();
}

class _ClinicalHistoryScreenState extends State<ClinicalHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Patient Basic Info Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  String _gender = 'ذكر';
  String _bloodType = 'A+';

  // Medical History Controllers
  final _chiefComplaintController = TextEditingController();
  final _presentIllnessController = TextEditingController();
  final _pastMedicalController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  final _socialHistoryController = TextEditingController();

  // Physical Examination Controllers
  final _generalAppearanceController = TextEditingController();
  final _vitalSignsController = TextEditingController();
  final _headNeckController = TextEditingController();
  final _cardiovascularController = TextEditingController();
  final _respiratoryController = TextEditingController();
  final _abdomenController = TextEditingController();
  final _extremitiesController = TextEditingController();
  final _neurologicalController = TextEditingController();

  // Lab & Imaging Controllers
  final _labResultsController = TextEditingController();
  final _imagingController = TextEditingController();
  final _ecgController = TextEditingController();
  final _otherTestsController = TextEditingController();

  // Plan Controllers
  final _diagnosisController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _followUpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _nameController.dispose();
    _ageController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _chiefComplaintController.dispose();
    _presentIllnessController.dispose();
    _pastMedicalController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _familyHistoryController.dispose();
    _socialHistoryController.dispose();
    _generalAppearanceController.dispose();
    _vitalSignsController.dispose();
    _headNeckController.dispose();
    _cardiovascularController.dispose();
    _respiratoryController.dispose();
    _abdomenController.dispose();
    _extremitiesController.dispose();
    _neurologicalController.dispose();
    _labResultsController.dispose();
    _imagingController.dispose();
    _ecgController.dispose();
    _otherTestsController.dispose();
    _diagnosisController.dispose();
    _treatmentPlanController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  Widget _buildGlassCard({required Widget child, double? height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withOpacity(0.1),
            BlendMode.overlay,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.cyanAccent.withOpacity(0.8))
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
          ),
        ),
        validator: (value) {
          if (maxLines == 1 && (value == null || value.isEmpty)) {
            return 'يرجى إدخال $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.cyanAccent, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('المعلومات الأساسية', Icons.person),
              _buildTextField(
                controller: _nameController,
                label: 'اسم المريض',
                icon: Icons.person_outline,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'العمر',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        dropdownColor: const Color(0xFF1e293b),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'الجنس',
                          labelStyle:
                              TextStyle(color: Colors.white.withOpacity(0.8)),
                          prefixIcon: Icon(Icons.wc,
                              color: Colors.cyanAccent.withOpacity(0.8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        items: ['ذكر', 'أنثى'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _idController,
                label: 'رقم الهوية / السجل الطبي',
                icon: Icons.badge,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _bloodType,
                  dropdownColor: const Color(0xFF1e293b),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'فصيلة الدم',
                    labelStyle:
                        TextStyle(color: Colors.white.withOpacity(0.8)),
                    prefixIcon: Icon(Icons.bloodtype,
                        color: Colors.cyanAccent.withOpacity(0.8)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _bloodType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('التاريخ المرضي', Icons.history),
              _buildTextField(
                controller: _chiefComplaintController,
                label: 'الشكوى الرئيسية',
                icon: Icons.report_problem,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _presentIllnessController,
                label: 'تاريخ المرض الحالي',
                icon: Icons.sick,
                maxLines: 4,
              ),
              _buildTextField(
                controller: _pastMedicalController,
                label: 'التاريخ المرضي السابق',
                icon: Icons.medical_information,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _medicationsController,
                label: 'الأدوية الحالية',
                icon: Icons.medication,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _allergiesController,
                label: 'الحساسية',
                icon: Icons.warning,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _familyHistoryController,
                label: 'التاريخ العائلي',
                icon: Icons.family_restroom,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _socialHistoryController,
                label: 'التاريخ الاجتماعي',
                icon: Icons.people,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicalExamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('الفحص السريري', Icons.medical_services),
              _buildTextField(
                controller: _generalAppearanceController,
                label: 'المظهر العام',
                icon: Icons.accessibility,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _vitalSignsController,
                label: 'العلامات الحيوية',
                icon: Icons.monitor_heart,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _headNeckController,
                label: 'الرأس والرقبة',
                icon: Icons.face,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _cardiovascularController,
                label: 'القلب والأوعية الدموية',
                icon: Icons.favorite,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _respiratoryController,
                label: 'الجهاز التنفسي',
                icon: Icons.air,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _abdomenController,
                label: 'البطن',
                icon: Icons.airline_seat_flat,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _extremitiesController,
                label: 'الأطراف',
                icon: Icons.accessibility_new,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _neurologicalController,
                label: 'الفحص العصبي',
                icon: Icons.psychology,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestigationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('الفحوصات والتحاليل', Icons.biotech),
              _buildTextField(
                controller: _labResultsController,
                label: 'نتائج المختبر',
                icon: Icons.science,
                maxLines: 4,
              ),
              _buildTextField(
                controller: _imagingController,
                label: 'الأشعة والتصوير',
                icon: Icons.image,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _ecgController,
                label: 'تخطيط القلب',
                icon: Icons.show_chart,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _otherTestsController,
                label: 'فحوصات أخرى',
                icon: Icons.assignment,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('الخطة العلاجية', Icons.assignment_turned_in),
              _buildTextField(
                controller: _diagnosisController,
                label: 'التشخيص',
                icon: Icons.local_hospital,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _treatmentPlanController,
                label: 'خطة العلاج',
                icon: Icons.healing,
                maxLines: 4,
              ),
              _buildTextField(
                controller: _followUpController,
                label: 'المتابعة',
                icon: Icons.calendar_today,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveData,
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ البيانات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportData,
                      icon: const Icon(Icons.share),
                      label: const Text('تصدير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'name': _nameController.text,
        'age': _ageController.text,
        'gender': _gender,
        'id': _idController.text,
        'phone': _phoneController.text,
        'bloodType': _bloodType,
        'chiefComplaint': _chiefComplaintController.text,
        'presentIllness': _presentIllnessController.text,
        'pastMedical': _pastMedicalController.text,
        'medications': _medicationsController.text,
        'allergies': _allergiesController.text,
        'familyHistory': _familyHistoryController.text,
        'socialHistory': _socialHistoryController.text,
        'generalAppearance': _generalAppearanceController.text,
        'vitalSigns': _vitalSignsController.text,
        'headNeck': _headNeckController.text,
        'cardiovascular': _cardiovascularController.text,
        'respiratory': _respiratoryController.text,
        'abdomen': _abdomenController.text,
        'extremities': _extremitiesController.text,
        'neurological': _neurologicalController.text,
        'labResults': _labResultsController.text,
        'imaging': _imagingController.text,
        'ecg': _ecgController.text,
        'otherTests': _otherTestsController.text,
        'diagnosis': _diagnosisController.text,
        'treatmentPlan': _treatmentPlanController.text,
        'followUp': _followUpController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
          'clinical_history_${_nameController.text}', jsonEncode(data));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ البيانات بنجاح'),
          backgroundColor: Colors.green.withOpacity(0.8),
        ),
      );
    }
  }

  void _exportData() {
    // Generate formatted text
    String exportText = '''
═══════════════════════════════════════
        القصة السريرية
═══════════════════════════════════════

【 المعلومات الأساسية 】
• الاسم: ${_nameController.text}
• العمر: ${_ageController.text}
• الجنس: $_gender
• الهوية: ${_idController.text}
• الهاتف: ${_phoneController.text}
• فصيلة الدم: $_bloodType

【 التاريخ المرضي 】
• الشكوى الرئيسية: ${_chiefComplaintController.text}
• المرض الحالي: ${_presentIllnessController.text}
• التاريخ المرضي السابق: ${_pastMedicalController.text}
• الأدوية الحالية: ${_medicationsController.text}
• الحساسية: ${_allergiesController.text}
• التاريخ العائلي: ${_familyHistoryController.text}
• التاريخ الاجتماعي: ${_socialHistoryController.text}

【 الفحص السريري 】
• المظهر العام: ${_generalAppearanceController.text}
• العلامات الحيوية: ${_vitalSignsController.text}
• الرأس والرقبة: ${_headNeckController.text}
• القلب والأوعية: ${_cardiovascularController.text}
• الجهاز التنفسي: ${_respiratoryController.text}
• البطن: ${_abdomenController.text}
• الأطراف: ${_extremitiesController.text}
• الفحص العصبي: ${_neurologicalController.text}

【 الفحوصات 】
• نتائج المختبر: ${_labResultsController.text}
• الأشعة: ${_imagingController.text}
• تخطيط القلب: ${_ecgController.text}
• فحوصات أخرى: ${_otherTestsController.text}

【 الخطة العلاجية 】
• التشخيص: ${_diagnosisController.text}
• خطة العلاج: ${_treatmentPlanController.text}
• المتابعة: ${_followUpController.text}

═══════════════════════════════════════
التاريخ: ${DateTime.now().toString().substring(0, 19)}
═══════════════════════════════════════
''';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: exportText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ البيانات إلى الحافظة'),
        backgroundColor: Colors.blue.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Text(
                                'القصة السريرية',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Tab Bar
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            indicatorColor: Colors.cyanAccent,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white60,
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'البيانات الأساسية'),
                              Tab(text: 'التاريخ المرضي'),
                              Tab(text: 'الفحص السريري'),
                              Tab(text: 'الفحوصات'),
                              Tab(text: 'الخطة العلاجية'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBasicInfoTab(),
                        _buildMedicalHistoryTab(),
                        _buildPhysicalExamTab(),
                        _buildInvestigationsTab(),
                        _buildPlanTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}