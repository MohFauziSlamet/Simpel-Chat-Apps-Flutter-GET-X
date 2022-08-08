import 'package:chat/app/controllers/auth_controller.dart';
import 'package:chat/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  /// mengakses data pada authcontroller
  final authController = Get.find<AuthController>();

  HomeView({Key? key}) : super(key: key);
  // reversed : [Iterable] dari objek dalam daftar ini dalam urutan terbalik.
  // mengurutkan dari nilai dari terbsesar ke terkecil dalam suatu list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black38),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chats',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                Material(
                  color: Colors.purple[400],
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Get.toNamed(Routes.PROFILE);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // listtile chats
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.chatsStream(
                  email: authController.userModel.value.email!),
              builder: (context, snapshot1) {
                if (snapshot1.connectionState == ConnectionState.active) {
                  var allChatsLenght = snapshot1.data!.docs.length;
                  var allChats = snapshot1.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10), // menghapus pading ListView
                    itemCount: allChatsLenght,
                    itemBuilder: (context, index) {
                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: controller.friendStream(
                            email: allChats[index]['connection']),
                        builder: (context, snapshot2) {
                          if (snapshot2.connectionState ==
                              ConnectionState.active) {
                            var data = snapshot2.data!.data();
                            return data!['status'] == ''
                                ? ListTile(
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 10, left: 20, right: 20),
                                    onTap: () {
                                      controller.goToChatRoom(
                                        chatId: allChats[index].id,
                                        friendEmail: allChats[index]
                                            ['connection'],
                                        email: authController
                                            .userModel.value.email,
                                      );
                                    },
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white70,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        child: Container(
                                          width: 75,
                                          height: 75,
                                          child: data["photoURL"] == 'no image'
                                              ? Image.asset(
                                                  "assets/logo/person.png",
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  "${data["photoURL"]}",
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "${data["name"]}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: allChats[index]["totalUnread"] !=
                                            0
                                        ? Chip(
                                            backgroundColor: Colors.purple[300],
                                            label: Text(
                                                '${allChats[index]["totalUnread"]}'),
                                            labelStyle: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          )
                                        : const SizedBox(),
                                  )
                                : ListTile(
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 10, left: 20, right: 20),
                                    onTap: () {
                                      controller.goToChatRoom(
                                        chatId: allChats[index].id,
                                        friendEmail: allChats[index]
                                            ['connection'],
                                        email: authController
                                            .userModel.value.email,
                                      );
                                    },
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white70,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        child: Container(
                                          width: 75,
                                          height: 75,
                                          child: data["photoURL"] == 'no image'
                                              ? Image.asset(
                                                  "assets/logo/person.png",
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  "${data["photoURL"]}",
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "${data["name"]}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${data["status"]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: allChats[index]["totalUnread"] !=
                                            0
                                        ? Chip(
                                            backgroundColor: Colors.purple[300],
                                            label: Text(
                                                '${allChats[index]["totalUnread"]}'),
                                            labelStyle: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          )
                                        : const SizedBox(),
                                  );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.SEARCH);
        },
        child: const Icon(Icons.search),
        backgroundColor: Colors.purple[500],
      ),
    );
  }
}
