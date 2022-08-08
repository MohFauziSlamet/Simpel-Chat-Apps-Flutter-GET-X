import 'package:chat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.mediaQuerySize.height * 0.2),
        child: AppBar(
          backgroundColor: Colors.purple[400],
          title: const Text('Search'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back, size: 30),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                controller: controller.searchController,
                cursorColor: Colors.purple[400],
                cursorWidth: 3,
                onChanged: (value) {
                  /// value digunakan untuk pencarian
                  controller.searchFriend(
                      dataInput: value, email: authC.userModel.value.email!);
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  hintText: 'Seacrh new friend here...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  suffixIcon: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      size: 30,
                      color: Colors.purple[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.tempSearch.length == 0
            ? Center(
                child: Container(
                  height: Get.width * 0.7,
                  width: Get.width * 0.7,
                  child: Lottie.asset("assets/lottie/empty.json", repeat: true),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero, // menghapus pading ListView
                itemCount: controller.tempSearch.length,
                itemBuilder: (context, index) {
                  // print({controller.tempSearch.length});
                  // print({controller.tempSearch[index]["name"]});
                  // print({controller.tempSearch[index]["email"]});
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: controller.tempSearch[index]["photoURL"] ==
                                "no image"
                            ? Image.asset(
                                "assets/logo/person.png",
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                "${controller.tempSearch[index]["photoURL"]}"),
                      ),
                    ),
                    title: Text(
                      "${controller.tempSearch[index]["name"]}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "${controller.tempSearch[index]["email"]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        authC.addNewConnection(
                          friendEmail: controller.tempSearch[index]["email"],
                        );
                      },
                      child: Chip(
                        backgroundColor: Colors.purple[300],
                        label: const Text('Message'),
                        labelStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
