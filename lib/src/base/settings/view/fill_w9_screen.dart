
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/settings/view/sign_w9_screen.dart';
import 'package:yacht_master/utils/helper.dart';

class FillW9Screen extends StatelessWidget {
  const FillW9Screen({super.key});

  bool formValidator(List<PdfFormField> formFields) {
    for (final PdfFormField formField in formFields) {
      if (formField is PdfTextFormField) {
        if (formField.name == 'topmostSubform[0].Page1[0].f1_01[0]') {
          if (formField.text.isEmpty || formField.text == ' ') {
            Helper.inSnackBar(
              'Error',
              "Please fill in a name",
              R.colors.themeMud,
            );
            return false;
          }
        } else if (formField.name ==
                'topmostSubform[0].Page1[0].Address_ReadOrder[0].f1_07[0]' ||
            formField.name ==
                'topmostSubform[0].Page1[0].Address_ReadOrder[0].f1_08[0]') {
          if (formField.text.isEmpty || formField.text == " ") {
            Helper.inSnackBar(
              'Error',
              "Please fill in an address",
              R.colors.themeMud,
            );
            return false;
          }
        } else if (formField.name == 'topmostSubform[0].Page1[0].f1_11[0]') {
          if (formField.text.isEmpty ||
              formField.text.length < 3 ||
              formField.text.contains(' ')) {
            Helper.inSnackBar(
              'Error',
              "Please fill in your complete Social Security Number",
              R.colors.themeMud,
            );
            return false;
          }
        } else if (formField.name == 'topmostSubform[0].Page1[0].f1_12[0]') {
          if (formField.text.isEmpty ||
              formField.text.length < 2 ||
              formField.text.contains(' ')) {
            Helper.inSnackBar(
              'Error',
              "Please fill in your complete Social Security Number",
              R.colors.themeMud,
            );
            return false;
          }
        } else if (formField.name == 'topmostSubform[0].Page1[0].f1_13[0]') {
          if (formField.text.isEmpty ||
              formField.text.length < 4 ||
              formField.text.contains(' ')) {
            Helper.inSnackBar(
              'Error',
              "Please fill in your complete Social Security Number",
              R.colors.themeMud,
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final PdfViewerController controller = PdfViewerController();
    List<PdfFormField>? formFields;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: R.colors.themeMud,
          foregroundColor: R.colors.black,
          onPressed: () async {
            if (formValidator(formFields!)) {
              List<int> bytes = await controller.saveDocument(
                flattenOption: PdfFlattenOption.formFields,
              );
              Get.to(SignW9Screen(pdfBytes: bytes));
            }
          },
          child: const Icon(Icons.arrow_forward),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SfPdfViewer.network(
          'https://www.irs.gov/pub/irs-pdf/fw9.pdf',
          controller: controller,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            formFields = controller.getFormFields();
          },
        ),
      ),
    );
  }
}
