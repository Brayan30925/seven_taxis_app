import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seven_taxis_app/src/pages/client/map/client_map_controller.dart';
import '../../../widgets/buttom_app.dart';
class ClientMapPage extends StatefulWidget {
  const ClientMapPage({super.key});

  @override
  State<ClientMapPage> createState() => _ClientMapPageState();
}

class _ClientMapPageState extends State<ClientMapPage> {
 final ClientMapController _con = ClientMapController();
 final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('se ejecuto el dispose');
    _con.dispose();
  }



 @override
 Widget build(BuildContext context) {

   return Scaffold(
     key: _con.key,
     drawer: _drawer(),
     body: Stack(
       children: [
         _googleMapsWidget(),
         SafeArea(
           child: Column(
             children: [
               _buttonDrawer(),
               _cardGooglePlaces(),
               _buttonChangeTo(),
               _buttonCenterPosition(),
               Expanded(child: Container()),
               _buttonRequest()
             ],
           ),
         ),
         Align(
           alignment: Alignment.center,
           child: _iconMyLocation(),
         )
       ],
     ),
   );
 }
  Widget _iconMyLocation(){
    return Image.asset(
      'assets/img/my_location.png',
      width: 65,
      height: 65,
    );

  }
 Future<void> showAutocompleteDialog(BuildContext context, bool consu) async {
   return showDialog(
     context: context,
     builder: (BuildContext context) {
       return StatefulBuilder(
         builder: (BuildContext context, StateSetter setState) {
           return AlertDialog(
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(20),
             ),
             title: Text(
               'BUSCA EL LUGAR QUE DESEAS',
               style: TextStyle(
                 fontSize: 20,
                 fontWeight: FontWeight.bold,
                 color: Colors.black87,
               ),
               textAlign: TextAlign.center,
             ),
             content: Container(
               width: double.maxFinite,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: TextField(
                       controller: searchController,
                       decoration: InputDecoration(
                         hintText: 'Buscar...',
                         prefixIcon: Icon(Icons.search),
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10),
                         ),
                       ),
                       onChanged: (text) {
                         if (text.isNotEmpty) {
                           _con.showAutocomplete(text).then((_) {
                             setState(() {});
                           });
                         } else {
                           _con.clearPredictions();
                           setState(() {});
                         }
                       },
                     ),
                   ),
                   Expanded(
                     child: ListView.builder(
                       shrinkWrap: true,
                       itemCount: _con.predictions.length,
                       itemBuilder: (context, index) {
                         final prediction = _con.predictions[index];
                         return ListTile(
                           title: Text(prediction.fullText ?? ''),
                           subtitle: Text(prediction.secondaryText ?? ''),
                           onTap: () {
                             // Guarda el ID y el nombre del lugar seleccionado
                             final placeId = prediction.placeId;
                             final placeName = prediction.fullText;

                             // Cierra el diálogo y pasa tanto el ID como el nombre del lugar
                             Navigator.of(context).pop({
                               'id': placeId,
                               'name': placeName,
                             });
                           },
                         );
                       },
                     ),
                   ),
                 ],
               ),
             ),
             actions: <Widget>[
               TextButton(
                 onPressed: () {
                   searchController.clear();
                   _con.clearPredictions();
                   Navigator.of(context).pop();
                 },
                 child: Text(
                   'Cerrar',
                   style: TextStyle(
                     color: Colors.redAccent,
                   ),
                 ),
               ),
             ],
           );
         },
       );
     },
   ).then((result) {
     if (result != null) {
       final selectedPlaceId = result['id'];
       final selectedPlaceName = result['name'];

       print('Este es el ID del lugar seleccionado: $selectedPlaceId');
       print('Este es el nombre del lugar seleccionado: $selectedPlaceName');

       if (selectedPlaceId != null) {
         // Llamar al método buscarCoordenadas del controlador con el ID del lugar
         _con.buscarCoordenadas(selectedPlaceId, consu);

         // Almacenar el nombre del lugar seleccionado
         setState(() {
           if (consu) {
             _con.from = selectedPlaceName;
           } else {
             _con.to = selectedPlaceName;
           }
         });
       }
     }
   });
 }

// Widget de la tarjeta con el diseño de Google Places

  Widget _cardGooglePlaces() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoCardLocation(
                'Desde',
                _con.from ?? 'Lugar de recogida',
                    () async {
                  // Muestra el cuadro de diálogo para la ubicación de recogida

                  await showAutocompleteDialog(context,true);

                },
              ),
              SizedBox(height: 5),
              Divider(color: Colors.grey, height: 10),
              SizedBox(height: 5),
              _infoCardLocation(
                'Hasta',
                _con.to ?? 'Lugar de destino',
                    () async {
                  // Muestra el cuadro de diálogo para la ubicación de destino
                  await showAutocompleteDialog(context,false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


// Widget para mostrar la información de la ubicación
  Widget _infoCardLocation(String title, String value, GestureTapCallback function) {
    return GestureDetector(
      onTap: function,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey, fontSize: 10),
            textAlign: TextAlign.start,
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    _con.client?.username ?? 'Nombre no disponible',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  child: Text(
                    _con.client?.email ?? 'Email no disponible',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 2),
                CircleAvatar(
                  backgroundImage: _con.client?.image != null && _con.client!.image!.isNotEmpty
                      ? NetworkImage(_con.client!.image!) // Imagen de red si está disponible
                      : AssetImage('assets/img/profile.jpg') as ImageProvider, // Imagen predeterminada
                  radius: 40,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.amber,
            ),
          ),
          ListTile(
            title: Text('editar perfil'),
            trailing: Icon(Icons.edit),
            onTap: _con.goToEditPage,
          ),
          ListTile(
            title: Text('Historial de viajes'),
            trailing: Icon(Icons.timer),
            onTap: _con.goToHistoryPage,
          ),
          ListTile(
            title: Text('cerrar sesión'),
            trailing: Icon(Icons.power_settings_new),
            onTap: _con.signOut,
          )
        ],
      ),
    );
  }
  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.location_searching,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonChangeTo() {
    return GestureDetector(
      onTap: _con.changeFromTo,
      child: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.refresh,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonDrawer() {
    return  Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: Icon(Icons.menu, color: Colors.white,),
      ),
    );
    ;
  }

  Widget _buttonRequest() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        onPressed: _con.requestDriver,
        text: 'SOLICITAR',
        color: Colors.amber,
        textColor: Colors.black,
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      onCameraMove: (position){
        _con.initialPosition=position;
      },
      onCameraIdle: () async{
        await _con.setLocationDraggableInfo();
    }
    );
  }

  void refresh() {

      setState(() {});

  }

}
