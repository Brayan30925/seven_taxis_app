import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/storage_provider.dart';
import 'package:seven_taxis_app/src/utils/my_progress_dialog.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;
import 'package:firebase_storage/firebase_storage.dart';


class DriverEditController {

  late BuildContext context;
  GlobalKey<ScaffoldState> key =  GlobalKey<ScaffoldState>();

  TextEditingController usernameController = TextEditingController();

  TextEditingController pin2Controller =  TextEditingController();
  TextEditingController pin3Controller =  TextEditingController();
  TextEditingController pin1Controller =  TextEditingController();
  TextEditingController pin4Controller =  TextEditingController();
  TextEditingController pin5Controller =  TextEditingController();
  TextEditingController pin6Controller =  TextEditingController();

  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late StorageProvider _storageProvider;
  late  ProgressDialog _progressDialog;

  File? imageFile; // Definir la variable imageFile
  PickedFile? pickedFile;

  Driver? driver;

  late Function refresh;

  Future<void> init (BuildContext context, Function refresh) async{
    this.context = context;
    this.refresh = refresh;
    _authProvider = MyAuthProvider();
    _driverProvider =  DriverProvider();
    _storageProvider =  StorageProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
    getUserInfo();
  }


  Future<void> getUserInfo() async {
    try {
      driver = await _driverProvider.getById(_authProvider.getUser()!.uid);
      if (driver != null) {
        usernameController.text = driver!.username ?? '';  // Verificación de nulo
        pin1Controller.text = driver?.plate?[0] ?? '';  // Verificación de que plate no sea null
        pin2Controller.text = driver?.plate?[1] ?? '';
        pin3Controller.text = driver?.plate?[2] ?? '';
        pin4Controller.text = driver?.plate?[4] ?? '';
        pin5Controller.text = driver?.plate?[5] ?? '';
        pin6Controller.text = driver?.plate?[6] ?? '';
        refresh();
      } else {
        utils.Snackbar.showSnackbar(context, 'Conductor no encontrado');
      }
    } catch (e) {
      utils.Snackbar.showSnackbar(context, 'Error al obtener la información del usuario: $e');
    }
  }

  void showAlertDialog() {
    Widget galleryButton = TextButton(
      onPressed: () async {
        await getImageFromGallery(ImageSource.gallery);
      },
      child: Text('Galería'),
    );

    Widget cameraButton = TextButton(
      onPressed: () async {
        await getImageFromGallery(ImageSource.camera);
      },
      child: Text('Cámara'),
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );
  }

  Future<void> getImageFromGallery(ImageSource imageSource) async {
    final picked = await ImagePicker().pickImage(source: imageSource);

    if (picked != null) {
      pickedFile = PickedFile(picked.path);  // Asigna a la variable de clase pickedFile
      imageFile = File(picked.path);  // Guarda la imagen como un archivo
      refresh();  // Llama a setState() para actualizar la interfaz
    } else {
      print('No seleccionó ninguna imagen');
    }
    // Asegúrate de cerrar el diálogo después de que se haya manejado la selección de imagen
    Navigator.of(context, rootNavigator: true).pop();
  }
  void update() async {
    String username = usernameController.text;

    String pin1 = pin1Controller.text.trim();
    String pin2 = pin2Controller.text.trim();
    String pin3 = pin3Controller.text.trim();
    String pin4 = pin4Controller.text.trim();
    String pin5 = pin5Controller.text.trim();
    String pin6 = pin6Controller.text.trim();

    String plate = '$pin1$pin2$pin3-$pin4$pin5$pin6';

    if (username.isEmpty || plate.isEmpty) {
      utils.Snackbar.showSnackbar(context, 'Debes ingresar todos los campos');
      return;
    }

   // _progressDialog.show();

    try {
      Map<String, dynamic> data = {
        'username': username,
        'plate': plate,
        'image': pickedFile == null ? driver?.image : await _uploadImage(),  // Verificar imagen
      };

      await _driverProvider.update(data, _authProvider.getUser()!.uid);
      utils.Snackbar.showSnackbar(context, 'Los datos se actualizaron');
    } catch (e) {
      utils.Snackbar.showSnackbar(context, 'Error al actualizar los datos: $e');
    } finally {
      _progressDialog.hide();
    }
  }
  Future<String?> _uploadImage() async {
    if (pickedFile != null) {
      TaskSnapshot snapshot = await _storageProvider.uploadFile(pickedFile!);
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

}