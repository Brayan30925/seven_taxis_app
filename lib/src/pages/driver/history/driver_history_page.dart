import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:seven_taxis_app/src/models/TravelHistory.dart';
import 'package:seven_taxis_app/src/pages/client/history/client_history_controller.dart';

import '../../../utils/relative_time_util.dart';

class ClientHistoryPage extends StatefulWidget {
  @override
  _ClientHistoryPageState createState() => _ClientHistoryPageState();
}

class _ClientHistoryPageState extends State<ClientHistoryPage> {
  ClientHistoryController _con = ClientHistoryController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      appBar: AppBar(
        title: Text('Historial de viajes'),
      ),
      body: FutureBuilder<List<TravelHistory>>(
        future: _con.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Muestra un indicador de carga mientras espera
          } else if (snapshot.hasError) {
            return Center(child: Text('Ocurrió un error: ${snapshot.error}')); // Manejo de errores
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay viajes en el historial.')); // Si no hay datos
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                TravelHistory travel = snapshot.data![index];
                return _cardHistoryInfo(
                  travel.from ?? '',
                  travel.to ?? '',
                  travel.nameDriver ?? 'nombre conductor', // Este campo lo puedes reemplazar con el nombre real si lo tienes
                  travel.price?.toString() ?? '0',
                  travel.calificationDriver?.toString() ?? 'Sin calificación',
                  RelativeTimeUtil.getRelativeTime(travel.timestamp ?? 0),
                  travel.id ?? '',

                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _cardHistoryInfo(
      String from,
      String to,
      String name,
      String price,
      String calification,
      String timestamp,
      String idTravelHistory
      ) {
    return GestureDetector(
      onTap:(){ _con.goToDetailHistory(idTravelHistory);
        },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 5),
                Icon(Icons.drive_eta),
                SizedBox(width: 5),
                Text(
                  'Conductor: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            _buildInfoRow(Icons.location_on, 'Recoger en:', from),
            SizedBox(height: 5),
            _buildInfoRow(Icons.location_searching, 'Destino:', to),
            SizedBox(height: 5),
            _buildInfoRow(Icons.monetization_on, 'Precio:', price),
            SizedBox(height: 5),
            _buildInfoRow(Icons.format_list_numbered, 'Calificación:', calification),
            SizedBox(height: 5),
            _buildInfoRow(Icons.timer, 'Hace:', timestamp),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String content) {
    return Row(
      children: [
        SizedBox(width: 5),
        Icon(icon),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            content,
            maxLines: 2,  // Puedes ajustar según tus necesidades
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
      ],
    );
  }



  void refresh() {
    setState(() {});
  }
}
