import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/utils/heights_widths.dart';

class DragDropImage extends StatefulWidget {
  final ValueChanged<DropImageModel> onDroppedFile;
  final String? descriptionText;

  const DragDropImage(
      {Key? key, required this.onDroppedFile, this.descriptionText})
      : super(key: key);

  @override
  State<DragDropImage> createState() => _DragDropImageState();
}

class _DragDropImageState extends State<DragDropImage> {
  late DropzoneViewController controller;
  bool isHover = false;

  DropImageModel dropImage = DropImageModel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          final events = await controller.pickFiles(mime: ['png', 'jpg', 'jpeg'], multiple: false);
          acceptFile(events.first);
        },
        child: Container(
          // width: 100.w,
          height: 22.h,
          padding: EdgeInsets.all(.5.w),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: R.colors.white,
            boxShadow: [
              BoxShadow(
                color: R.colors.black.withOpacity(.16),
                offset: const Offset(0, 0),
                blurRadius: 10,
                spreadRadius: 10,
              ),
            ]
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DropzoneView(
                onDrop: acceptFile,
                onCreated: ((controller) => this.controller = controller),
                onHover: () => setState(() {
                  isHover = true;
                }),
                onLeave: () => setState(() {
                  isHover = false;
                }),
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  h0P5,
                  Image.asset(R.images.selectPicture, scale: 3,),
                  h0P5,
                  Text(
                    'Select Picture',
                    style: R.textStyles.poppins(
                      fs: 16,
                      fw: FontWeight.w700,
                      color: R.colors.blackText,
                    ),
                  ),
                  h0P5,
                  Text(
                    'Supports: png, jpg, jpeg',
                    style: R.textStyles.poppins(
                      fs: 12,
                      fw: FontWeight.w700,
                      color: R.colors.lightGrey,
                    ),
                  ),
                  h0P5,

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future acceptFile(dynamic event) async {
    controller.getFileData(event);
    String url = (await controller.createFileUrl(event));
    String name = (await controller.getFilename(event));
    String mime = (await controller.getFileMIME(event));
    int byte = (await controller.getFileSize(event));
    Uint8List? fileData = (await controller.getFileData(event));

    dropImage = DropImageModel(url: url, name: name, mime: mime, byte: byte, fileData: fileData);
    widget.onDroppedFile(dropImage);
    isHover = false;
  }
}

class DropImageModel {
  String? url;
  String? name;
  String? mime;
  Uint8List? fileData;
  int? byte;

  DropImageModel({this.url, this.name, this.mime, this.fileData, this.byte});
}
