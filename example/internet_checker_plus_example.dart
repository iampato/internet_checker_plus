import 'package:internet_checker_plus/internet_checker_plus.dart';

void main() {
  var internetChekerPlus = InternetCheckerPlus(
    checkerOptions: CheckerOptions(
      uri: Uri.parse('https://google.com'),
      method: HttpMethod.get,
      timeout: Duration(seconds: 1),
    ),
    checkInterval: Duration(seconds: 1),
  );
  internetChekerPlus.onStatusChange.listen(
    (bool status) {
      print('Status: $status');
    },
  );
}
