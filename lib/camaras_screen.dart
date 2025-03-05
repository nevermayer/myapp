import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'valvulas_screen.dart';

class CamarasScreen extends StatefulWidget {
  final Tramo tramo;

  const CamarasScreen({super.key, required this.tramo});

  @override
  CamarasScreenState createState() => CamarasScreenState();
}

class CamarasScreenState extends State<CamarasScreen> {
  late Future<List<Camara>> _camaras;
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _refreshCamaras();
  }

  void _refreshCamaras() {
    setState(() {
      _camaras = _dbHelper.getCamaras(widget.tramo.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cámaras de ${widget.tramo.nombre}'),
      ),
      body: FutureBuilder<List<Camara>>(
        future: _camaras,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final camaras = snapshot.data!;
            return ListView.builder(
              itemCount: camaras.length,
              itemBuilder: (context, index) {
                final camara = camaras[index];
                return ListTile(
                  title: Text(camara.nombre),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ValvulasScreen(camara: camara),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(camara),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(camara.id!),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay cámaras'));
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Cámara'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre de la Cámara'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _insertCamara(nameController.text);
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

  void _showEditDialog(Camara camara) {
    final TextEditingController nameController =
        TextEditingController(text: camara.nombre);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Cámara'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre de la Cámara'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _updateCamara(Camara(id: camara.id, nombre: nameController.text, tramoId: camara.tramoId));
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
          title: const Text('Eliminar Cámara'),
          content: const Text('¿Estás seguro de que quieres eliminar esta cámara?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteCamara(id);
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _insertCamara(String nombre) async {
    final camara = Camara(nombre: nombre, tramoId: widget.tramo.id!);
    await _dbHelper.insertCamara(camara);
    _refreshCamaras();
  }

  void _updateCamara(Camara camara) async {
    await _dbHelper.updateCamara(camara);
    _refreshCamaras();
  }

  void _deleteCamara(int id) async {
    await _dbHelper.deleteCamara(id);
    _refreshCamaras();
  }
}
