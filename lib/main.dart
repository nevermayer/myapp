import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ingreso de Nombre y Apellido',
      home: NameEntryScreen(),
    );
  }
}

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});
  @override
  NameEntryScreenState createState() => NameEntryScreenState();
}

class NameEntryScreenState extends State<NameEntryScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Función para guardar los datos en SharedPreferences
  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('lastName', _lastNameController.text);
    if (!mounted) return;

    // Redirigir a la pantalla principal después de guardar los datos
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingrese su Nombre y Apellido')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveData, child: Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
