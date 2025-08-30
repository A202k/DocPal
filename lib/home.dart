import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_application_1/patient_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> icuPatients = [];
  List<Map<String, dynamic>> cardiacSurgeryPatients = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      icuPatients = (prefs.getStringList('icuPatients') ?? []).map((e) {
        var patient = jsonDecode(e);
        return {
          'name': patient['name'],
          'icon': IconData(patient['icon']['codePoint'], fontFamily: patient['icon']['fontFamily'])
        };
      }).toList();
      cardiacSurgeryPatients = (prefs.getStringList('cardiacSurgeryPatients') ?? []).map((e) {
        var patient = jsonDecode(e);
        return {
          'name': patient['name'],
          'icon': IconData(patient['icon']['codePoint'], fontFamily: patient['icon']['fontFamily'])
        };
      }).toList();
    });
  }

  Future<void> _savePatients() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('icuPatients', icuPatients.map((e) => jsonEncode({
      'name': e['name'],
      'icon': {'codePoint': e['icon'].codePoint, 'fontFamily': e['icon'].fontFamily}
    })).toList());
    prefs.setStringList('cardiacSurgeryPatients', cardiacSurgeryPatients.map((e) => jsonEncode({
      'name': e['name'],
      'icon': {'codePoint': e['icon'].codePoint, 'fontFamily': e['icon'].fontFamily}
    })).toList());
  }

  Future<void> _deletePatientPrefs(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'pi_${name}_';
    final keys = prefs.getKeys();
    for (final k in keys) {
      if (k.startsWith(prefix)) {
        await prefs.remove(k);
      }
    }
  }

  void _addPatient(String name, String location) {
    setState(() {
      if (location == 'العناية المشددة') {
        icuPatients.add({'name': name, 'icon': Icons.local_hospital});
      } else {
        cardiacSurgeryPatients.add({'name': name, 'icon': Icons.favorite});
      }
      _savePatients();
    });
  }

  void _showAddPatientDialog() {
    String name = '';
    String location = 'العناية المشددة';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('إضافة مريض'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(hintText: 'اسم المريض'),
              ),
              DropdownButton<String>(
                value: location,
                items: <String>['العناية المشددة', 'شعبة الجراحة القلبية']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    location = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('إضافة'),
              onPressed: () {
                _addPatient(name, location);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPatientInfoScreen(String patientName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientInfoScreen(patientName: patientName),
      ),
    );
  }

  

  Widget _buildGlassPatientList(List<Map<String, dynamic>> patients) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = patients[index];
        final name = item['name'] as String;
        return Dismissible(
          key: ValueKey<String>('patient_$name'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('تأكيد الحذف'),
                content: Text('هل تريد حذف "$name"؟'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
                  ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('حذف')),
                ],
              ),
            );
          },
          onDismissed: (_) {
            setState(() {
              icuPatients.removeWhere((p) => (p['name'] as String) == name);
              cardiacSurgeryPatients.removeWhere((p) => (p['name'] as String) == name);
              _savePatients();
            });
            _deletePatientPrefs(name);
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showPatientInfoScreen(name),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.14), Colors.white.withOpacity(0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 10)),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  child: Icon(item['icon'] as IconData, color: Colors.cyanAccent),
                ),
                title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPatientInfoDialog(String patientName) {
    List<String> injections = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('معلومات المريض: $patientName'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(hintText: 'BP'),
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'HR'),
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'SPO2 (%)'),
                    ),
                    SizedBox(height: 20),
                    Text('Urine Amount (ml)'),
                    Container(
                      height: 100,
                      color: Colors.lightBlueAccent,
                      child: Center(child: Text('Liquid Effect Placeholder')),
                    ),
                    SizedBox(height: 20),
                    Text('Blood in Drainage (degrees)'),
                    Container(
                      height: 100,
                      color: Colors.redAccent,
                      child: Center(child: Text('Liquid Effect Placeholder')),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: List.generate(injections.length, (index) {
                        return Text(injections[index]);
                      }),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          injections.add('New Injection');
                        });
                      },
                      child: Text('+ Add Injection'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Copy Info'),
                  onPressed: () {
                    // Copy logic here
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Share via WhatsApp'),
                  onPressed: () {
                    // Share logic here
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('المؤشرات الحيوية', style: TextStyle(fontSize: 22, color: Colors.white)),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Styled TabBar segment
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.08)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 15)),
                        BoxShadow(color: Colors.cyanAccent.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [Colors.cyanAccent.withOpacity(0.35), Colors.blueAccent.withOpacity(0.25)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3)),
                        ],
                      ),
                      tabs: const [
                        Tab(icon: Icon(Icons.local_hospital, color: Colors.redAccent), text: 'العناية المشددة'),
                        Tab(icon: Icon(Icons.favorite, color: Colors.lightBlueAccent), text: 'شعبة الجراحة القلبية'),
                      ],
                    ),
                  ),
                ),
                // Patient lists with glass cards
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGlassPatientList(icuPatients),
                      _buildGlassPatientList(cardiacSurgeryPatients),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.cyanAccent.shade400,
          foregroundColor: Colors.black,
          elevation: 8,
          onPress: _showAddPatientDialog,
          children: const [],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
