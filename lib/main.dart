// catatan package
// firebase_core : digunakan untuk mengakses seluruh fungsi yang ada pada firebase.

import 'package:chat/app/controllers/auth_controller.dart';
import 'package:get_storage/get_storage.dart';

import './app/utils/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  // ini wajib ditambahkan diawal
  // untuk menyambungkan ke firebase
  // inisiasi firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ini wajib ditambahkan diawal
  // untuk menggunakan get_storage
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // memanggil  AuthController
  final authCon = Get.put(AuthController(), permanent: true);

  //
  @override
  Widget build(BuildContext context) {
    // return Obx(() => GetMaterialApp(
    //       debugShowCheckedModeBanner: false,
    //       title: "Chat App",
    //       initialRoute:
    //           authCon.isAuth.isTrue ? Routes.HOME : Routes.LOGIN, // jika false
    //       getPages: AppPages.routes,
    //     ));

    return FutureBuilder(
      // membuat delay waktu untuk SplashScreen selama 6 detik
      future: Future.delayed(const Duration(seconds: 6)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // setelah delay 6 detik
          // menampilkan login page
          return Obx(
            () => GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Chat App",
              initialRoute: authCon.isSkipIntroduction.isTrue
                  ? authCon.isAuth.isTrue
                      ? Routes.HOME
                      : Routes.LOGIN // jika false
                  : Routes.INTRODUCTION, // jika false
              getPages: AppPages.routes,
            ),
          );
        }

        /// ketika delay 6 detik berjalan , akan menampilkan splash_screen.
        /// dan menjalankan function firstInitialized
        /// untuk mengecek isAuth dan isSkipIntroduction apakah true.
        /// function firstInitialized akan selalu dijalankan ketika, menjalankan
        /// SplashScreen
        return FutureBuilder(
          future: authCon.firstInitialized(),
          builder: (context, snapshot) {
            return const SplashScreen();
          },
        );
      },
    );
  }
}
