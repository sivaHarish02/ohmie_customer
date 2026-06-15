import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ohmie_customer/core/network/api_client.dart';
import 'package:ohmie_customer/core/routes/app_pages.dart';
import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/core/services/api_service.dart';
import 'package:ohmie_customer/core/services/socket_service.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';
import 'package:ohmie_customer/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Keep system bars in sync with the light app theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize core services before routing starts.
  await Get.putAsync<StorageService>(() async {
    final service = StorageService();
    await service.init();
    return service;
  }, permanent: true);

  await Get.putAsync<ApiService>(() async {
    final service = ApiService();
    await service.init();
    return service;
  }, permanent: true);

  await Get.putAsync<ApiClient>(() async {
    final client = ApiClient();
    await client.init();
    return client;
  }, permanent: true);

  Get.put<SocketService>(SocketService(), permanent: true);

  runApp(const OhmieCustomerApp());
}

class OhmieCustomerApp extends StatelessWidget {
  const OhmieCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Ohmie Customer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          builder: (context, widget) {
            // Ensure text scale factor does not break UI
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
