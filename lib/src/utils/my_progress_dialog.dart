import 'package:flutter/material.dart';
import 'package:progress_dialog2/progress_dialog2.dart';


class MyProgressDialog{
  static ProgressDialog createprogressDialog(BuildContext context, String text){
    ProgressDialog progressDialog = new ProgressDialog(
        context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
      showLogs: false
    );
    progressDialog.style(
        message: text,
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,

        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w600)
    );
    return progressDialog;

  }
}