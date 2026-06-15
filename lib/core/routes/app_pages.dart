import 'package:get/get.dart';

import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/feature/auth/bindings/auth_binding.dart';
import 'package:ohmie_customer/feature/auth/views/login_screen.dart';
import 'package:ohmie_customer/feature/auth/views/otp_screen.dart';
import 'package:ohmie_customer/feature/booking/bindings/booking_binding.dart';
import 'package:ohmie_customer/feature/booking/views/booking_screen.dart';
import 'package:ohmie_customer/feature/history/bindings/history_binding.dart';
import 'package:ohmie_customer/feature/history/views/history_screen.dart';
import 'package:ohmie_customer/feature/home/bindings/home_binding.dart';
import 'package:ohmie_customer/feature/home/views/home_screen.dart';
import 'package:ohmie_customer/feature/profile/bindings/profile_binding.dart';
import 'package:ohmie_customer/feature/profile/views/profile_screen.dart';
import 'package:ohmie_customer/feature/splash/splash_binding.dart';
import 'package:ohmie_customer/feature/splash/splash_screen.dart';
import 'package:ohmie_customer/feature/tracking/bindings/tracking_binding.dart';
import 'package:ohmie_customer/feature/tracking/views/tracking_screen.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingScreen(),
      binding: BookingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tracking,
      page: () => const TrackingScreen(),
      binding: TrackingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
