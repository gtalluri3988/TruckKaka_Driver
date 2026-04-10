import 'package:get/get.dart';
import '../home/home_screen.dart';
import '../account/account_screen.dart';
import '../payments/payments_screen.dart';

class MainController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final List<dynamic> pages = [
    const HomeScreen(),
    const AccountScreen(),
    const PaymentsScreen(),
  ];

  void selectTab(int index) {
    selectedIndex.value = index;
  }
}
