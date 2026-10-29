import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: TabuadaApp()));
}

class TabuadaApp extends StatefulWidget {
  const TabuadaApp({super.key});

  @override
  State<TabuadaApp> createState() => _TabuadaAppState();
}

class _TabuadaAppState extends State<TabuadaApp> {
  final TextEditingController _controller = TextEditingController();
  int fator = 1;
  int multiplicador = 1;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fator = prefs.getInt('fator') ?? 1;
      multiplicador = prefs.getInt('multiplicador') ?? 1;
    });
  }

  Future<void> _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fator', fator);
    await prefs.setInt('multiplicador', multiplicador);
  }

  void _verificar() {
    int? resposta = int.tryParse(_controller.text);
    if (resposta == fator * multiplicador) {
      setState(() {
        if (multiplicador == 10) {
          fator++;
          multiplicador = 1;
        } else {
          multiplicador++;
        }
      });
      _salvar();
    } else {
      final fErro = fator;
      final mErro = multiplicador;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Errou, clique aqui para continuar'),
          action: SnackBarAction(
            label: 'Continuar',
            onPressed: () {
              setState(() {
                fator = fErro;
                multiplicador = mErro;
              });
              _salvar();
            },
          ),
        ),
      );

      setState(() {
        fator++;
        multiplicador = 1;
      });
      _salvar();
    }
    setState(() {
      _controller.clear();
    });
  }

  Widget _btn(String txt) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              if (txt == 'C') {
                _controller.clear();
              } else if (txt == 'OK') {
                _verificar();
              } else {
                _controller.text += txt;
              }
            });
          },
          child: Text(txt, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tabuada do $fator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: multiplicador / 10),
            const SizedBox(height: 16),
            Text(
              '$fator x $multiplicador = ${_controller.text.isEmpty ? '?' : _controller.text}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(children: [_btn('7'), _btn('8'), _btn('9')]),
            Row(children: [_btn('4'), _btn('5'), _btn('6')]),
            Row(children: [_btn('1'), _btn('2'), _btn('3')]),
            Row(children: [_btn('C'), _btn('0'), _btn('OK')]),
          ],
        ),
      ),
    );
  }
}
