import 'package:flutter/material.dart';
import 'database_helper.dart';

class ValvulasScreen extends StatefulWidget {
  final Camara camara;

  const ValvulasScreen({super.key, required this.camara});

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
      appBar: AppBar(
        title: Text('Válvulas de ${widget.camara.nombre}'),
      ),
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
                  title: Text(valvula.
nombre),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Válvula'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre de la Válvula'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                 if (nameController.text.isNotEmpty) {
                   _insertValvula(nameController.text);
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
        final TextEditingController nameController =
            TextEditingController(text: valvula.nombre);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Editar Válvula'),
              content: TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nombre de la Válvula'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),

                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      _updateValvula(Valvula(id: valvula.id, nombre: nameController.text, camaraId: valvula.camaraId));
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
          content: const Text('¿Estás seguro de que quieres eliminar esta válvula?'),
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
  void _insertValvula(String nombre) async {
    final valvula = Valvula(nombre: nombre, camaraId: widget.camara.id!);
    await _dbHelper.insertValvula(valvula);
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
}
