import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import 'package:image_picker/image_picker.dart';

class ValvulasScreen extends StatefulWidget {
  final Camara camara;
  final Tramo tramo;

  //const ValvulasScreen({super.key, required this.camara});
  const ValvulasScreen({Key? key, required this.camara, required this.tramo})
    : super(key: key);
  @override
  ValvulasScreenState createState() => ValvulasScreenState();
}

class ValvulasScreenState extends State<ValvulasScreen> {
  late Future<List<Valvula>> _valvulas;
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _refreshValvulas();
  }

  void _refreshValvulas() {
    setState(() {
      _valvulas = _dbHelper.getValvulas(widget.camara.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Válvulas de ${widget.camara.nombre}')),
      body: FutureBuilder<List<Valvula>>(
        future: _valvulas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final valvulas = snapshot.data!;
            return ListView.builder(
              itemCount: valvulas.length,
              itemBuilder: (context, index) {
                final valvula = valvulas[index];
                return ListTile(
                  title: Text(valvula.nombre),
                  subtitle: Text(
                    'DN: ${valvula.dn ?? ''}, PN: ${valvula.pn ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () => _pickimagefromcamera(valvula),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(valvula),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(valvula.id!),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay válvulas'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dnController = TextEditingController();
    final TextEditingController pnController = TextEditingController();
    final TextEditingController medidatorquimetroController =
        TextEditingController();
    final TextEditingController valvulaController = TextEditingController();
    final TextEditingController coladaController = TextEditingController();
    final TextEditingController materialController = TextEditingController();
    final TextEditingController recubrimientoB1Controller =
        TextEditingController();
    final TextEditingController recubrimientoB2Controller =
        TextEditingController();
    final TextEditingController observacionesController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Válvula'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la Válvula',
                  ),
                ),
                TextField(
                  controller: dnController,
                  decoration: const InputDecoration(hintText: 'DN'),
                ),
                TextField(
                  controller: pnController,
                  decoration: const InputDecoration(hintText: 'PN'),
                ),
                TextField(
                  controller: medidatorquimetroController,
                  decoration: const InputDecoration(
                    hintText: 'Medida Torquímetro',
                  ),
                ),
                TextField(
                  controller: valvulaController,
                  decoration: const InputDecoration(hintText: 'Válvula'),
                ),
                TextField(
                  controller: coladaController,
                  decoration: const InputDecoration(hintText: 'Colada'),
                ),
                TextField(
                  controller: materialController,
                  decoration: const InputDecoration(hintText: 'Material'),
                ),
                TextField(
                  controller: recubrimientoB1Controller,
                  decoration: const InputDecoration(
                    hintText: 'Recubrimiento B1',
                  ),
                ),
                TextField(
                  controller: recubrimientoB2Controller,
                  decoration: const InputDecoration(
                    hintText: 'Recubrimiento B2',
                  ),
                ),
                TextField(
                  controller: observacionesController,
                  decoration: const InputDecoration(hintText: 'Observaciones'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _insertValvula(
                    nameController.text,
                    dnController.text,
                    pnController.text,
                    medidatorquimetroController.text,
                    valvulaController.text,
                    coladaController.text,
                    materialController.text,
                    recubrimientoB1Controller.text,
                    recubrimientoB2Controller.text,
                    observacionesController.text,
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

  void _showEditDialog(Valvula valvula) {
    final TextEditingController nameController = TextEditingController(
      text: valvula.nombre,
    );
    final TextEditingController dnController = TextEditingController(
      text: valvula.dn,
    );
    final TextEditingController pnController = TextEditingController(
      text: valvula.pn,
    );
    final TextEditingController medidatorquimetroController =
        TextEditingController(text: valvula.medidatorquimetro);
    final TextEditingController valvulaController = TextEditingController(
      text: valvula.valvula,
    );
    final TextEditingController coladaController = TextEditingController(
      text: valvula.colada,
    );
    final TextEditingController materialController = TextEditingController(
      text: valvula.material,
    );
    final TextEditingController recubrimientoB1Controller =
        TextEditingController(text: valvula.recubrimientoB1);
    final TextEditingController recubrimientoB2Controller =
        TextEditingController(text: valvula.recubrimientoB2);
    final TextEditingController observacionesController = TextEditingController(
      text: valvula.observaciones,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Válvula'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la Válvula',
                  ),
                ),
                TextField(
                  controller: dnController,
                  decoration: const InputDecoration(hintText: 'DN'),
                ),
                TextField(
                  controller: pnController,
                  decoration: const InputDecoration(hintText: 'PN'),
                ),
                TextField(
                  controller: medidatorquimetroController,
                  decoration: const InputDecoration(
                    hintText: 'Medida Torquímetro',
                  ),
                ),
                TextField(
                  controller: valvulaController,
                  decoration: const InputDecoration(hintText: 'Válvula'),
                ),
                TextField(
                  controller: coladaController,
                  decoration: const InputDecoration(hintText: 'Colada'),
                ),
                TextField(
                  controller: materialController,
                  decoration: const InputDecoration(hintText: 'Material'),
                ),
                TextField(
                  controller: recubrimientoB1Controller,
                  decoration: const InputDecoration(
                    hintText: 'Recubrimiento B1',
                  ),
                ),
                TextField(
                  controller: recubrimientoB2Controller,
                  decoration: const InputDecoration(
                    hintText: 'Recubrimiento B2',
                  ),
                ),
                TextField(
                  controller: observacionesController,
                  decoration: const InputDecoration(hintText: 'Observaciones'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _updateValvula(
                    Valvula(
                      id: valvula.id,
                      nombre: nameController.text,
                      camaraId: valvula.camaraId,
                      dn: dnController.text,
                      pn: pnController.text,
                      medidatorquimetro: medidatorquimetroController.text,
                      valvula: valvulaController.text,
                      colada: coladaController.text,
                      material: materialController.text,
                      recubrimientoB1: recubrimientoB1Controller.text,
                      recubrimientoB2: recubrimientoB2Controller.text,
                      observaciones: observacionesController.text,
                    ),
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
          title: const Text('Eliminar Válvula'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta válvula?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteValvula(id);
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _insertValvula(
    String nombre,
    String dn,
    String pn,
    String medidatorquimetro,
    String valvula,
    String colada,
    String material,
    String recubrimientoB1,
    String recubrimientoB2,
    String observaciones,
  ) async {
    final valvulaa = Valvula(
      nombre: nombre,
      camaraId: widget.camara.id!,
      dn: dn,
      pn: pn,
      medidatorquimetro: medidatorquimetro,
      valvula: valvula,
      colada: colada,
      material: material,
      recubrimientoB1: recubrimientoB1,
      recubrimientoB2: recubrimientoB2,
      observaciones: observaciones,
    );
    await _dbHelper.insertValvula(valvulaa);
    _refreshValvulas();
  }

  void _updateValvula(Valvula valvula) async {
    await _dbHelper.updateValvula(valvula);
    _refreshValvulas();
  }

  void _deleteValvula(int id) async {
    await _dbHelper.deleteValvula(id);
    _refreshValvulas();
  }

  Future _pickimagefromcamera(Valvula valvula) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      try {
        // Obtener la carpeta de almacenamiento interno de la aplicación
        final directory = await getApplicationDocumentsDirectory();
        // Formato del nombre de archivo
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
        final fileName =
            '${widget.tramo.nombre}_${widget.camara.nombre}_${valvula.nombre}_$formattedDate.jpg';
        final String newPath = '${directory.path}/$fileName';
        // Mover la imagen a la carpeta interna de la app
           final File savedImage = await File(pickedFile.path).copy(newPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Foto guardada en: ${savedImage.path}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar la foto: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se tomó ninguna foto.')),
        );
      }
    }
  }
}
