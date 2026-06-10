import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> seleccionarYSubirImagen({
    required String carpeta,
    required String nombreArchivo,
  }) async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (imagen == null) return null;

      final file = File(imagen.path);
      final ref = _storage.ref().child('$carpeta/$nombreArchivo.jpg');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error subiendo imagen: $e');
      return null;
    }
  }
}