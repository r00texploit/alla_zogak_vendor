import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../api/user_service.dart';
import '../models/vendors.dart';

class ChangePhoneWidget extends StatefulWidget {
  final Vendors? vendor;
  final Future<void> Function() pull;
  const ChangePhoneWidget({Key? key, required this.pull, this.vendor})
      : super(key: key);
  @override
  State<ChangePhoneWidget> createState() => _ChangePhoneWidgetState();
}

class _ChangePhoneWidgetState extends State<ChangePhoneWidget> {
  bool loading = false;
  int step = 1;
  String? msg;
  String? validOtp;
  OtpFieldController otpController = OtpFieldController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController tel = TextEditingController();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      send();
    });
  }

  send() async {
    setState(() {
      loading = true;
      msg = null;
    });
    await sendOtp();
    setState(() {
      step = 1;
      loading = false;
      msg = null;
    });
  }

  submit() async {
    setState(() {
      loading = true;
      msg = null;
    });
    try {
      Map<String, String> map = {};
      if (tel.text.isNotEmpty) {
        map['tel'] = tel.text;
      }
      final resp = await updatePhone(validOtp, map);
      if (resp.success) {
        setState(() {
          loading = false;
          msg = null;
          step = 2;
        });
        await widget.pull();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        setState(() {
          loading = false;
          msg = "حدث خطأ ما";
          step = 2;
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

  validateOtp(String otp, BuildContext context) async {
    validOtp = otp;
    setState(() {
      loading = true;
      msg = null;
      step = 0;
    });
    try {
      final resp = await verifyOtp(otp);
      if (resp.success) {
        setState(() {
          loading = false;
          msg = null;
          step = 2;
        });
      } else {
        setState(() {
          loading = false;
          msg = "الرمز الذي أدخلته خاطئ";
          step = 1;
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
        step = 1;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
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
                  const SizedBox(
                    height: 5.0,
                  ),
                  if (step == 1 && loading)
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              "تم الأن إرسال الرمز السري ل ${widget.vendor?.tel}"),
                          SizedBox(
                            height: 45,
                            width: 45,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (step == 2 && loading)
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 45,
                            width: 45,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (step == 1 && !loading)
                    const Center(
                      child: Text(
                        "تم إرسال الرمز السري",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  if (step == 1 && !loading)
                    const SizedBox(
                      height: 10.0,
                    ),
                  if (step == 1 && !loading)
                    Center(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: OTPTextField(
                            controller: otpController,
                            length: 4,
                            width: MediaQuery.of(context).size.width,
                            textFieldAlignment: MainAxisAlignment.spaceEvenly,
                            fieldWidth: 45,
                            fieldStyle: FieldStyle.underline,
                            outlineBorderRadius: 8,
                            style: const TextStyle(fontSize: 17),
                            onCompleted: (pin) async {
                              await validateOtp(pin, context);
                            }),
                      ),
                    ),
                  if (step == 1 && !loading)
                    const SizedBox(
                      height: 15,
                    ),
                  if (step == 2 && !loading)
                    const SizedBox(
                      height: 15,
                    ),
                  if (step == 2 && !loading)
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: tel,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value == null ? "الرجاء إدخال رقم الهاتف" : null,
                      decoration: InputDecoration(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * .8),
                        hintText: '0xxxxxxxxx',
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        label: const Text("رقم الهاتف"),
                      ),
                    ),
                  if (msg != null)
                    Center(
                      child: Text(
                        '$msg',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  if (step == 2 && !loading)
                    const SizedBox(
                      height: 15,
                    ),
                  if (step == 2 && !loading)
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                        ),
                      ),
                      onPressed: () {
                        final valid = _key.currentState?.validate();
                        if (!loading && valid == true) {
                          submit();
                        }
                      },
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
                  const SizedBox(
                    height: 25.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
