import 'package:image_picker/image_picker.dart';

class MediaService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      return file?.path;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }
}
