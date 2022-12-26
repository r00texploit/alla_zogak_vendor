// ignore_for_file: library_private_types_in_public_api

import 'package:alla_zogak_vendor/widgets/change_phone.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alla_zogak_vendor/models/vendors.dart';
import 'package:alla_zogak_vendor/widgets/change_password.dart';

import '../api/user_service.dart';
import '../models/response_model.dart';
import '../widgets/change_location.dart';
import '../widgets/change_profile.dart';
import '../widgets/change_settings.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final GlobalKey _key = GlobalKey();
  Vendors? vendor;
  late Future<void> _initData;
  @override
  void initState() {
    super.initState();
    _initData = _initProfile();
  }

  Future<void> _initProfile() async {
    try {
      ResponseModel resp = await getMyProfile();
      vendor = Vendors.fromJson(resp.data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> refreshProfile() async {
    ResponseModel resp = await getMyProfile();
    setState(() {
      vendor = Vendors.fromJson(resp.data);
    });
  }

  selectImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["jpg", "png", "jpeg"],
      type: FileType.custom,
    );

    if (result != null) {
      final avatar =
          await MultipartFile.fromFile(result.files.first.path as String);
      await updateProfilePhoto({"profile": avatar});
      await refreshProfile();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => refreshProfile(),
        child: FutureBuilder(
          future: _initData,
          builder: (context, snap) {
            switch (snap.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                {
                  return const Center(child: CircularProgressIndicator());
                }
              case ConnectionState.done:
                {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _getHeader(),
                          const Divider(),
                          _myOrder(
                            'تعديل البروفايل',
                            Icons.person_outline,
                            () => showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                              ),
                              backgroundColor: Colors.white,
                              builder: (context) => Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: ChangeProfileWidget(
                                  pull: refreshProfile,
                                  vendor: vendor,
                                ),
                              ),
                            ),
                          ),
                          _myOrder(
                            'تعديل الهاتف',
                            Icons.person_outline,
                            () => showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                              ),
                              backgroundColor: Colors.white,
                              builder: (context) => Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: ChangePhoneWidget(
                                  pull: refreshProfile,
                                  vendor: vendor,
                                ),
                              ),
                            ),
                          ),
                          _myOrder(
                            'عنوان المتجر',
                            Icons.location_on_outlined,
                            () => showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              builder: (context) => Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: ChangeLocationWidget(
                                  pull: refreshProfile,
                                  vendor: vendor,
                                ),
                              ),
                            ),
                          ),
                          _myOrder(
                            'إعدادات التطبيق',
                            Icons.settings,
                            () => showModalBottomSheet(
                              context: context,
                              // useRootNavigator: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                              ),
                              backgroundColor: Colors.white,
                              builder: (context) => Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: const ChangeSettingsWidget(),
                              ),
                            ),
                          ),
                          _myOrder(
                            'تغيير الرمز السري',
                            Icons.password_outlined,
                            () => showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                              ),
                              backgroundColor: Colors.white,
                              builder: (context) => Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: const ChangePasswordWidget(),
                              ),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 100,
                          ),
                          _myOrder('تسجيل الخروج', Icons.exit_to_app, () async {
                            final sh = await SharedPreferences.getInstance();
                            sh.remove("token");
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacementNamed(context, "login");
                          }),
                        ],
                      ),
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }

  Widget _getHeader() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 10.0, top: 10),
        child: Row(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsetsDirectional.only(bottom: 17),
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: Image.network(
                            'https://yoo2.smart-node.net${vendor?.avatar}',
                            errorBuilder: (context, error, stackTrace) =>
                                CircleAvatar(
                              backgroundColor: Colors.white54,
                              child: Icon(
                                Icons.person,
                                size: 78,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            key: _key,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 15,
                        left: 14,
                        child: IconButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          icon: const Icon(
                            Icons.change_circle,
                            size: 35,
                            color: Colors.black,
                          ),
                          onPressed: () => selectImages(),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً, ${vendor?.name.toUpperCase()}',
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Text(
                      vendor?.tel ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Colors.black),
                    )
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  _myOrder(String text, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: ListTile(
          dense: true,
          title: Text(
            text,
            style: TextStyle(fontSize: 15,color: Colors.grey[800],),
          ),
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              color: Colors.grey[800],
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
