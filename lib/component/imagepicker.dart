import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Imagepicker {
  
  final ImagePicker _picker = ImagePicker();
  Future<File?> pickImage({bool fromGallery = true}) async {
    final PickedFile = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera);

    if (PickedFile != null) {
      return File(PickedFile.path);
    }
    return null;
  }
}
