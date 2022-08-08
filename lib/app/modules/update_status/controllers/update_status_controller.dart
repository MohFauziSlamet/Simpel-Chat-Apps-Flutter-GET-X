import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateStatusController extends GetxController {
  late TextEditingController updateStatusController;

  @override
  void onInit() {
    super.onInit();
    updateStatusController = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    updateStatusController.dispose();
  }
}
