// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../utils/z_bot/zbot_toast.dart';



class WebFileModel {
  Uint8List? file;
  String? fileName;
  WebFileModel({
    this.file,
    this.fileName,
  });
}

class FilePickerServicesWeb {
  static List<WebFileModel?> tempTranscriptFiles = [];
  static List<WebFileModel>? transFiles = [];

  static Future uploadMultiFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['pdf', 'doc', 'png', 'jpg', 'jpeg']);

    if (result != null) {
      tempTranscriptFiles.clear();
      for (var element in result.files) {
        tempTranscriptFiles
            .add(WebFileModel(file: element.bytes, fileName: element.name));
      }
      if (transFiles!.length >= 3 || tempTranscriptFiles.length >= 3) {
        ZBotToast.showToastError(message: "Maximum three files are allowed");
      } else {
        for (var element in tempTranscriptFiles) {
          var tempSize = element!.file!.lengthInBytes;
          double sizeInMb = tempSize / (1024 * 1024);
          if (sizeInMb > 10) {
          } else {
            transFiles!.add(element);
          }
        }
        return true;
      }
    } else {
      return false;
    }
  }
}
