import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/settings/view/sign_w9_screen.dart';

class FillW9Screen extends StatelessWidget {
  const FillW9Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final PdfViewerController controller = PdfViewerController();
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: R.colors.themeMud,
          foregroundColor: R.colors.black,
          onPressed: () async {
            List<int> bytes = await controller.saveDocument(
              flattenOption: PdfFlattenOption.formFields,
            );
            Get.to(SignW9Screen(pdfBytes: bytes));
          },
          child: const Icon(Icons.arrow_forward),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SfPdfViewer.network(
          'https://www.irs.gov/pub/irs-pdf/fw9.pdf',
          controller: controller,
        ),
      ),
    );
  }
}
