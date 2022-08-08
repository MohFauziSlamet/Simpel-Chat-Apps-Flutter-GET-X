import 'package:chat/app/data/models/users_model.dart';
import 'package:chat/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
//  kita buat variabel bool untuk mengecek apakah user sudah pernah login atau
//  user baru.
//  tujuannya : jika user baru maka akan ke introduction screen.
//  jika user sudah pernah login , akan di arahkan ke login.
  RxBool isSkipIntroduction = false.obs;

  // membuat variabel apakah di sudah pernah login (auth)
  // tujuannya: jika sudah pernah auth , akan ke home_screen
  // jika belum , akan ke login_screen
  RxBool isAuth = false.obs;

  /// membuat variabel user dari UserModel
  var userModel = UsersModel().obs;

  // inisiasi _googleSignIn
  GoogleSignIn _googleSignIn = GoogleSignIn();

  /// inisiasi cloud firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // menghandle user
  // buat variabel untuk menampung data value dari signIn
  // dengan tipe kembalian GoogleSignInAccount
  GoogleSignInAccount? _currentUser;

  // digunakan untuk menampung value credential dari proses
  // signInWithCredential(credential)
  UserCredential? userCredential;

  /// ---------------------------FIRST_INITIALIZED------------------------------
  /// membuat function untuk mengubah nilai isAuth dan isSkipIntroduction => true
  Future<void> firstInitialized() async {
    /// kita jalankan function autoLogin
    await autoLogin().then(
      (value) {
        if (value) {
          isAuth.value = true;
        }
      },
    );

    /// kita jalankan function skipIntro
    await skipIntro().then(
      (value) {
        if (value) {
          isSkipIntroduction.value = true;
        }
      },
    );
  }

  Future<bool> autoLogin() async {
    try {
      /// kita check apakah aplikasi dalam kondisi ada akun google(sudah signIn)
      /// isSigned = akan mengembalikan nilai bool .
      final isSigned = await _googleSignIn.isSignedIn();
      if (isSigned) {
        /// sebelum mengembalikan nilai true
        /// jika benar2 signIn dan ada data nya , kita akan memasukan data kedalam UserModel
        /// signInSilently : Upaya untuk masuk ke pengguna yang sebelumnya diautentikasi tanpa interaksi.(autoLogin)
        await _googleSignIn.signInSilently().then(
              (value) => _currentUser = value,
            );

        /// ==== proses memasukan data login ke firebase_auth ====
        /// kita juga akan buat credential baru
        /// uratan langkahnya sbb
        /// mendapatkan accessToken dam idToken dari _currentUser
        final googleAuth = await _currentUser!.authentication;

        /// mendapatkan credential dari GoogleAuthProvider
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        /// buat variabel untuk menampung value credential dari proses signInWithCredential(credential)
        UserCredential? userCredential;

        // memasukan data kedalam firebase Auth
        // kita membutuhkan firebase instance
        // dan
        // kita membutuhkan Oauthcredential sebagai pengisi paramater
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        /// ======================================================

        /// sebelum masuk ke home
        /// kita simpan data kedalam firestore
        /// kita buat CollectionReference sbg nama tempat penyimpaanannya
        CollectionReference users = firestore.collection("users");

        /// karena autoLogin, sudah pasti ada datanya, kita tidak perlu mengechek lagi.
        /// kita bisa langsung melakukan update pada lastSignInTime
        await users.doc(_currentUser!.email).update({
          "lastSignInTime":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        });

        /// setelah berhasil dimasukan ke dalam database
        /// data kita ambil lagi , dan kita masukan kedalam model
        /// untuk digunakan didalam aplikasi

        /// ambil data
        final currUser = await users.doc(_currentUser!.email).get();

        /// memasukan data kedalam variabel
        Map<String, dynamic> currentUserData =
            currUser.data() as Map<String, dynamic>;

        /// memasukan data kedalam model
        /// dengan mengupdate keseluruhan data / override / mereplace
        /// menggunakan methode dari GetX baru
        /// dikarenakan ketika awal memasukan data , kita tidak menambahkan data chats
        /// kareana chat merupakan sebuah collection baru
        userModel(UsersModel.fromJson(currentUserData));

        userModel.refresh();

        /// mengambil data dari collection chats , yang berada dalam collection user
        final listChats =
            await users.doc(_currentUser!.email).collection('chats').get();

        /// cek , ada isi nya atau tidak
        if (listChats.docs.isNotEmpty) {
          List<ChatUserModel> dataListChats = [];

          /// looping listChats utuk dapatin semua data
          listChats.docs.forEach(
            (element) {
              var dataChat = element.data();
              var dataChatId = element.id;
              dataListChats.add(
                ChatUserModel(
                  chatId: dataChatId,
                  connection: dataChat['connection'],
                  lastTime: dataChat['lastTime'],
                  totalUnread: dataChat['totalUnread'],
                ),
              );
            },
          );

          /// mengupdate userModel JIKA listChats ADA DATA
          userModel.update((val) {
            val!.chats = dataListChats;
          });

          userModel.refresh();
        } else {
          /// tidak mengupdate userModel JIKA listChats TIDAK ADA DATA
          userModel.update((val) {
            val!.chats = [];
          });
          userModel.refresh();
        }

        /// mengembalikan nilai true
        return true;
      }
      return false;
    } catch (e) {
      Get.defaultDialog(
        title: 'Terjadi Kesalahan',
        middleText: "$e",
        onConfirm: () {
          Get.back();
        },
        textConfirm: 'kembali',
      );

      print("terjadi kesalahan auto login : $e");

      return false;
    }
  }

  Future<bool> skipIntro() async {
    /// logic untuk mengubah isSkipIntroduction menjadi ture
    /// konsepnya , kita check apakah didalam aplikasi sudah pernah terjadi  signIn.
    /// jika pernah, maka kita akan menyinpan data signIn kedalam memori local.
    /// jika dimemori lokal , ada data pernah signIn.
    /// maka saat masuk ke aplikai lagi , tidak akan menampilkan introduction lagi.
    /// kita akan menyimpan data menggunakan get_storage, saat pertama kali login.
    final box = GetStorage();
    if (box.read("skipIntro") != null || box.read("skipIntro") == true) {
      return true;
    }
    return false;
  }

  /// ---------------------------LOGIN_WITH_GOOGLE------------------------------
  /// Membuat fungsi authLogin dengan google
  Future<void> authLogin() async {
    try {
      // signOut :Menandai pengguna saat ini berada dalam status keluar.
      // memastikan pengguna telah signed out dari hp , sebelum melakukan login kembali
      await _googleSignIn.signOut();

      // signIn() : Memulai proses masuk interaktif.
      // Returned Future diselesaikan ke instans [GoogleSignInAccount] untuk proses masuk
      // atau null yang dikembalikan jika proses masuk dibatalkan.
      // Proses otentikasi dipicu hanya jika tidak ada pengguna yang masuk
      // (yaitu saat currentUser == null),
      // jika tidak metode ini mengembalikan Masa Depan yang diselesaikan ke instans pengguna yang sama.
      // Autentikasi ulang hanya dapat dipicu setelah [signOut] atau [disconnect].
      // methode ini untuk mendapatkan google account
      await _googleSignIn.signIn().then(
            (value) => _currentUser = value,
          );

      // mengecek  status login user apakah sedang sign in atau tidak
      // mengembalikan nilai true or false
      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        // kondisi login berhasil
        print("SUDAH BERHASIL LOGIN DENGAN AKUN : ");
        print(_currentUser);
        //
        // mendapatkan accessToken dam idToken dari _currentUser
        final googleAuth = await _currentUser!.authentication;

        // mendapatkan credential dari GoogleAuthProvider
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // memasukan data kedalam firebase Auth
        // kita membutuhkan firebase instance
        // dan
        // kita membutuhkan Oauthcredential sebagai pengisi paramater
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        // print(userCredential);

        /// ------------------------------
        /// sebelum masuk ke home
        /// kita simpan status user bahwa sudah pernah login dan
        /// tidak akan menampilkan introduction kembali.
        /// ketika login kembali, kita chek dulu ,
        /// apakah box ada isi nya ? jika ada , maka kita hapus terlebih dahulu.
        /// hal ini mencegah , agar tidak terjadi kebocoran memori .
        /// kareana menulis box berulang ulang.
        /// karena ada kemungkinan , kita login berulang kali.
        final box = GetStorage();
        if (box.read('skipIntro') != null) {
          box.remove("skipIntro");
        }
        box.write('skipIntro', true);

        /// ------------------------------
        /// sebelum masuk ke home
        /// kita simpan data kedalam firestore
        /// kita buat CollectionReference sbg nama tempat penyimpaanannya
        CollectionReference users = firestore.collection("users");

        /// sebelum ditambahakan kedalam database
        /// kita check dulu , dia pengguna baru atau hanya sekedar login kembali
        /// hal ini terjadi , karena button login dan signUp menjadi satu
        /// pertama kita coba ambil data email yang di buat signIn , sudah ada di database apa tidak
        final chechUser = await users.doc(_currentUser!.email).get();

        if (chechUser.data() == null) {
          /// jika data yang diambil kosong. maka ,
          /// menambahkan data kedalam firestore
          /// doc(): untuk membuat uniq id sendiri, agar tidak di generate oleh firestore
          /// set(): proses setelah doc. yaitu menambahkan data yang akan disimpan di firebase firestore
          await users.doc(_currentUser!.email).set({
            'uid': userCredential!.user!.uid,
            'name': userCredential!.user!.displayName,
            'keyName': userCredential!.user!.displayName!
                .substring(0, 1)
                .toUpperCase(),
            "email": userCredential!.user!.email,
            "photoURL": userCredential!.user!.photoURL ?? 'no image',
            "status": '',
            "creationTime":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updatedAt": DateTime.now().toIso8601String(),
          });

          /// kita buat collection baru didalam user data
          /// jadi kita buat nested collection => collection didalam collection
          users.doc(_currentUser!.email).collection('chats');

          /// disini kita hanya membuat collection chats saja
          /// karena isi collection chats , akan terisi ketika kita menambahkan
          /// teman chats yaitu friendEmail

        } else {
          /// jika ternyata data yang di ambil berdasarkan email , ada isinya
          /// maka hanya akan melakukan update pada lastSignInTime
          await users.doc(_currentUser!.email).update({
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }

        /// setelah berhasil dimasukan ke dalam database
        /// data kita ambil lagi , dan kita masukan kedalam model
        /// untuk digunakan didalam aplikasi

        /// ambil data
        final currUser = await users.doc(_currentUser!.email).get();

        /// memasukan data kedalam variabel
        Map<String, dynamic> currentUserData = {};
        currentUserData = currUser.data() as Map<String, dynamic>;

        /// memasukan data kedalam model
        /// dengan mengupdate keseluruhan data / override / mereplace
        /// menggunakan methode dari GetX baru
        /// dikarenakan ketika awal memasukan data , kita tidak menambahkan data chats
        /// kareana chat merupakan sebuah collection baru
        userModel(UsersModel.fromJson(currentUserData));
        userModel.refresh();

        /// mengambil data dari collection chats , yang berada dalam collection user
        final listChats =
            await users.doc(_currentUser!.email).collection('chats').get();

        /// cek , ada isi nya atau tidak
        if (listChats.docs.isNotEmpty) {
          List<ChatUserModel> dataListChats = [];

          /// looping listChats utuk dapatin semua data
          listChats.docs.forEach(
            (element) {
              var dataChat = element.data();
              var dataChatId = element.id;
              dataListChats.add(
                ChatUserModel(
                  chatId: dataChatId,
                  connection: dataChat['connection'],
                  lastTime: dataChat['lastTime'],
                  totalUnread: dataChat['totalUnread'],
                ),
              );
            },
          );

          /// mengupdate userModel JIKA listChats ADA DATA
          userModel.update((val) {
            val!.chats = dataListChats;
          });
          userModel.refresh();
        } else {
          /// tidak mengupdate userModel JIKA listChats TIDAK ADA DATA
          userModel.update((val) {
            val!.chats = [];
          });
          userModel.refresh();
        }

        /// ------------------------------
        // jika value true
        // maka berhasil login
        // kita ubah isAuth = true
        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
        //

      } else {
        print('Gagal Login !');
        // jika value false
        // maka gagal login
      }
    } catch (error) {
      Get.defaultDialog(title: 'Terjadi kesalahan', middleText: "$error");
      print("terjadi kesalahan $error");
    }
  }

  /// ---------------------------LOGOUT------------------------------
  Future<void> loguotApp() async {
    /// disconnect : ketika sudah logoout, supaya tidak autoLogin lagi
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  /// ---------------------------CHANGE_PROFILE------------------------------
  void changeProfile({required String name, required String status}) {
    String date = DateTime.now().toIso8601String();

    /// menyambungkan ke firebase (atau bisa membuat tabel baru)
    CollectionReference users = firestore.collection("users");

    /// mengupdate data yang ada di collection users
    /// berdasarkan email yang dipilih
    users.doc(_currentUser!.email).update(
      {
        'name': name,
        'keyName': name.substring(0, 1).toUpperCase(),
        "status": status,
        "lastSignInTime":
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        "updatedAt": date
      },
    );

    /// mengupdate model
    userModel.update(
      (user) {
        user!.name = name;
        user.keyName = name.substring(0, 1).toUpperCase();
        user.status = status;
        user.lastSignInTime =
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
        user.updatedAt = date;
      },
    );

    Get.defaultDialog(
      title: 'Succes',
      middleText: 'Berhasil',
      onConfirm: () {
        Get.back();
        Get.back();
        userModel.refresh();
      },
      textConfirm: 'OKE',
    );
  }

  /// ---------------------------UPDATE STATUS------------------------------
  void updateStatus({required String status}) {
    String date = DateTime.now().toIso8601String();

    /// menyambungkan ke firebase (atau bisa membuat tabel baru)
    CollectionReference users = firestore.collection("users");

    /// mengupdate data yang ada di collection users
    /// berdasarkan email yang dipilih
    users.doc(_currentUser!.email).update(
      {
        "status": status,
        "lastSignInTime":
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        "updatedAt": date
      },
    );

    /// mengupdate model
    /// karena ini yang akan menjadi tampilan pada aplikasi
    userModel.update(
      (user) {
        user!.status = status;
        user.lastSignInTime =
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
        user.updatedAt = date;
      },
    );

    Get.defaultDialog(
      title: 'Succes',
      middleText: 'Berhasil',
      onConfirm: () {
        Get.back();
        Get.back();
        userModel.refresh();
      },
      textConfirm: 'OKE',
    );
  }

  /// ---------------------------UPDATE PHOTO PROFILE------------------------------
  void updatePhotoUrl(String url) async {
    String date = DateTime.now().toIso8601String();
    // Update firebase
    CollectionReference users = firestore.collection('users');
    await users.doc(_currentUser!.email).update({
      "photoURL": url,
      "updatedAt": date,
    });

    // Update model
    userModel.update((user) {
      user!.photoURL = url;
      user.updatedAt = date;
    });

    userModel.refresh();
    Get.defaultDialog(
        title: "Success", middleText: "Change photo profile success");
  }

  /// --------------------------- ADD SEARCH FRIEND CONNECTION ------------------------------
  /// kita membutuhkan paramater email tujuan sebagai calon teman chats kita
  void addNewConnection({String? friendEmail}) async {
    var chatId; // menyimpan chat id
    bool flagNewConnection = false; // true => buat connection baru

    /// membuat date untuk Chat
    String date = DateTime.now().toIso8601String();

    /// membuat / masuk ke collection chats dan users
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    /// ada 2 kondisi yang harus kita ketahui
    /// 1. Dia(_currentUser.email) belum pernah buat connection
    /// atau history chat dengan friendEmail
    /// 2. Dia(_currentUser.email) sudah pernah buat connection
    /// atau history chat dengan friendEmail

    /// kita ambil terlebih dahulu semua data ,
    /// berdasarkan currentUser.email pada apps di firestore
    /// Kita ambil data pada collection chats yang ada DIDALAM collection users
    final documentUserChats =
        await users.doc(_currentUser!.email).collection('chats').get();

    /// selanjutnya kita check
    /// documentUserChats ada isi nya apa tidak
    /// jika ada => berarti sudah pernah chat dengan siapapun
    /// jika kosong => berarti belum pernah chat dengan siapapun
    if (documentUserChats.docs.isNotEmpty) {
      // === sudah pernah chat dengan siapapun ===
      // berarti documentUserChatsChats ada data nya minimal 1
      // kita ambil data jika sama dengan friendEmail
      final checkConnectionFriend = await users
          .doc(_currentUser!.email)
          .collection('chats')
          .where("connection", isEqualTo: friendEmail)
          .get();

      /// kita cek data checkConnectionFriend kosong atau tidak
      if (checkConnectionFriend.docs.isNotEmpty) {
        // sudah pernah chat / sudah pernah buat koneksi dengan friendEmail
        flagNewConnection = false;

        // mendapatkan chat_id from collection chats
        chatId = checkConnectionFriend.docs[0].id;
        // kenapa index[0], karena data query berbentuk list
        // dan jka ada connection yang sama dengan friendEmail,
        // datanya PASTI HANYA SATU . dan index ke [0]
      } else {
        // belum pernah chat / belum pernah buat koneksi dengan friendEmail
        // buat koneksi baru .....
        flagNewConnection = true;
      }
    } else {
      // === belum pernah chat dengan siapapun ===
      // berarti documentUserChatsChats tidak ada data (0)
      // buat koneksi baru .....
      flagNewConnection = true;
    }

    /// FIXING COLLECTION Chats

    /// kita cek flagNewConnection true or false
    if (flagNewConnection) {
      // sebelum dibuat chats baru
      // kita check terlebih dahulu pada chats collection,
      // apakah ada data pada connection yang isi nya _currentUser dan friendEmail
      // sehingga ada dua keadaan
      // 1. sudah ada data connection
      // -> misal si A pernah buat koneksi dengan si B, namun belum ada chat
      // sedang si B belum pernah buat koneksi dengan si A.
      // ketika si B akan buat koneksi dengan si A, kita check dulu. agar tidak
      // terjadi dobel dalam membuat dokumen chats.
      // 2. belum ada data connection
      // -> kita akan buat connection baru

      // kita masuk kedalam collection chats
      // kita lakukan query data , dan mensort nya berdasarkan isi emailnya yaitu
      // email yang sedang aktif(_currentUser)
      // dan email tujuan (friendEmail)
      // jika ada yang cocok, maka tidak akan membuat chats baru.
      // dan menggunakan chat_id yang sudah dibuat oleh friendEmail
      // (friendEmail sudah ada koneksi dengan currentUser)
      final docsChats = await chats.where('connection', whereIn: [
        // ketika ada yang cocok dari salah satu dibawah
        // maka dokumen chats akan di ambil mulai dari dokumen id.
        // kalo ada dokumen chat , pasti hanya ada 1 dokumen saja.
        [
          _currentUser!.email, // email user di aplikas
          friendEmail, // email tujuan
        ],
        [
          friendEmail, // email tujuan
          _currentUser!.email, // email user di aplikas
        ]
      ]).get();

      // kita check, docsChats ada datanya apa tidak
      if (docsChats.docs.isNotEmpty) {
        // sudah ada koneksi antara meraka berdua (_currentUser dan friendEmail)

        // kita ambil chat_id
        // pada index ke 0. karena data pada hanya 1.
        var chatsDocsId = docsChats.docs[0].id;

        // mengambil semua data yang ada pada dokumen chats
        var chatsDocsData = docsChats.docs[0].data() as Map<String, dynamic>;

        /// kita tidak boleh langsung mengupdate, dan data lama tidak boleh direplaces
        /// kita tambakan data yang terbaru
        /// kedalam collection chats pada firestore yang berada dalam collection
        /// users.(artinya collection didalam collection => nested collection)
        await users
            .doc(_currentUser!.email)
            .collection('chats')
            .doc(chatsDocsId)
            .set({
          "connection": friendEmail,
          "lastTime": date,
          "totalUnread": 0,
        });

        /// mengupdate userModel yang ada di aplikasi
        /// mengambil data dari collection chats , yang berada dalam collection user
        final listChats =
            await users.doc(_currentUser!.email).collection('chats').get();

        /// cek , ada isi nya atau tidak
        if (listChats.docs.isNotEmpty) {
          List<ChatUserModel> dataListChats = [];

          /// looping listChats utuk dapatin semua data
          listChats.docs.forEach(
            (element) {
              var dataChat = element.data();
              var dataChatId = element.id;
              dataListChats.add(
                ChatUserModel(
                  chatId: dataChatId,
                  connection: dataChat['connection'],
                  lastTime: dataChat['lastTime'],
                  totalUnread: dataChat['totalUnread'],
                ),
              );
            },
          );

          /// mengupdate userModel JIKA model ChatUserModel listChats ADA DATA
          userModel.update((val) {
            val!.chats = dataListChats;
          });
          userModel.refresh();
        } else {
          /// tidak mengupdate userModel JIKA listChats TIDAK ADA DATA
          userModel.update((val) {
            val!.chats = [];
          });
          userModel.refresh();
        }

        chatId = chatsDocsId;

        /// karena userModel merupakan obs
        /// setelah melakukan perubahan , harus melakukan refresh
        userModel.refresh();
      } else {
        /// belum ada koneksi antara meraka berdua (_currentUser dan friendEmail)
        /// buat baru...
        /// memasukan data ke collection chats (buat baru)
        final newChatDoc = await chats.add(
          {
            "connection": [
              _currentUser!.email,
              friendEmail,
            ],
          },
        );

        /// selanjutnya kita buat nested collection dengan naman chat DIDALAM collection chats
        await chats.doc(newChatDoc.id).collection('chat');

        /// memasukan data ke collection chats yang berada di collection users (buat baru)
        await users
            .doc(_currentUser!.email)
            .collection('chats')
            .doc(newChatDoc.id)
            .set({
          "connection": friendEmail,
          "lastTime": date,
          "totalUnread": 0,
        });

        /// mengambil data dari collection chats , yang berada dalam collection user
        /// mengupdate userModel yang ada di aplikasi
        final listChats =
            await users.doc(_currentUser!.email).collection('chats').get();

        /// cek , ada isi nya atau tidak
        if (listChats.docs.isNotEmpty) {
          List<ChatUserModel> dataListChats = [];

          /// looping listChats utuk dapatin semua data
          // ignore: avoid_function_literals_in_foreach_calls
          listChats.docs.forEach(
            (element) {
              var dataChat = element.data();
              var dataChatId = element.id;
              dataListChats.add(
                ChatUserModel(
                  chatId: dataChatId,
                  connection: dataChat['connection'],
                  lastTime: dataChat['lastTime'],
                  totalUnread: dataChat['totalUnread'],
                ),
              );
            },
          );

          /// mengupdate userModel JIKA listChats ADA DATA
          userModel.update((val) {
            val!.chats = dataListChats;
          });
        } else {
          /// tidak mengupdate userModel JIKA listChats TIDAK ADA DATA
          userModel.update((val) {
            val!.chats = [];
          });
        }

        chatId = newChatDoc;

        /// karena userModel merupakan obs
        /// setelah melakukan perubahan , harus melakukan refresh
        userModel.refresh();
      }
    }

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
        .where('penerima', isEqualTo: _currentUser!.email)
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
        .doc(_currentUser!.email)
        .collection("chats")
        .doc(chatId)
        .update({"totalUnread": 0});

    /// setelah itu kita navigasikan ke chat room
    /// dan membawa document id chat
    print("chat connection id $chatId");
    Get.toNamed(
      Routes.CHAT_ROOM,
      arguments: {
        "chat_id": chatId,
        "friendEmail": friendEmail,
      },
    );
  }
}
