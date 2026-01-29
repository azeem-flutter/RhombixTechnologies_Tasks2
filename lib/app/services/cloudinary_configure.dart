import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryConfig {
  static final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  static final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;
  static final arthubartwork = dotenv.env['CLOUDINARY_ARTWORK_FOLDER']!;
}
