import 'package:fluent_ai/app/data/services/user_service.dart';
import 'package:fluent_ai/app/modules/navbar/bindings/navbar_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes/app_pages.dart';
import 'package:timeago/timeago.dart' as timeago;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GoogleFonts.pendingFonts([
    GoogleFonts.montserrat(),
  ]);

  // Initialize services and controllers
  await Get.putAsync(() => UserService().init());

  timeago.setLocaleMessages('id', timeago.IdMessages());
  
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Fluent",
      initialRoute: AppPages.INITIAL,
      initialBinding: NavbarBinding(), // This will initialize NavbarController
      getPages: AppPages.routes,
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300),
            displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300),
            displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400),
            headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w400),
            headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: ThemeMode.light,
    ),
  );
}