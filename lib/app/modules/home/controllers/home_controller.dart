import 'package:chat/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // mengambil data chat di firestore secara realtime
  // dengan menggukanan StreamBuilder
  Stream<QuerySnapshot<Map<String, dynamic>>> chatsStream(
      {required String email}) {
    return firestore
        .collection("users")
        .doc(email)
        .collection('chats')
        .orderBy('lastTime', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> friendStream(
      {required String email}) {
    return firestore.collection("users").doc(email).snapshots();
  }

  void goToChatRoom({
    String? chatId,
    String? email,
    String? friendEmail,
  }) async {
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");
    print(chatId);

    /// sebelum kita pindah ke CHAT_ROOM
    /// kita juga haru mengubah isRead menjadi true
    /// dan mengubah totalUnread = 0
    /// hal ini jika kita masuk ke dalam CHAT_ROOM melalui pencarian friend

    // kita ambil data pada collection chats
    // berdasarkan chat_id kita (currentUser) dengan friendEmail
    // kita ambil isRead = false
    // dan penerimanya adalah kita (currentUser)
    final updateStatusChat = await chats
        .doc(chatId)
        .collection('chat')
        .where('isRead', isEqualTo: false)
        .where('penerima', isEqualTo: email)
        .get();

    // karena datanya bisa lebih dari 1
    // kita lakukan looping , agar dapat mengubah semua
    updateStatusChat.docs.forEach((element) async {
      await chats
          .doc(chatId)
          .collection('chat')
          .doc(element.id)
          .update({"isRead": true});
    });

    // selanjutnya kita ubah juga totalUnread pada currentUser (kita)
    await users
        .doc(email)
        .collection("chats")
        .doc(chatId)
        .update({"totalUnread": 0});

    Get.toNamed(
      Routes.CHAT_ROOM,
      arguments: {
        "chat_id": chatId,
        "friendEmail": friendEmail,
      },
    );
  }
}
