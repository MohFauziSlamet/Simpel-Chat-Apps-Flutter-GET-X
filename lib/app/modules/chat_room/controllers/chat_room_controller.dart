import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatRoomController extends GetxController {
  late TextEditingController createMassage;

  // untuk menghandle auto scroll ke bawah , ketika ada chat baru
  late ScrollController scrollC;

  // bool untuk mengecek ada apa pengetikan didalam TextField
  RxBool isTyping = false.obs;

  // bool untuk mengecek ada apa pengetikan didalam TextField
  RxBool isShowEmoji = false.obs;

  // variabel penampung FocusNode
  late FocusNode focusNode;

  // function untuk menambahkan emoji kedalam TextField
  void addEmojiToTextfield({required Emoji parameterEmoji}) {
    // menambahkan emoji ke TextEditingController createMassage
    createMassage.text = createMassage.text + parameterEmoji.emoji;
  }

  // function untuk menambahkan emoji kedalam TextField
  void deleteEmojiFromTextfield() {
    // kita akan mengubah isi didalam TextEditingController createMassage.text
    // kita akan menghapus dengan bantuan substring (menthode untuk menghapus sebuah string)
    //
    createMassage.text =
        createMassage.text.substring(0, createMassage.text.length - 2);
  }

  /// -------------------------------- NEW CHAT --------------------------------
  /// variabel global
  /// kita inisiasi dulu firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var date = DateTime.now().toIso8601String();
  int totalUnread = 0;

  void newChat({
    required Map<String, dynamic> argumens,
    required String chat,
    required String email,
  }) async {
    // validasi , jika chat kosong
    if (chat != '') {
      /// masuk ke collection chats
      final chats = firestore.collection("chats");
      final users = firestore.collection("users");

      /// kita buat collection chat yang ada DI DALAM collection chats
      /// dan menambahkan data
      await chats.doc(argumens["chat_id"]).collection("chat").add({
        "pengirim": email,
        "penerima": argumens["friendEmail"],
        "msg": chat,
        "time": date,
        "isRead": false,
        "grupTime": DateFormat.yMMMMd('en_US').format(DateTime.parse(date)),
      });

      // kita buat auto scroll
      /// jumpTo :Melompati posisi gulir dari nilai saat ini ke nilai yang diberikan,
      /// tanpa animasi, dan tanpa memeriksa apakah nilai baru berada dalam jangkauan.
      /// Animasi aktif apa pun dibatalkan. Jika pengguna saat ini menggulir,
      /// tindakan tersebut akan dibatalkan.
      /// Jika metode ini mengubah posisi gulir, urutan pemberitahuan gulir mulai/update/akhir
      /// akan dikirim. Tidak ada pemberitahuan overscroll yang dapat dihasilkan dengan metode
      /// ini. Segera setelah lompatan, aktivitas balistik dimulai, jika nilainya di luar jangkauan
      Timer(Duration.zero,
          () => scrollC.jumpTo(scrollC.position.maxScrollExtent));

      // setelah dikirim , text akan dikosongkan
      createMassage.clear();

      await users
          .doc(email)
          .collection("chats")
          .doc(argumens["chat_id"])
          .update({
        "lastTime": date,
      });

      final chechChatsFriend = await users
          .doc(argumens["friendEmail"])
          .collection("chats")
          .doc(argumens["chat_id"])
          .get();

      if (chechChatsFriend.exists) {
        // ada dokumen
        // lakukan update for friend database

        // cek total unread friend
        final checkTotalUnread = await chats
            .doc(argumens["chat_id"])
            .collection("chat")
            .where("isRead", isEqualTo: false)
            .where("pengirim", isEqualTo: email)
            .get();

        // total unread for friend
        totalUnread = checkTotalUnread.docs.length;

        // selanjutnya kita update lastTime dan totalUnread
        await users
            .doc(argumens["friendEmail"])
            .collection("chats")
            .doc(argumens["chat_id"])
            .update({
          "lastTime": date,
          "totalUnread": totalUnread,
        });
      } else {
        // tidak ada dokumen
        // buat baru for friend database
        await users
            .doc(argumens["friendEmail"])
            .collection("chats")
            .doc(argumens["chat_id"])
            .set({
          "connection": email,
          "lastTime": date,
          "totalUnread": totalUnread + 1,
        });
      }
    }
  }

  /// --------------------------------------------------------------------------

  /// -------------------------------- STREAM CHAT --------------------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> streamChats({String? chatId}) {
    print("stream chat id:  $chatId");
    CollectionReference chats = firestore.collection("chats");

    return chats
        .doc(chatId)
        .collection("chat")
        .orderBy("time", descending: false)
        .snapshots();
  }

  /// --------------------------------------------------------------------------
  /// -------------------------------- STREAM FRIEND DATA --------------------------------
  Stream<DocumentSnapshot<Object?>> streamFriendData({String? friendEmail}) {
    print("stream chat id:  $friendEmail");
    CollectionReference users = firestore.collection("users");

    return users.doc(friendEmail).snapshots();
  }

  /// --------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    createMassage = TextEditingController(text: '');
    scrollC = ScrollController();

    // menentukan aktif atau tidak aktif
    focusNode = FocusNode();

    // addListener : menambahkan keadaan pada keyboar untuk
    // menyatakan aktif atau tidak aktif
    focusNode.addListener(() {
      // kita chek dulu , apakah focusNode sedang aktif atau tidak
      if (focusNode.hasFocus) {
        // ia ada focus , artinya keyboard membuka
        // kita akan menutup emoji , dengan mengubah nilai isShowEmoji menjadi false
        isShowEmoji.value = false;
      }
    });
  }

  @override
  void onClose() {
    createMassage.dispose();
    scrollC.dispose();
    focusNode.dispose();
  }
}
