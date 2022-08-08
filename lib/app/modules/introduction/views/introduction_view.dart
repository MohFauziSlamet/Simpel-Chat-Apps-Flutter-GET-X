import 'package:chat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';

import '../controllers/introduction_controller.dart';

class IntroductionView extends GetView<IntroductionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Berintersaksi dengan mudah",
              body:
                  "Kamu hanya perlu dirumah saja untuk mendapakatkan teman baru",
              image: Container(
                margin: EdgeInsets.only(top: 20),
                width: Get.width * 0.75,
                height: Get.width * 0.75,
                child: Center(
                    child:
                        Lottie.asset("assets/lottie/main-laptop-duduk.json")),
              ),
            ),
            PageViewModel(
              title: "Temukan sahabat baru disini",
              body:
                  "Jika kamu mendapatkan jodoh dari aplikasi ini , kami sangat bahagia",
              image: Container(
                margin: EdgeInsets.only(top: 20),
                width: Get.width * 0.75,
                height: Get.width * 0.75,
                child: Center(child: Lottie.asset("assets/lottie/ojek.json")),
              ),
            ),
            PageViewModel(
              title: "Aplikasi bebas biaya",
              body:
                  "Kamu tidak perlu khawatir, aplikasi ini bebas dari biaya apapun",
              image: Container(
                margin: EdgeInsets.only(top: 20),
                width: Get.width * 0.75,
                height: Get.width * 0.75,
                child:
                    Center(child: Lottie.asset("assets/lottie/payments.json")),
              ),
            ),
            PageViewModel(
              title: "Gabung sekarang juga",
              body:
                  "Daftarkan diri kamu, kami akan menghubungkan dengan 1000 teman lainnya",
              image: Container(
                margin: EdgeInsets.only(top: 20),
                width: Get.width * 0.75,
                height: Get.width * 0.75,
                child:
                    Center(child: Lottie.asset("assets/lottie/register.json")),
              ),
            ),
          ],
          onDone: () {
            // When done button is press
            Get.offAllNamed(Routes.LOGIN);
          },
          showBackButton: false,
          showSkipButton: true,
          skip: const Text(
            'Skip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          next: const Text(
            'Next',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          done: const Text("Login",
              style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Colors.blue,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }
}
