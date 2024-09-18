import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seven_taxis_app/src/utils/colors.dart' as utils;
import 'package:seven_taxis_app/src/pages/driver/history_detail/driver_history_detail_controller.dart';

class DriverHistoryDetailPage extends StatefulWidget {
  @override
  _DriverHistoryDetailPageState createState() => _DriverHistoryDetailPageState();
}

class _DriverHistoryDetailPageState extends State<DriverHistoryDetailPage> {

  DriverHistoryDetailController _con =DriverHistoryDetailController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del historial'),),
      body: SingleChildScrollView(
        child: Column(
         children: [
           _bannerInfoDriver(),
           _listTileInfo('Lugar de recogida', _con.travelHistory?.from ?? '', Icons.location_on),
           _listTileInfo('Destino', _con.travelHistory?.to ?? '', Icons.location_searching),
           _listTileInfo('Mi calificacion', _con.travelHistory?.calificationClient?.toString() ?? '', Icons.star_border),
           _listTileInfo('Calificacion del conductor', _con.travelHistory?.calificationDriver?.toString() ?? '', Icons.star),
           _listTileInfo('Precio del viaje', '${_con.travelHistory?.price?.toString() ?? '0\$'} ', Icons.monetization_on_outlined),
         ],
        ),
      ),
    );
  }

  Widget _listTileInfo(String title, String value, IconData icon) {
    return ListTile(
      title: Text(
          title ?? ''
      ),
      subtitle: Text(value ?? ''),
      leading: Icon(icon),
    );
  }

  Widget _bannerInfoDriver() {
    return ClipPath(
      clipper: DiagonalPathClipperTwo(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.27,
        width: double.infinity,
        color: utils.Colors.seven,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            CircleAvatar(
              backgroundImage: _con.client?.image != null
                  ? NetworkImage(_con.client?.image ?? '')
                  : AssetImage('assets/img/profile.jpg'),
              radius: 50,
            ),
            SizedBox(height: 10),
            Text(
              _con.client?.username ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17
              ),
            )
          ],
        ),
      ),
    );
  }

  void refresh() {
    setState(() {

    });
  }
}
