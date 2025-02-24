class AppUtils{

  static String formatDate({required String pDate}) {
    DateTime date = DateTime.parse(pDate);
    List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    String day = date.day.toString().padLeft(2, '0');
    String month = months[date.month - 1];
    String year = date.year.toString();

    return "$day $month $year";
  }

  static String formatDateAndGetDay(DateTime datetime){
    List<String> days = ['mon','tue','wed','thur','Fri','sat','sun'];

    String day = days[datetime.weekday - 1];

    return day;
  }


  static String? validateExpenseTitle(String str){
    if(str.isEmpty){
      return '* can not be empty';
    }else{
      return null;
    }
  }

  static String? validateExpenseAmount(String str){
    if(str.isEmpty){
      return '* can not be empty';
    }else{
      return null;
    }
  }
}