import 'package:manage/api/apiurl.dart';

class Urls {
  static String login = ApiUrl.api + "user/login/";
  static String signup = ApiUrl.api + "user/signup/";
  static String addExpenditures = ApiUrl.api + "expenditures/addTransactions";
  static String getExpenditures = ApiUrl.api + "expenditures/getTransactions";
}
