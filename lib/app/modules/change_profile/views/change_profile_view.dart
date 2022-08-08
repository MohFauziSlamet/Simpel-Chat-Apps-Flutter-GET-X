import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_profile_controller.dart';

class ChangeProfileView extends GetView<ChangeProfileController> {
  ChangeProfileView({Key? key}) : super(key: key);

  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    controller.emailCon.text = authC.userModel.value.email!;
    controller.nameCon.text = authC.userModel.value.name!;
    controller.statusCon.text = authC.userModel.value.status ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        title: const Text('Change Profile'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authC.changeProfile(
                name: controller.nameCon.text,
                status: controller.statusCon.text,
              );
            },
            icon: const Icon(
              Icons.save,
              size: 30,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10,
        ),
        child: ListView(
          children: [
            // avatar glow
            AvatarGlow(
              endRadius: 110,
              glowColor: Colors.black,
              duration: const Duration(seconds: 3),
              child: Container(
                // margin: EdgeInsets.all(10),
                width: Get.width * 0.4,
                height: Get.width * 0.4,
                child: Obx(
                  () => ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: authC.userModel.value.photoURL == "no image"
                        ? const Image(
                            image: AssetImage("assets/logo/person.png"),
                            fit: BoxFit.cover,
                          )
                        : Image(
                            image:
                                NetworkImage(authC.userModel.value.photoURL!),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            //

            // TextField email
            TextField(
              autocorrect: false,
              readOnly: true,
              enabled: false,
              textInputAction: TextInputAction.next,
              controller: controller.emailCon,
              cursorColor: Colors.purple[300],
              decoration: InputDecoration(
                label: const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.purple,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.purple,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),

            // TextField name
            TextField(
              autocorrect: false,
              textInputAction: TextInputAction.next,
              controller: controller.nameCon,
              cursorColor: Colors.purple[300],
              decoration: InputDecoration(
                label: const Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.purple,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.purple,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // TextField Status
            TextField(
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                authC.changeProfile(
                  name: controller.nameCon.text,
                  status: controller.statusCon.text,
                );
              },
              controller: controller.statusCon,
              cursorColor: Colors.purple[300],
              decoration: InputDecoration(
                label: const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.purple,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.purple,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // upload image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetBuilder<ChangeProfileController>(
                    builder: (c) => c.pickedImage != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 110,
                                width: 125,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        image: DecorationImage(
                                          // FileImage : untuk menampilkan foto dari imagepicker
                                          image: FileImage(
                                            File(c.pickedImage!.path),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -5,
                                      child: IconButton(
                                        onPressed: () => c.resetImage(),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => c
                                    .uploadImage(authC.userModel.value.uid!)
                                    .then((hasilKembalian) {
                                  if (hasilKembalian != null) {
                                    authC.updatePhotoUrl(hasilKembalian);
                                  }
                                }),
                                child: Text(
                                  "upload",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text("no image"),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.selectImage();
                    },
                    child: const Text(
                      'Choose Image',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // button Update
            SizedBox(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () {
                  authC.changeProfile(
                    name: controller.nameCon.text,
                    status: controller.statusCon.text,
                  );
                },
                child: const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white,
                  primary: Colors.purple[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
