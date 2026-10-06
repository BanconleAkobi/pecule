import 'package:flutter/material.dart';

const _toastDuration = Duration(milliseconds: 2200);

/// Confirmation brève en bas d'écran : « Ajouté à tes favoris ».
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: _toastDuration,
      ),
    );
}
