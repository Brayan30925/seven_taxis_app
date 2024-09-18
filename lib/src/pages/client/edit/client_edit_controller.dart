import 'dart:io'; // Import necesario para manejar archivos (File)
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/utils/my_progress_dialog.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;

import '../../../providers/storage_provider.dart';

class ClientEditController {
  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  late Function refresh;
  TextEditingController usernameController = TextEditingController();

  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late ProgressDialog _progressDialog;
  late StorageProvider _storageProvider;
  File? imageFile; // Definir la variable imageFile
  PickedFile? pickedFile; // Esto es ahora una variable de clase, no una local
  Client? client;

  Future<void> init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    _storageProvider = StorageProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
    await getUserInfo();
  }

  Future<void> getUserInfo() async {
    try {
      client = await _clientProvider.getById(_authProvider.getUser()!.uid);
      if (client != null) {
        usernameController.text = client!.username ?? '';
        refresh();
      } else {
        utils.Snackbar.showSnackbar(context, 'Cliente no encontrado');
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

  Future<void> update() async {
    String username = usernameController.text;

    if (username.isEmpty) {
      utils.Snackbar.showSnackbar(context, 'Debes ingresar todos los campos');
      return;
    }

    //_progressDialog.show();

    try {
      String? imageUrl;
      if (pickedFile != null) {
        TaskSnapshot snapshot = await _storageProvider.uploadFile(pickedFile!);
        imageUrl = await snapshot.ref.getDownloadURL();
      } else {
        imageUrl = client?.image; // Usa la imagen existente del cliente si no se selecciona una nueva
      }

      Map<String, dynamic> data = {
        'image': imageUrl ?? 'null', // Usa 'null' si imageUrl es null
        'username': username,  // Actualiza también el nombre de usuario si es necesario
      };

      await _clientProvider.update(data, _authProvider.getUser()!.uid);
      utils.Snackbar.showSnackbar(context, 'Los datos se actualizaron correctamente');
    } catch (e) {
      utils.Snackbar.showSnackbar(context, 'Error al actualizar los datos: $e');
    }
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
}
