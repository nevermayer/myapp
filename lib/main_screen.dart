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
      appBar: AppBar(title: const Text('Lista de Componentes')),
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
                return Container(
                  color: index.isEven ? Colors.white: const Color.fromRGBO(214,242,255,0.729),
                  child: ListTile(
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
    //List<Camara> camaras = await _dbHelper.getCamaras(tramo.id!);
    final data = await _dbHelper.getCamarasAndValvulasData(tramo.id!);
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Camaras_Valvulas'];

    // Encabezados
    sheetObject.appendRow([
      TextCellValue('Cámara'),
      TextCellValue('Tipo de Cámara'),
      TextCellValue('Dn(mm)'),
      TextCellValue('Pn(bar)'),
      TextCellValue('Medida Torquimetro(lbf*pie)'),
      TextCellValue('Valvula'),
      TextCellValue('Colada'),
      TextCellValue('Material'),
      TextCellValue('Recubrimiento B1(µm)'),
      TextCellValue('Recubrimiento B2(µm)'),
      TextCellValue('Observaciones'),
    ]);

    // Datos
    for (var row in data) {
      sheetObject.appendRow([
        TextCellValue(row['nombrecamara']),
        TextCellValue(row['tipodecamara']),
        TextCellValue(row['dn']),
        TextCellValue(row['pn']),
        TextCellValue(row['medidatorquimetro']),
        TextCellValue(row['valvula']),
        TextCellValue(row['colada']),
        TextCellValue(row['material']),
        TextCellValue(row['recubrimientoB1']),
        TextCellValue(row['recubrimientoB2']),
        TextCellValue(row['observaciones']),
      ]);
    }

    // Guardar el archivo
    var bytes = excel.encode();
    if (bytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/camaras_valvulas.xlsx');
      await file.writeAsBytes(bytes);

      // Compartir el archivo
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Cámaras y válvulas del tramo $tramo.nombre');
    } else {
      if (mounted) {
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
          title: const Text('Agregar Componente'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre del Componente'),
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
          title: const Text('Editar Componente'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre del Componente'),
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
            '¿Estás seguro de que quieres eliminar este componente?',
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
