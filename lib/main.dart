import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const EchoFxApp());

class EchoFxApp extends StatelessWidget {
  const EchoFxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ECHO FX',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6), brightness: Brightness.dark)),
    home: const EchoHome(),
  );
}

class EchoHome extends StatefulWidget {
  const EchoHome({super.key});
  @override
  State<EchoHome> createState() => _EchoHomeState();
}

class _EchoHomeState extends State<EchoHome> {
  static const channel = MethodChannel('echo_fx/audio');
  double level = 55;
  bool running = false;
  String message = 'اضغط تشغيل واسمح باستخدام المايك';

  Future<void> start() async {
    try {
      await channel.invokeMethod('start', {'level': level.round()});
      if (!mounted) return;
      setState(() { running = true; message = 'الصدى يعمل مباشرة'; });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => message = e.message ?? 'تعذر تشغيل المايك');
    }
  }

  Future<void> stop() async {
    try { await channel.invokeMethod('stop'); } catch (_) {}
    if (mounted) setState(() { running = false; message = 'تم إيقاف التأثير'; });
  }

  Future<void> changeLevel(double value) async {
    setState(() => level = value);
    if (running) {
      try { await channel.invokeMethod('setLevel', {'level': value.round()}); }
      catch (_) {}
    }
  }

  @override
  void dispose() {
    channel.invokeMethod('stop');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF10101A),
    appBar: AppBar(title: const Text('ECHO FX'), centerTitle: true, backgroundColor: Colors.transparent),
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.graphic_eq_rounded, size: 92, color: Color(0xFFAA87FF)),
        const SizedBox(height: 18),
        const Text('صدى مباشر للصوت', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 42),
        Text('${level.round()}%', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
        const Text('مستوى الصدى', style: TextStyle(color: Colors.white60)),
        Slider(value: level, min: 0, max: 100, divisions: 100, onChanged: changeLevel),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Text('بدون صدى'), Text('صدى قوي')
        ]),
        const SizedBox(height: 36),
        SizedBox(width: double.infinity, height: 58,
          child: FilledButton.icon(
            onPressed: running ? stop : start,
            icon: Icon(running ? Icons.stop_rounded : Icons.mic_rounded),
            label: Text(running ? 'إيقاف' : 'تشغيل المايك'),
          )),
        const SizedBox(height: 20),
        const Text('استخدم سماعات لتجنب رجوع صوت السماعة إلى المايك وحدوث صفير.',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.orangeAccent, fontSize: 13)),
      ]),
    ))),
  );
}