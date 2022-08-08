import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProfileController extends GetxController {
  late TextEditingController nameCon;
  late TextEditingController emailCon;
  late TextEditingController statusCon;

  // kita buat imagePicker
  late ImagePicker imagePicker;

  // kita buat
  XFile? pickedImage = null;

  /// inisiasi awal untuk konek dengan firebase storage
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImage(String uid) async {
    // Mewakili referensi (jika di firestore namanya collection) ke objek Google Cloud Storage.
    // developer dapat mengunggah, mengunduh, dan menghapus objek, serta mendapatkan/mengatur metadata objek.
    Reference storageRef = storage.ref("$uid.png");
    File file = File(pickedImage!.path);

    try {
      // putFile : mengupload file ke firebase storage
      await storageRef.putFile(file);
      final photoUrl = await storageRef.getDownloadURL();
      print("$photoUrl");
      resetImage();
      return photoUrl;
    } catch (err) {
      print("Terjadi error : $err");
      Get.defaultDialog(title: 'Terjadi Kesalahan', middleText: "$err");
      return null;
    }
  }

  ///  menghapus image yang telah di ambil
  void resetImage() {
    pickedImage = null;
    update();
  }

  /// mengambil image dari perangkat
  void selectImage() async {
    try {
      final checkDataImage =
          await imagePicker.pickImage(source: ImageSource.gallery);

      /// kita cek , apakah jadi ada image yang di ambil
      /// atau cancel
      if (checkDataImage != null) {
        /// ada image yang di select (di pilih dari gallery

        /// Nama file seperti yang dipilih oleh pengguna di perangkat mereka.
        /// Gunakan hanya untuk alasan kosmetik, jangan mencoba menggunakan ini sebagai jalan.
        print(checkDataImage.name);

        /// mendapatkan jalur file yang dipilih.
        print(checkDataImage.path);
        pickedImage = checkDataImage;
      }

      /// kareana mengguankan get builder
      /// maka setiap selesai proses , harus dilakukan update
      /// update() ini sama halnya setstate di statefull
      update();
    } catch (err) {
      print(err);
      pickedImage = null;
      update();
      Get.defaultDialog(
        title: 'Terjadi kesalahan',
        middleText: "$err",
        onConfirm: () {
          Get.back();
        },
        textConfirm: 'kembali',
        barrierDismissible: true,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    nameCon = TextEditingController();
    emailCon = TextEditingController();
    statusCon = TextEditingController();
    imagePicker = ImagePicker();
  }

  @override
  void onClose() {
    emailCon.dispose();
    nameCon.dispose();
    statusCon.dispose();
  }
}
