//get user photo
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:async_foreach/async_foreach.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerServices {
  final picker = ImagePicker();
  List<XFile>? pickedFiles = [];

   getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      return image;
    } else {
      return null;
    }
  }

   getMultipleImages() async {
    List<XFile>? pictures = (await picker.pickMultiImage(imageQuality: 80));
    log("___________LEN:${pickedFiles?.length}");
    if (pictures!.isNotEmpty ) {
      pictures.forEach((element) {
        pickedFiles!.add(element);
      });
    }

    return pickedFiles;
  }

   uploadSingleImage(File images, {String bucketName="userProfile"}) async {
    log("__________________________IMAGE:${images}");
    String? image;
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(
          "$bucketName/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().toString()}");
      final TaskSnapshot snapshot = await  ref.putFile(images);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      image = downloadUrl;
    } on Exception catch (e) {
      // TODO
      log("____________________________ERRPR:${e}");
    }
    return image!;
  }

  Future<List<String>> uploadPostImages(List<XFile>? images,String bucketName) async {
    List<String> imageList = [];
    await images!.asyncForEach((value) async {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(
          "${bucketName}/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().toString()}");
      final TaskSnapshot snapshot = await ref.putFile(File(value.path));
      String imageUrl = await snapshot.ref.getDownloadURL();
      imageList.add(imageUrl.toString());
      log(imageUrl.toString());
    });
    return imageList;
  }

}
