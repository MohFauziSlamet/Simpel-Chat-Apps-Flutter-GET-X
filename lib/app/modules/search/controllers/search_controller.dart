import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  late TextEditingController searchController;

  /// kita buat 2 list untuk menampung text input dan memfilter
  var queryAwal = [].obs; // untuk ketikan
  var tempSearch = [].obs; // untuk memfilter dari queryAwal

  /// kita akan mengakses firestore
  /// maka kita butuh sebuah instance
  /// instance ini digunakan untuk mengakses collection
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// function untuk search
  void searchFriend({required String dataInput, required String email}) async {
    // print("SEARCH :  $dataInput");

    /// pertama kita cek dulu, dataInput kosong atau tidak
    /// jika kosong, maka queryAwal dan tempSearch kita kosongkan
    /// karena ketika TextField search kosong , maka kita juga kosongkan
    /// list queryAwal dan tempSearch
    if (dataInput.length == 0) {
      /// jika kosong
      queryAwal.value = [];
      tempSearch.value = [];
    } else {
      /// jika tidak kosong
      /// mengubah huruf pertama menjadi kapital
      var capitalized =
          dataInput.substring(0, 1).toUpperCase() + dataInput.substring(1);
      // print(capitalized);

      // ignore: unrelated_type_equality_checks
      /// fungsi yang akan dijalankan pada 1 huruf ketikan pertama
      if (queryAwal.length == 0 && dataInput.length == 1) {
        /// kita akan mengambil data dari firestore
        CollectionReference users = await firestore.collection('users');

        /// mengambil data yang sama dari huruf pertama yang diketikan
        /// dan juga bukan email yang sedang digunakan
        final keyNameResult = await users
            .where('keyName',
                isEqualTo: dataInput.substring(0, 1).toUpperCase())
            .where('email', isNotEqualTo: email)
            .get();

        if (keyNameResult.docs.length > 0) {
          for (var i = 0; i < keyNameResult.docs.length; i++) {
            queryAwal.add(keyNameResult.docs[i].data() as Map<String, dynamic>);
          }

          print("QUERY DATA:");
          print(queryAwal);
        } else {
          print("QUERY DATA:");
          print(queryAwal);
          print('path search controller : Tidak ada data');
        }
      }

      /// memasukan data kedalam list tempSearch
      if (queryAwal.length != 0) {
        tempSearch.value = [];
        queryAwal.forEach(
          (element) {
            // print("element : $element");
            if (element["name"].startsWith(capitalized)) {
              tempSearch.add(element);
              // print("element : $tempSearch");
            }
          },
        );
      }
    }

    /// karena data kita berupa obs, setiap kali ada perubahan ,
    /// kita harus melakukan refresh
    queryAwal.refresh();
    tempSearch.refresh();
  }

  ///

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
  }
}
