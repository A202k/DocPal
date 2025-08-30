import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Removed unnecessary Cupertino import
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientInfoScreen extends StatefulWidget {
  final String patientName;

  const PatientInfoScreen({Key? key, required this.patientName}) : super(key: key);

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  double sysBP = 120;
  double diaBP = 70;
  double hr = 80;
  double spo2 = 98;
  double urine = 0;
  double bloodDrainage = 0;
  double lastSavedUrine = 0;
  double lastSavedDrainage = 0;
  List<String> injections = [];
  final TextEditingController _medicineController = TextEditingController();
  bool _isDraggingGauge = false;
  // Preset medication chips with optional rate when active
  final Map<String, String?> _activePresetRates = {}; // name -> rate text
  final List<String> _presetMeds = const [
    'لنترال (nitroglycerin)',
    'بوتاسيوم (K)',
    'بيكربونات (HCO3)',
    'هيبارين',
    'كوردان',
    'أنسولين',
    'ديبوتريكس (dobutamine)',
    'دوبامين (Dopamine)',
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معلومات المريض: ${widget.patientName}',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0f172a),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              physics: _isDraggingGauge
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              children: [
                _buildSection('🩺 المؤشرات الحيوية', [
                  Text(
                    'BP: ${sysBP.toInt()}/${diaBP.toInt()} mmHg',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  _buildSlider('الانقباضي (SYS): ${sysBP.toInt()} mmHg', sysBP, 80, 200, (value) {
                    setState(() {
                      sysBP = value;
                      if (diaBP >= sysBP) diaBP = (sysBP - 5).clamp(40, 130);
                    });
                  }),
                  _buildSlider('الانبساطي (DIA): ${diaBP.toInt()} mmHg', diaBP, 40, 130, (value) {
                    setState(() {
                      diaBP = value;
                      if (diaBP >= sysBP) sysBP = (diaBP + 5).clamp(80, 200);
                    });
                  }),
                  _buildSlider('HR: ${hr.toStringAsFixed(0)} bpm', hr, 40, 180, (value) => setState(() => hr = value)),
                  _buildSlider('SpO₂: ${spo2.toStringAsFixed(0)}%', spo2, 70, 100, (value) => setState(() => spo2 = value)),
                ]),
                // Separate sections for urine and drainage
                _buildSection('🚰 البول', [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _buildSlidingContainer('🚰 البول', urine, Colors.amber,
                          (value) => setState(() => urine = value)),
                    ),
                  ),
                ]),
                _buildSection('⚡ المفجر', [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _buildSlidingContainer('⚡ المفجر', bloodDrainage, Colors.redAccent,
                          (value) => setState(() => bloodDrainage = value)),
                    ),
                  ),
                ]),
                _buildSection('💉 الأدوية/المحاليل', [
                  // Preset tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: _presetMeds.map((name) {
                      final rate = _activePresetRates[name];
                      final isActive = rate != null;
                      final label = isActive ? '$name - $rate' : name;
                      return InputChip(
                        label: Text(label, style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF334155),
                        selectedColor: const Color(0xFF0E7490),
                        selected: isActive,
                        showCheckmark: false,
                        onPressed: () async {
                          final newRate = await _promptForRate(context, name, initial: rate);
                          if (newRate != null && newRate.trim().isNotEmpty) {
                            setState(() => _activePresetRates[name] = newRate.trim());
                          }
                        },
                        onDeleted: isActive
                            ? () => setState(() => _activePresetRates.remove(name))
                            : null,
                        deleteIconColor: Colors.redAccent,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Custom additions as chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: injections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final full = entry.value;
                      final base = full.split(' - ').first;
                      final init = full.contains(' - ') ? full.split(' - ').last : null;
                      return InputChip(
                        label: Text(full, style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF334155),
                        selected: true,
                        selectedColor: const Color(0xFF0E7490),
                        showCheckmark: false,
                        onPressed: () async {
                          final newRate = await _promptForRate(context, base, initial: init);
                          if (newRate != null && newRate.trim().isNotEmpty) {
                            setState(() => injections[index] = '$base - ${newRate.trim()}');
                          }
                        },
                        onDeleted: () => setState(() => injections.removeAt(index)),
                        deleteIconColor: Colors.redAccent,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _medicineController,
                    decoration: InputDecoration(
                      hintText: 'أدخل دواء جديد',
                      prefixIcon: const Icon(Icons.add),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      hintStyle: const TextStyle(color: Colors.white60),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) {
                      if (_medicineController.text.isNotEmpty) {
                        setState(() {
                          injections.add(_medicineController.text);
                          _medicineController.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('إضافة دواء'),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.cyanAccent.withOpacity(0.8),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        if (_medicineController.text.isNotEmpty) {
                          setState(() {
                            injections.add(_medicineController.text);
                            _medicineController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyInfo,
                        icon: const Icon(Icons.copy_all_rounded),
                        label: const Text('نسخ التقرير'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareInfo,
                        icon: const Icon(Icons.share),
                        label: const Text('مشاركة واتساب'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.greenAccent.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white)),
                  const SizedBox(height: 12),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    double clamp(double v) => v.clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final entered = await _promptForNumber(label, initial: value.toStringAsFixed(0), min: min, max: max);
                  if (entered != null) onChanged(clamp(entered));
                },
                child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
              onPressed: () => onChanged(clamp(value - 1)),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
              onPressed: () => onChanged(clamp(value + 1)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.blueAccent,
            overlayColor: Colors.blueAccent.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSlidingContainer(String label, double value, Color color, ValueChanged<double> onChanged) {
    const double maxValue = 2000.0;
    final double screenW = MediaQuery.of(context).size.width;
    final bool isCompact = screenW < 420;
    final double gaugeWidth = isCompact ? 120.0 : 140.0;
    final double gaugeHeight = isCompact ? 300.0 : 340.0;

    double clampToStep(double v) => (v / 10).round() * 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          textDirection: TextDirection.ltr, // keep ruler on the right side of gauge even in RTL
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final localY = details.localPosition.dy.clamp(0.0, gaugeHeight);
                final ratio = (gaugeHeight - localY) / gaugeHeight;
                final v = clampToStep((ratio * maxValue).clamp(0.0, maxValue));
                setState(() => onChanged(v));
              },
              onVerticalDragStart: (details) {
                setState(() => _isDraggingGauge = true);
                final localY = details.localPosition.dy.clamp(0.0, gaugeHeight);
                final ratio = (gaugeHeight - localY) / gaugeHeight;
                final v = clampToStep((ratio * maxValue).clamp(0.0, maxValue));
                setState(() => onChanged(v));
              },
              onVerticalDragUpdate: (details) {
                final localY = details.localPosition.dy.clamp(0.0, gaugeHeight);
                final ratio = (gaugeHeight - localY) / gaugeHeight;
                final v = clampToStep((ratio * maxValue).clamp(0.0, maxValue));
                setState(() => onChanged(v));
              },
              onVerticalDragEnd: (details) {
                setState(() => _isDraggingGauge = false);
              },
              child: Container(
                width: gaugeWidth,
                height: gaugeHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.18),
                      color.withOpacity(0.10),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.2), blurRadius: 18, offset: const Offset(0, 10)),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        height: (value / maxValue) * gaugeHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              color.withOpacity(0.95),
                              color.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [Colors.white.withOpacity(0.06), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Text(
                        '${value.toStringAsFixed(0)} ml',
                        key: ValueKey<int>(value.round()),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 44,
              height: gaugeHeight,
              child: CustomPaint(
                painter: VerticalRulerPainter(
                  maxValue: maxValue,
                  labelEvery: 200,
                  minorTick: 50,
                  baseColor: Colors.white.withOpacity(0.9),
                  accentColor: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                final newV = clampToStep((value - 10).clamp(0.0, maxValue));
                onChanged(newV);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: const StadiumBorder(),
              ),
              child: const Text('- 10ml'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final newV = clampToStep((value + 10).clamp(0.0, maxValue));
                onChanged(newV);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: const StadiumBorder(),
              ),
              child: const Text('+ 10ml'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlidingContainerWithControls(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
              onPressed: () => onChanged(value - 10),
            ),
            _buildSlidingContainer(label, value, color, onChanged),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
              onPressed: () => onChanged(value + 10),
            ),
          ],
        ),
      ],
    );
  }

  void _copyInfo() {
    final text = _buildReportText();
    Clipboard.setData(ClipboardData(text: text));
    _savePatientData();
  }

  String _buildReportText() {
    final buffer = StringBuffer();
    final currentTime = TimeOfDay.now().format(context);
    buffer.writeln('🕑 التوقيت: $currentTime');
    buffer.writeln('👤 المريض: ${widget.patientName}\n');

    if (spo2 > 0) buffer.writeln('SpO₂: ${spo2.toStringAsFixed(0)}%');
    if (hr > 0) buffer.writeln('❤️ HR: ${hr.toStringAsFixed(0)} نبضة/دقيقة');
    if (sysBP > 0 && diaBP > 0) buffer.writeln('🩸 BP: ${sysBP.toStringAsFixed(0)}/${diaBP.toStringAsFixed(0)} سم زئبق');

    if (bloodDrainage > 0) {
      final delta = (bloodDrainage - lastSavedDrainage).round();
      final deltaStr = delta != 0 ? ' (${delta.toString()})' : '';
      buffer.writeln('⚡ المفجر: ${bloodDrainage.toStringAsFixed(0)}$deltaStr مل');
    }
    if (urine > 0) {
      final delta = (urine - lastSavedUrine).round();
      final deltaStr = delta != 0 ? ' (${delta.toString()})' : '';
      buffer.writeln('🚰 البول: ${urine.toStringAsFixed(0)}$deltaStr مل');
    }

    // Medications section: preset active + custom entries
    final activePresets = _activePresetRates.entries
        .where((e) => (e.value != null && e.value!.trim().isNotEmpty))
        .map((e) => '${e.key} - ${e.value}')
        .toList();
    final custom = List<String>.from(injections);
    final allMeds = [...activePresets, ...custom];
    if (allMeds.isNotEmpty) {
      buffer.writeln('\n💉 الأدوية/المحاليل:');
      for (final m in allMeds) {
        buffer.writeln(m);
      }
    }
    return buffer.toString();
  }

  Future<void> _shareInfo() async {
    final text = _buildReportText();
    // Always open WhatsApp in share/composer mode so user can choose chats
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to universal share-to-WhatsApp web link
      final fallback = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
    await _savePatientData();
  }

  // Preferences key helpers (per patient)
  String _key(String suffix) => 'pi_${widget.patientName}_$suffix';

  Future<void> _loadPatientData() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedSys = prefs.getDouble(_key('sysBP'));
    final loadedDia = prefs.getDouble(_key('diaBP'));
    final loadedHr = prefs.getDouble(_key('hr'));
    final loadedSp = prefs.getDouble(_key('spo2'));
    final loadedUr = prefs.getDouble(_key('urine'));
    final loadedDr = prefs.getDouble(_key('drainage'));
    final savedUr = prefs.getDouble(_key('lastUrine'));
    final savedDr = prefs.getDouble(_key('lastDrainage'));
    final ratesStr = prefs.getString(_key('activeRates'));
    final injList = prefs.getStringList(_key('injections'));

    setState(() {
      if (loadedSys != null) sysBP = loadedSys;
      if (loadedDia != null) diaBP = loadedDia;
      if (loadedHr != null) hr = loadedHr;
      if (loadedSp != null) spo2 = loadedSp;
      if (loadedUr != null) urine = loadedUr;
      if (loadedDr != null) bloodDrainage = loadedDr;
      lastSavedUrine = savedUr ?? lastSavedUrine;
      lastSavedDrainage = savedDr ?? lastSavedDrainage;

      _activePresetRates.clear();
      if (ratesStr != null && ratesStr.isNotEmpty) {
        try {
          final Map<String, dynamic> m = jsonDecode(ratesStr);
          m.forEach((k, v) => _activePresetRates[k] = v?.toString());
        } catch (_) {}
      }
      injections = injList ?? injections;
    });
  }

  Future<void> _saveCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key('sysBP'), sysBP);
    await prefs.setDouble(_key('diaBP'), diaBP);
    await prefs.setDouble(_key('hr'), hr);
    await prefs.setDouble(_key('spo2'), spo2);
    await prefs.setDouble(_key('urine'), urine);
    await prefs.setDouble(_key('drainage'), bloodDrainage);
    await prefs.setString(_key('activeRates'), jsonEncode(_activePresetRates));
    await prefs.setStringList(_key('injections'), List<String>.from(injections));
  }

  // Save current values and also update the last-saved markers for deltas
  Future<void> _savePatientData() async {
    await _saveCurrentState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key('lastUrine'), urine);
    await prefs.setDouble(_key('lastDrainage'), bloodDrainage);
    lastSavedUrine = urine;
    lastSavedDrainage = bloodDrainage;
  }

  Future<double?> _promptForNumber(String label, {required String initial, required double min, required double max}) async {
    final controller = TextEditingController(text: initial);
    double? result;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0f172a),
          title: Text('أدخل قيمة $label', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              hintText: 'بين ${min.toInt()} و ${max.toInt()}',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => Navigator.of(ctx).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final v = double.tryParse(controller.text.trim());
                if (v != null) {
                  result = v.clamp(min, max);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
    return result;
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _saveCurrentState();
    super.dispose();
  }

  Future<String?> _promptForRate(BuildContext context, String name, {String? initial}) async {
    final controller = TextEditingController(text: initial ?? '');
    String? result;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0f172a),
          title: Text('أدخل السرعة لـ "$name"', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'مثال: 3',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                result = controller.text;
                Navigator.of(ctx).pop();
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
    return result;
  }

}

class VerticalRulerPainter extends CustomPainter {
  final double maxValue;
  final double labelEvery;
  final double minorTick;
  final Color baseColor;
  final Color accentColor;

  VerticalRulerPainter({
    required this.maxValue,
    this.labelEvery = 200,
    this.minorTick = 50,
    required this.baseColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = baseColor
      ..strokeWidth = 1.0;
    final majorPaint = Paint()
      ..color = accentColor.withOpacity(0.95)
      ..strokeWidth = 2.0;

    for (double v = 0; v <= maxValue; v += minorTick) {
      final y = size.height - (v / maxValue) * size.height;
      final isMajor = v % labelEvery == 0;
      final isMedium = !isMajor && v % 100 == 0;
      final tickLen = isMajor ? 16.0 : (isMedium ? 10.0 : 6.0);
      final paint = isMajor ? majorPaint : tickPaint;
      canvas.drawLine(Offset(size.width - tickLen, y), Offset(size.width, y), paint);

      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(
            text: v.toInt().toString(),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(size.width - tickLen - tp.width - 4, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant VerticalRulerPainter oldDelegate) => true;
}
