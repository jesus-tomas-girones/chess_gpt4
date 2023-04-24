import 'package:flutter/material.dart';

void showMyDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),],);},);
}


Future<T?> showLoadingDialog<T>({
  required BuildContext context,
  required String message,
  VoidCallback? onCancel,
}) async {
  return showDialog<T>(
    context: context,
    barrierDismissible: false, // Usuario no puede cerrar el diálogo tocando fuera de él
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false, // Usuario no puede cerrar el diálogo usando el botón de retroceso
        child: AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20), // Espacio entre el indicador y el texto
              Text(message),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) { onCancel(); }
              },
              child: Text('CANCELAR'),
            ),
          ],
        ),
      );
    },
  );
}
