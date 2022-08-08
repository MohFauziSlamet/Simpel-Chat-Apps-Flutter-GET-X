// To parse this JSON data, do
//
//     final usersModel = usersModelFromJson(jsonString);

import 'dart:convert';

UsersModel usersModelFromJson(String str) =>
    UsersModel.fromJson(json.decode(str));

String usersModelToJson(UsersModel data) => json.encode(data.toJson());

class UsersModel {
  UsersModel({
    this.uid,
    this.name,
    this.keyName,
    this.email,
    this.photoURL,
    this.status,
    this.creationTime,
    this.lastSignInTime,
    this.updatedAt,
    this.chats,
  });

  String? uid;
  String? name;
  String? keyName;
  String? email;
  String? photoURL;
  String? status;
  String? creationTime;
  String? lastSignInTime;
  String? updatedAt;
  List<ChatUserModel>? chats;

  factory UsersModel.fromJson(Map<String, dynamic> json) => UsersModel(
        uid: json["uid"],
        name: json["name"],
        keyName: json["keyName"],
        email: json["email"],
        photoURL: json["photoURL"],
        status: json["status"],
        creationTime: json["creationTime"],
        lastSignInTime: json["lastSignInTime"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "keyName": keyName,
        "email": email,
        "photoURL": photoURL,
        "status": status,
        "creationTime": creationTime,
        "lastSignInTime": lastSignInTime,
        "updatedAt": updatedAt,
      };
}

class ChatUserModel {
  ChatUserModel({
    this.connection,
    this.chatId,
    this.lastTime,
    this.totalUnread,
  });

  String? connection;
  String? chatId;
  String? lastTime;
  int? totalUnread;

  factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
        connection: json["connection"],
        chatId: json["chat_id"],
        lastTime: json["lastTime"],
        totalUnread: json["totalUnread"],
      );

  Map<String, dynamic> toJson() => {
        "connection": connection,
        "chat_id": chatId,
        "lastTime": lastTime,
        "totalUnread": totalUnread,
      };
}
