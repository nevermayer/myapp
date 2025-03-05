import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';
import 'camaras_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late Future<List<Tramo>> _tramos;
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _refreshTramos();
  }

  void _refreshTramos() {
    setState(() {
      _tramos = _dbHelper.getTramos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tramos')),
      body: FutureBuilder<List<Tramo>>(
        future: _tramos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final tramos = snapshot.data!;
            return ListView.builder(
              itemCount: tramos.length,
              itemBuilder: (context, index) {
                final tramo = tramos[index];
                return ListTile(
                  title: Text(tramo.nombre),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CamarasScreen(tramo: tramo),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => _exportCamarasToExcelAndShare(tramo),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(tramo),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(tramo.id!),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay datos'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _exportCamarasToExcelAndShare(Tramo tramo) async {
    List<Camara> camaras = await _dbHelper.getCamaras(tramo.id!);
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Camaras'];

    // Encabezados
    sheetObject.appendRow([
        TextCellValue('ID'), 
        TextCellValue('Nombre'),
        TextCellValue('Tramo ID')
        ]);

    // Datos
    for (var camara in camaras) {
      sheetObject.appendRow([
            IntCellValue(camara.id!), 
            TextCellValue(camara.nombre),
            IntCellValue(camara.tramoId)
           ]);
    }

    // Guardar el archivo
    var bytes = excel.encode();
    if (bytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/camaras.xlsx');
      await file.writeAsBytes(bytes);

      // Compartir el archivo
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Cámaras del tramo ${tramo.nombre}');
    } else {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al exportar a Excel')),
        );
      }
    }
  }

  void _showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Tramo'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre del Tramo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _insertTramo(nameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Tramo tramo) {
    final TextEditingController nameController = TextEditingController(
      text: tramo.nombre,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Tramo'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre del Tramo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _updateTramo(
                    Tramo(id: tramo.id, nombre: nameController.text),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Tramo'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este tramo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteTramo(id);
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _insertTramo(String nombre) async {
    final tramo = Tramo(nombre: nombre);
    await _dbHelper.insertTramo(tramo);
    _refreshTramos();
  }

  void _updateTramo(Tramo tramo) async {
    await _dbHelper.updateTramo(tramo);
    _refreshTramos();
  }

  void _deleteTramo(int id) async {
    await _dbHelper.deleteTramo(id);
    _refreshTramos();
  }
}
