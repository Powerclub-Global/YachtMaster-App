// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:get/get.dart';
// import 'package:yacht_master/localization/app_localization.dart';
// import 'package:yacht_master/resources/resources.dart';
// import 'package:yacht_master/src/base/search/model/services_model.dart';
// import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
// import 'package:yacht_master/utils/general_app_bar.dart';
//
// class ViewAllServiceImages extends StatefulWidget {
//   static String route="/viewAllServiceImages";
//   const ViewAllServiceImages({Key? key}) : super(key: key);
//
//   @override
//   _ViewAllServiceImagesState createState() => _ViewAllServiceImagesState();
// }
//
// class _ViewAllServiceImagesState extends State<ViewAllServiceImages> {
//   // List<ImageType>? images=[];
//   @override
//   Widget build(BuildContext context) {
//     var args=ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
//     images=args["images"];
//     return Scaffold(
//       backgroundColor: R.colors.black,
//       appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "all_images")??""),
//       body: Padding(
//         padding:  EdgeInsets.symmetric(horizontal: Get.width*.05),
//         child: Column(children: [
//           Expanded(
//             child: GridView.custom(
//               gridDelegate: SliverQuiltedGridDelegate(
//                 crossAxisCount: 4,
//                 mainAxisSpacing: 10,
//                 crossAxisSpacing: 10,
//                 repeatPattern: QuiltedGridRepeatPattern.inverted,
//                 pattern: [
//                   QuiltedGridTile(3, 2),
//                   QuiltedGridTile(2, 2),
//                   QuiltedGridTile(1, 2),
//                 ],
//               ),
//               childrenDelegate: SliverChildBuilderDelegate(
//                     (context, index) => ClipRRect(borderRadius: BorderRadius.circular(12),
//                   child:
//                   images?[index].isFile==true?
//                   Image.file(File(images?[index].image.path),fit: BoxFit.fill,):
//                   Image.asset(images?[index].image,fit: BoxFit.fill,),
//                 ),
//                 childCount: images?.length,
//               ),
//             ),
//           ),
//         ],),
//       ),
//     );
//   }
// }
