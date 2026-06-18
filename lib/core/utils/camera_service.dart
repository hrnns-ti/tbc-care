import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takeMedicationPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        return photo.path;
      }
    } catch (e) {
      print("Error mengambil foto: $e");
    }
    return null;
  }
}