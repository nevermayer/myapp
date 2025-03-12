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
      theme: ThemeData(
        //scaffoldBackgroundColor: Color.fromRGBO(239,250,255,0.890),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(18,99,199,1), // Un azul como ejemplo
          foregroundColor: Colors.white,
        ),
      ),
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
    body: Stack(
      children: [
        // Fondo con imagen decorativa
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/background.jpg"), // Imagen de fondo
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(flex: 0, child: Container(color: Colors.white)),
            ],
          ),
        ),
        // Contenido Principal
        Center(
          child: SingleChildScrollView( // Nuevo widget
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 220),
                  // Logo
                  Image.asset("assets/logo2.png", height: 100), // Asegúrate de agregar esta imagen en assets
                  SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Apellido'),
                  ),
                  SizedBox(height: 16),
                  //ElevatedButton(onPressed: saveData, child: Text('Guardar')),
                  ElevatedButton(
                    onPressed: saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Ingresar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
