import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class TestImagePickerPlatform extends ImagePickerPlatform {
  TestImagePickerPlatform({String? imagePath}) : _imagePath = imagePath;

  String? _imagePath;

  void setImagePath(String? imagePath) {
    _imagePath = imagePath;
  }

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    if (_imagePath == null) {
      return null;
    }

    return XFile(_imagePath!);
  }

  @override
  Future<List<XFile>> getMedia({required MediaOptions options}) async {
    if (_imagePath == null) {
      return <XFile>[];
    }

    return <XFile>[XFile(_imagePath!)];
  }
}
