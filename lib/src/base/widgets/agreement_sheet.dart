import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';

import 'package:sizer/sizer.dart';
import '../../../appwrite.dart';
import '../../../localization/app_localization.dart';
import '../../../resources/decorations.dart';
import '../../../resources/resources.dart';
import '../../../utils/heights_widths.dart';
import '../../../utils/helper.dart';

class AgreementBottomSheet extends StatefulWidget {
  bool isBooking;
  Function()? yesCallBack;
  AgreementBottomSheet({this.yesCallBack, required this.isBooking});

  @override
  _AgreementBottomSheetState createState() => _AgreementBottomSheetState();
}

class _AgreementBottomSheetState extends State<AgreementBottomSheet> {
  DateTime now = DateTime.now();
  bool value = false;
  String hostingTitle = '''CONTRACTUAL AGREEMENT''';
  String bookingTitle =
      '''GENERAL RELEASE OF LIABILITY, WAIVER OF CLAIMS, EXPRESS ASSUMPTION OF RISKS, AND HOLD HARMLESS AGREEMENT: YACHTMASTER APP LLC''';
  @override
  Widget build(BuildContext context) {
    String bookingText =
        '''In consideration of booking a boat or charter via the Yachtmaster application (“YACHTMASTER APP LLC” or “Booking Company”), and engage in activities on, the boat or charter, I hereby agree as follows: I, ${appwrite.user.name}, for myself and my estate, heirs, administrators, executors, and assigns, hereby release, discharge and hold harmless YACHTMASTER APP LLC (the “Booking Company”) and their officers, directors, employees, representatives, agents, and volunteers (collectively, the “Releasees”), for, from and against any and all liability and responsibility whatsoever, however caused, for any and all damages, claims, or causes of action that I, my estate, heirs, administrators, executors, or assigns may have for any loss, personal injury, death, or property damage arising out of, connected with, or in any manner pertaining to my activities on the property, WHETHER CAUSED BY THE NEGLIGENCE OF THE RELEASEES or otherwise. I fully understand that there are potential risks and hazards associated with entering and engaging in activities on the boat or vessel, including, but not limited to, possible injury or loss of life. I further understand that this is a third-party company or Booking Company used to connect me with the owner of the boat or charter that I will be interacting with, or coming into contact with, persons that are not associated with or under the control or supervision of the Releasees. Despite the potential risks and hazards associated with my activities on the boat or charter, I wish to proceed, and freely accept and assume all risks and hazards that may arise from my activities on the boat or charter, WHETHER CAUSED BY THE NEGLIGENCE OF RELEASEES or otherwise. I acknowledge that my activities on the boat or charter are purely optional, that I requested this boat or charter, and that I am freely and voluntarily participating in the activities. I agree to comply with all laws, orders and regulations of any governmental authorities having jurisdiction over the subject property, including, without limitation, any law, statute, rule, regulation, ordinance, code, or policy now or hereafter in effect relating to the rent of the boat or charter. Further, I agree to take all reasonable steps to protect the boat or charter from any damage other than ordinary wear and tear caused by my activities thereon. Lastly, I agree to defend, indemnify, and hold harmless the Releasees from any judgment, settlement, loss, liability, damage, or costs, including court costs and attorney fees for both the trial and appellate levels, that Releasees may incur as a proximate result of any negligent or deliberate act or omission on my part during my activities on the boat or charter. In signing this agreement, I acknowledge and represent that I have read and understand it; that I sign it voluntarily and for full and adequate consideration, fully intending to be bound by the same; and that I am at least eighteen (18) years of age and fully competent. I HAVE READ THIS AGREEMENT, UNDERSTAND THAT I AM GIVING UP SUBSTANTIAL RIGHTS BY SIGNING IT, AND VOLUNTARILY AGREE TO BE BOUND BY IT.''';
    String hostingText =
        '''THIS AGREEMENT (the “Agreement) is made as of the ${now.day} day of ${DateFormat.MMMM().format(now)} ${now.year}, by and between YACHTMASTER APP LLC, a (LLC formed in the State of Florida) (the “First Party”), and ${appwrite.user.name} (the “Second Party,” and collectively, the “Parties”). WHEREAS the First Party is engaged in creating a rental boating marketplace application to connect Second Party with customers and consumers for boat and charter rentals and; WHEREAS the Second Party is engaged in providing boats and charting rentals available to the customers and consumer, providing accuracy of boat photos and details of the boats posted, and providing the services at agreed upon times and dates, enter into this Agreement; WHEREAS the Second Party will represent and be affiliated with First Party by virtue of soliciting and originating customers and consumers via a rental boating marketplace application created by First party and by marketing for First Party, and will paid a twenty percent (20%) fee for their efforts. NOW THEREFORE BE IT RESOLVED, in consideration of the mutual covenants, promises, warranties and other good and valuable consideration set forth herein, the Parties agree as follows: 1. Formation. The Agreement shall be considered in all respects a joint venture between the Parties, and nothing in this Agreement shall be construed to create a partnership or any other fiduciary relationship between the Parties. 2. Purpose. The Joint Venture shall be formed for the purpose of connecting potential customers and consumers for the Second Party, and for this, the First Party will be paid a twenty percent (20%) fee on the money generated from their services and efforts by the client/customer. 3. Contributions. The Parties shall each make an initial contribution to the Joint Venture according to the following terms: i. First Party’s Contribution: Contributions will be in the form of marketing new potential customers and consumers via a boat marketplace application. ii. Second Party’s Contribution: Contributions will be in the form of providing certain boats and/or charters, providing accuracy of boat photos and details of boats posted, providing services at agreed upon times and dates. Second Party will be responsible for compliance with all state laws and regulations for boat charters and providing captains for charters. 4. Management. The Agreement shall be managed according to the following terms: Both Parties will review progress consistently. 5. Exclusivity Agreement. Work that is generated from First Party shall be given to Second Party. From this Second Party will pay a twenty percent (20%) fee for each customer and consumer. 6. Term. This Agreement shall remain in full force and effect, for a period of three (3) years from the date of this Agreement (the “Initial Term”). Upon the expiration of the Initial Term, the Parties shall decide on how to continue with the applicable terms of this Joint Venture. 7. Confidentiality. Any information pertaining to either Party’s business to which the other Party is exposed as a result of the relationship contemplated by this Agreement shall be considered to be “Confidential Information.” Neither Party may disclose any Confidential Information to any person or entity, except as required by law, without the express written consent of the affected Party. 8. Further Actions. The Parties hereby agree to execute any further documents and to take any necessary actions to complete the formation of the Joint Venture. 9. Assignment. Neither Party may assign or transfer their respective rights or obligations under this Agreement without prior written consent from the other Party. Except that if the assignment or transfer is pursuant to a sale of all or substantially all of a Party’s assets, or is pursuant to a sale of a Party’s business, then no consent shall be required. In the event that an assignment or transfer is made pursuant to either a sale of all or substantially all of the Party’s assets or pursuant to a sale of the business, then written notice must be given of such transfer within 10 days of such assignment or transfer. 10. Governing Law/Jurisdiction. This Agreement shall be governed by and construed and enforced in accordance with the laws of the State of Florida (without regard to any conflict of laws principles). All actions, suits and proceedings arising out of or in connection with this Agreement shall be brought in the courts of the State of Florida, Broward County, which shall be the exclusive forum therefor. The parties hereto hereby irrevocably submit to the in personam jurisdiction and process of the courts in the State of Florida, Broward County, and further agree that service by certified mail to their business addresses shall constitute sufficient service of process. 11. Severability. The invalidity or unenforceability of any particular provision of this Agreement in whole or in part shall not affect any other provision hereof, and this Agreement and each and every provision hereof shall be construed in all respects as though such invalid or unenforceable provision were omitted. 12. Counterparts/Facsimile. This Agreement may be executed in two or more counterparts, each of which shall be deemed to be an original but all of which shall constitute one and the same agreement. This Agreement shall become effective when each party hereto shall have received counterparts thereof signed by the other party hereto. A facsimile signature on this Agreement is as valid as an original signature. 13. Legal Fees. In any litigation, arbitration, or other proceeding by which one party either seeks to enforce its rights under this Agreement (whether in contract, tort, or both) or seeks a declaration of any rights or obligations under this Agreement, the prevailing party shall be awarded its reasonable attorney fees, and costs and expenses incurred. 14. Notice. Any notice required or otherwise given pursuant to this Agreement shall be in writing and mailed certified return receipt requested, postage prepaid, or delivered by overnight delivery service, addressed as follows: If to First Party: Danielle Willis If to Second Party: ${appwrite.user.name} 15. Headings. The headings for section herein are for convenience only and shall not affect the meaning of the provisions of this Agreement. 16. Entire Agreement. This Agreement constitutes the entire agreement between First Party and Second Party, and supersedes any prior understanding or representation of any kind preceding the date of this Agreement. There are no other promises, conditions, understandings or other agreements, whether oral or written, relating to the subject matter of this Agreement.''';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Get.width * .07),
      decoration: BoxDecoration(
        color: R.colors.black,
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          h1,
          Icon(Icons.warning, color: R.colors.whiteColor, size: 30.sp),
          h2,
          Text(
            widget.isBooking ? bookingTitle : hostingTitle,
            textAlign: TextAlign.center,
            style: R.textStyle
                .helveticaBold()
                .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
          ),
          h1,
          SizedBox(
            height: 190,
            width: Get.width * .65,
            child: SingleChildScrollView(
              child: Text(
                widget.isBooking ? bookingText : hostingText,
                textAlign: TextAlign.center,
                style: R.textStyle.helveticaBold().copyWith(
                    color: R.colors.whiteColor, fontSize: 9.sp, height: 1.5),
              ),
            ),
          ),
          h1,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "I agree to all terms",
                style: R.textStyle.helveticaBold().copyWith(
                    color: R.colors.whiteColor, fontSize: 10.sp, height: 1.5),
              ),
              Checkbox(
                value: this.value,
                checkColor: R.colors.black,
                activeColor: R.colors.golden,
                onChanged: (value) {
                  setState(() {
                    this.value = value!;
                  });
                },
              ),
            ],
          ),
          h2,
          GestureDetector(
            onTap: value
                ? widget.yesCallBack
                : () {
                    Helper.inSnackBar(
                        'Error',
                        "Please agree to the Terms and Conditions",
                        R.colors.themeMud);
                    ;
                  },
            child: Container(
              height: Get.height * .055,
              width: Get.width * .8,
              margin: EdgeInsets.only(bottom: Get.height * .015),
              decoration: AppDecorations.gradientButton(radius: 30),
              child: Center(
                child: Text(
                  "Agree and Proceed",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
