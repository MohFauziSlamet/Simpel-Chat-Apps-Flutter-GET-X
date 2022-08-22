import 'dart:async';
import 'dart:io';

import 'package:chat/app/controllers/auth_controller.dart';
import 'package:chat/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/chat_room_controller.dart';
import '../widget_component/item_chat.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  ChatRoomView({Key? key}) : super(key: key);

  /// memanggil data dari AuthController
  final authC = Get.find<AuthController>();

  /// chatId
  var chatId = (Get.arguments as Map<String, dynamic>)["chat_id"];
  var friendEmail = (Get.arguments as Map<String, dynamic>)["friendEmail"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[500],
        title: InkWell(
          onTap: () {
            // Get.toNamed(Routes.PROFILE);s
          },
          child: StreamBuilder<DocumentSnapshot<Object?>>(
            stream: controller.streamFriendData(friendEmail: friendEmail),
            builder: (context, snapshotFriendData) {
              if (snapshotFriendData.connectionState ==
                  ConnectionState.active) {
                // jika kondisi aktif
                // kita cek isi snapshotFriendData
                var data =
                    snapshotFriendData.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['name']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${data['status']}",
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              }
              // jika kondisi  selain aktif
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ],
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_back,
                ),
                const SizedBox(width: 3),
                CircleAvatar(
                  radius: Get.width * 0.14 * 0.25,
                  backgroundColor: Colors.grey[300],
                  child: StreamBuilder<DocumentSnapshot<Object?>>(
                    stream:
                        controller.streamFriendData(friendEmail: friendEmail),
                    builder: (context, snapshotFriendData) {
                      if (snapshotFriendData.connectionState ==
                          ConnectionState.active) {
                        // jika kondisi aktif

                        // kita cek isi snapshotFriendData
                        var data = snapshotFriendData.data!.data()
                            as Map<String, dynamic>;

                        // disini kita cek
                        // image nya ada atau tidak
                        // kareana di awal memasukan data di AuthController
                        // jika image dari account google_sign_in kosong , maka
                        // yang dimasukan adl string "no image"
                        if (data['photoURL'] == "no image") {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/logo/person.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              data['photoURL'],
                              fit: BoxFit.fill,
                            ),
                          );
                        }
                      }
                      // jika kondisi selain aktif
                      return ClipRRect(
                        // borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/logo/person.png',
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: Get.width * 0.17,
      ),
      body: WillPopScope(
        // function untuk menutup tampilan emoji dengan menggunakan tombol back pada android
        onWillPop: () {
          if (controller.isShowEmoji.isTrue) {
            controller.isShowEmoji.value = false;
          } else {
            Get.back();
          }

          return Future.value(false);
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white70,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.streamChats(chatId: chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      var allData = snapshot.data!.docs;

                      // sebelum melakukan build ListView
                      // kita scrol sampai dibatas bawah
                      Timer(
                          Duration.zero,
                          () => controller.scrollC.jumpTo(
                              controller.scrollC.position.maxScrollExtent));
                      return ListView.builder(
                        controller: controller.scrollC,
                        itemCount: allData.length,
                        itemBuilder: (context, index) {
                          // kita cek indexnya
                          // jika index == 0
                          // kita juga tampilkan grupTime per hari
                          if (index == 0) {
                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "${allData[index]["grupTime"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ItemChat(
                                  msg: '${allData[index]['msg']}',
                                  isSender: allData[index]['pengirim'] ==
                                          authC.userModel.value.email
                                      ? true
                                      : false,
                                  time: '${allData[index]['time']}',
                                ),
                              ],
                            );
                          } else {
                            if (allData[index]["grupTime"] ==
                                allData[index - 1]["grupTime"]) {
                              return ItemChat(
                                msg: '${allData[index]['msg']}',
                                isSender: allData[index]['pengirim'] ==
                                        authC.userModel.value.email
                                    ? true
                                    : false,
                                time: '${allData[index]['time']}',
                              );
                            } else {
                              return Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    "${allData[index]["grupTime"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ItemChat(
                                    msg: '${allData[index]['msg']}',
                                    isSender: allData[index]['pengirim'] ==
                                            authC.userModel.value.email
                                        ? true
                                        : false,
                                    time: "${allData[index]['time']}",
                                  ),
                                ],
                              );
                            }
                          }
                        },
                      );
                    }

                    // jika connectionState selain active
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),

            // TextField pesan
            Container(
              color: Colors.purple[50],
              margin: EdgeInsets.only(
                  bottom: controller.isShowEmoji.isTrue
                      ? 0
                      : context.mediaQueryPadding.bottom),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              width: context.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      // untuk memmbuka dan menutup keyboard
                      focusNode: controller.focusNode,
                      onChanged: (_) {
                        // jika ada ketikan , tombol akan berubah ke mode send
                        // namun jika TextField kosong , akan ke mode voice
                        controller.isTyping.value = true;
                        if (controller.createMassage.text == '') {
                          controller.isTyping.value = false;
                        }
                      },
                      autocorrect: false,
                      onEditingComplete: () => controller.newChat(
                        argumens: Get.arguments as Map<String, dynamic>,
                        chat: controller.createMassage.text,
                        email: authC.userModel.value.email!,
                      ),
                      controller: controller.createMassage,
                      cursorColor: Colors.purple[300], maxLines: 2,
                      decoration: InputDecoration(
                        focusColor: Colors.purple[500],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(
                            color: Colors.purple,
                          ),
                        ),
                        hintText: 'Tulis pesan disini...',
                        prefixIcon: IconButton(
                          onPressed: () {
                            // ketika emoji ditekan , dan saat itu keyboard aktif
                            // kita akan menutup keyboard , dengan cara membuat keyboard unfocus
                            // unfocus : menghapus focus yang sudah ada saat ini
                            controller.focusNode.unfocus();

                            // mengubah nilai true ke false dan sebaliknya
                            // agar mengaktifkan emoji
                            controller.isShowEmoji.toggle();
                          },
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.purple[300],
                          ),
                        ),
                        fillColor: Colors.white38,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(
                            color: Colors.purple,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // tombol send
                  Obx(
                    () => Container(
                      child: controller.isTyping.value
                          ? Material(
                              color: Colors.purple[500],
                              borderRadius: BorderRadius.circular(25),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  controller.newChat(
                                    argumens:
                                        Get.arguments as Map<String, dynamic>,
                                    chat: controller.createMassage.text,
                                    email: authC.userModel.value.email!,
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Material(
                              color: Colors.purple[500],
                              borderRadius: BorderRadius.circular(25),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {},
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // kita check variabel boolean isShowEmoji
            // jika true , kita tampilkan emoji
            // jika false, kita tampilkan sizebox kosong
            Obx(
              () => (controller.isShowEmoji.value == true)
                  ? SizedBox(
                      height: 325,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          // Do something when emoji is tapped
                          // memanggil function addEmojiToTextfield
                          controller.addEmojiToTextfield(parameterEmoji: emoji);
                        },
                        onBackspacePressed: () {
                          controller.deleteEmojiFromTextfield();
                        },
                        config: Config(
                            columns: 7,
                            emojiSizeMax:
                                32 * (Platform.isAndroid ? 1.30 : 1.0),
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            initCategory: Category.RECENT,
                            bgColor: const Color(0xFFF2F2F2),
                            indicatorColor: const Color(0xffAB47BC),
                            iconColor: Colors.grey,
                            iconColorSelected: const Color(0xffAB47BC),
                            progressIndicatorColor: const Color(0xffAB47BC),
                            backspaceColor: const Color(0xffAB47BC),
                            showRecentsTab: true,
                            recentsLimit: 28,
                            noRecentsText: "No Recents",
                            noRecentsStyle: const TextStyle(
                                fontSize: 20, color: Colors.black26),
                            categoryIcons: const CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
