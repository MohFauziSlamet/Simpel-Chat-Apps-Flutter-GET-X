import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat/app/controllers/auth_controller.dart';
import 'package:chat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  /// kita panggil AuthController
  /// untuk memanggil data yang  ada di userModel
  final authC = Get.find<AuthController>();

  ProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authC.loguotApp();
            },
            icon: const Icon(
              Icons.logout_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Obx(
                  () => AvatarGlow(
                    endRadius: 110,
                    glowColor: Colors.white,
                    duration: const Duration(seconds: 3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        width: Get.width * 0.4,
                        height: Get.width * 0.4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: authC.userModel.value.photoURL == "no image"
                              ? const Image(
                                  image: AssetImage("assets/logo/person.png"),
                                  fit: BoxFit.cover,
                                )
                              : Image(
                                  image: NetworkImage(
                                      authC.userModel.value.photoURL!),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    '${authC.userModel.value.name}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${authC.userModel.value.email}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Get.toNamed(Routes.UPDATE_STATUS);
                  },
                  leading: const Icon(Icons.note_add_outlined, size: 30),
                  title: const Text(
                    'Update Status',
                    style: const TextStyle(fontSize: 22),
                  ),
                  trailing: const Icon(
                    Icons.arrow_right,
                    size: 60,
                  ),
                ),
                ListTile(
                  onTap: () {
                    Get.toNamed(Routes.CHANGE_PROFILE);
                  },
                  leading: const Icon(Icons.person, size: 30),
                  title: const Text(
                    'Change Profile',
                    style: TextStyle(fontSize: 22),
                  ),
                  trailing: const Icon(
                    Icons.arrow_right,
                    size: 60,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.color_lens, size: 30),
                  title: const Text(
                    'Change Theme',
                    style: const TextStyle(fontSize: 22),
                  ),
                  trailing: const Text(
                    "Light",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(bottom: context.mediaQueryPadding.bottom + 10),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Chats App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'v.1.0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
