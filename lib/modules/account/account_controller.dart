import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/dialogue_service/dialogues.dart';
import '../../utils/local_storage/stored_data.dart';

class AccountController extends GetxController {
  RxString driverName = ''.obs;
  RxString driverRole = ''.obs;
  RxString driverId = ''.obs;
  RxBool isLoggingOut = false.obs;

  @override
  void onReady() {
    super.onReady();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await StoredData.getTokenModel();
    driverName.value = token?.fullName ?? 'Driver';
    driverRole.value = token?.role ?? 'Driver';
    driverId.value = token?.userId ?? '';
  }

  Future<void> logout() async {
    await Dialogues.confirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      onConfirm: _doLogout,
    );
  }

  Future<void> _doLogout() async {
    isLoggingOut.value = true;
    try {
      // AuthService.logout revokes the refresh token on the server, wipes
      // SecureTokenStore, and clears legacy SharedPreferences.
      await AuthService().logout();
      Get.offAllNamed(AppRoute.login);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
