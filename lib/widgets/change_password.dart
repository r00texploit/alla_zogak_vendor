import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alla_zogak_vendor/api/user_service.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({Key? key}) : super(key: key);

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  bool loading = false;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String? message;
  TextEditingController password = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController reTypePassword = TextEditingController();
  bool hidePassword = true;
  bool hideNewPassword = true;
  bool hideReTypePassword = true;

  @override
  initState() {
    super.initState();
  }

  submit() async {
    final isVerified = _key.currentState?.validate();
    if (isVerified != null && isVerified) {
      setState(() {
        loading = true;
      });
      try {
        Map<String, dynamic> map = {};
        if (password.text.isNotEmpty) {
          map['password'] = password.text;
        }
        if (newPassword.text.isNotEmpty) {
          map['new_password'] = newPassword.text;
        }
        final resp = await updatePassword(map);
        if (resp.success) {
          setState(() {
            message = "تم تغيير الرمز السري بنجاح";
            loading = false;
          });
        }
      } catch (e) {
        if (e is DioError) {
          if (kDebugMode) {
            print(e.message);
          }
        }
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            height: 5,
            width: MediaQuery.of(context).size.width * .6,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  if (message == null)
                    TextFormField(
                      autofocus: true,
                      controller: password,
                      obscureText: hidePassword,
                      validator: (value) =>
                          value != null ? null : "يجب إدخال الرمز السري الحالي",
                      decoration: InputDecoration(
                        label: const Text("الرمز السري الحالي"),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  if (message == null)
                    TextFormField(
                      autofocus: true,
                      controller: newPassword,
                      obscureText: hideNewPassword,
                      validator: (value) => value != null && value.length < 6
                          ? "الرمز السري يجب ان يكون اكثر من 5 خانات"
                          : value == null
                              ? "يجب إدخال الرمز السري الجديد"
                              : null,
                      decoration: InputDecoration(
                        label: const Text("الرمز السري الجديد"),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hideNewPassword = !hideNewPassword;
                            });
                          },
                          icon: Icon(hideNewPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  if (message == null)
                    TextFormField(
                      autofocus: true,
                      controller: reTypePassword,
                      obscureText: hideReTypePassword,
                      validator: (value) =>
                          value != null && value != newPassword.text
                              ? "الرمز السري يجب ان يطابق"
                              : value == null
                                  ? "يجب إدخال الرمز السري مره أخري"
                                  : null,
                      decoration: InputDecoration(
                        label: const Text('أعد كتابة الرمز السري الجديد'),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hideReTypePassword = !hideReTypePassword;
                            });
                          },
                          icon: Icon(hideReTypePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  if (message != null)
                    const Icon(
                      Icons.done_all,
                      size: 35,
                      color: Colors.green,
                    ),
                  if (message != null)
                    Text(
                      message ?? "",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (message == null)
                    ElevatedButton.icon(
                      onPressed: () => loading ? {} : submit(),
                      icon: loading
                          ? const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label:
                          loading ? const Text("") : const Text("حفظ التغيرات"),
                    ),
                  if (message != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text("إغلاغ"),
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
