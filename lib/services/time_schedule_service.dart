
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:yacht_master/utils/date_utils.dart';
DateTime now=DateTime.now();


///FUNCTIONS: EXTENSION METHODS FOR DATETIME DATATYPE
extension TimeScheduleServices on DateTime{
  ///INPUT: A DATE
  ///OUTPUT:NUMBER OF DAYS
  ///FUNCTIONS:IT WILL INPUT A DATE AND WILL FETCH THE MONTH OF THAT DATE AND WILL OUTPUT THE NUMBER OF DAYS IN THAT MONTH
  List<String> allDaysOfMonth() {
    final daysCount = DateUtil().daysInMonth(month, year);
    List<String> days = [];
    for (int i = 1; i < daysCount + 1; i++) {
      days.add(DateFormat("MMMM dd,yyyy")
          .format(DateTime(year, month, i)));
    }
    return days;
  }
 ///INPUT:START & END DATES
  ///OUTPUT:LIST OF DATES
  ///FUNCTIONS:IT WILL TAKE TWO DATES AND WILL CALCULATE THE LIST OF DATES BETWEEN START AND END DATES
  List<DateTime> getDays(
     DateTime start,
     DateTime end
  ) {
    final days = end.difference(start).inDays;

    return [
      for (int i = 0; i <= days; i++)
        start.add(Duration(days: i))
    ];
  }
  ///INPUT: DATE
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE A DATE AND WILL FORMAT THAT DATE LIKE Fri 05:00 am
  String formateDateChatNow() {
    return DateFormat("EEEE hh:mm a").format(this);
  }
  ///INPUT: DATE
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE A DATE AND WILL FORMAT THAT DATE LIKE June 28,2022
  String formateDateMDY() {
    return DateFormat("MMM dd,yyyy").format(this);
  }
}

///FUNCTIONS: EXTENSION METHODS FOR STRING DATATYPE
extension FormatingServices on String{
  ///INPUT: STRING
  ///OUTPUT: INT
  ///FUNCTIONS: IT WILL TAKE TIME IN FORM OF STRING WILL OUTPUT/SPLIT THE HOUR AS INT
  int splitHour()
  {
    return int.parse(this.split(":").first);
  }
  ///INPUT: STRING
  ///OUTPUT: INT
  ///FUNCTIONS: IT WILL TAKE TIME IN FORM OF STRING WILL OUTPUT/SPLIT THE MINT AS INT
  int splitMint()
  {
    return int.parse(this.split(":").last.split(" ").first);
  }
  ///INPUT: STRING
  ///OUTPUT: DATETIME
  ///FUNCTIONS: IT WILL TAKE TIME IN FORM OF STRING WILL CONVERT IT TO DATETIME
  DateTime? convertStringToDateTime(){
    DateTime? _dateTime;
    try{
      _dateTime =  DateFormat("hh:mm").parse(this);
    }catch(e){}
    return _dateTime;
  }
  ///INPUT: STRING
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE STRING AND WILL OUTPUT THE HOUR AND MINT AS STRING
  String formateHM(){
    return formatDate(
        this.convertStringToDateTime()!, [hh, ':', nn, ' ', am]);
  }

  ///INPUT: STRING
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE STRING AND WILL OUTPUT/FORMAT THE STRING LIKE JUNE 22
  String formateDateMD() {
    return DateFormat("MMM dd").format(DateFormat("dd-mm-yyyy").parse(this));
  }
  ///INPUT: STRING
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE STRING AND WILL OUTPUT/FORMAT THE STRING LIKE 22 JUNE
  String formateDateDM() {
    return DateFormat("dd MMM").format(DateFormat("dd-mm-yyyy").parse(this));
  }
  ///INPUT: STRING
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE STRING AND WILL OUTPUT/FORMAT THE STRING LIKE 22 JUNE 2022
  String formateDateDMY() {
    return DateFormat("dd MMM yyyy").format(DateFormat("dd-mm-yyyy").parse(this));
  }
  ///INPUT: STRING
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE EMAIL STRING AND WILL OUTPUT/OBSCURE EMAIL LIKE ka********@gmail.com
  String obsecureEmail()
  {
    return "${this.split("@").first.substring(0,2)}${this.split("@").first.substring(2).replaceAll(RegExp(r'[a-zA-Z0-9@]'), "*")}@${this.split("@").last}";
  }
  ///INPUT: STRING
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE CARD NUMBER STRING AND WILL OUTPUT/OBSCURE CARD NUMBER LIKE **************12
  String obsecureCardNum()
  {
    return this.replaceAll(RegExp(r'\d(?!\d{0,1}$)'), "*");
  }
}

///FUNCTIONS: EXTENSION METHODS FOR INTEGER DATATYPE
extension HourMintService on int{
  ///INPUT: INT
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE MINUTE INTEGER AND IF MINUTE IS SINGLE DIGIT THAN IT WILL ADD A '0' AT START OF MINUTE
  String formatMint() {
    return this <= 9 ? '0$this' : '$this';
  }
  ///INPUT: INT
  ///OUTPUT: STRING
  ///FUNCTIONS: IT WILL TAKE HOUR INTEGER AND IF HOUR IS SINGLE DIGIT THAN IT WILL ADD A '0' AT START OF HOUR
  String formatHour() {
    return this <= 9 ? '0$this' : '$this';
  }
}