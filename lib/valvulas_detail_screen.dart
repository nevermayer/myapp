import 'package:flutter/material.dart';
import 'database_helper.dart';

class ValvulaDetailScreen extends StatelessWidget {
  final Valvula valvula;

  const ValvulaDetailScreen({super.key, required this.valvula});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de la valvula')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Column(
            children: [
            _buildDetailRow("Numero de camara:", valvula.nombre),
            _buildDetailRow("Dn(mm):", valvula.dn),
            _buildDetailRow("Pn(bar):", valvula.pn),
            _buildDetailRow("Medida Torquimetro(lbf*pie):", valvula.medidatorquimetro),
            _buildDetailRow("Válvula:", valvula.valvula),
            _buildDetailRow("Colada:", valvula.colada),
            _buildDetailRow("Material:", valvula.material),
            _buildDetailRow("Recubrimiento B1(µm):", valvula.recubrimientoB1),
            _buildDetailRow("Recubrimiento B2(µm):", valvula.recubrimientoB2),
            _buildDetailRow("Observaciones", valvula.observaciones),
            const SizedBox(height: 10),
            // Aquí puedes agregar más detalles de la válvula
          ],
            )
          ],          
        ),
      ),
    );
  }
}

Widget _buildDetailRow(String title, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 3),
        Text(value ?? " ", style: TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    ),
  );
}

