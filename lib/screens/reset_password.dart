import 'package:alla_zogak_vendor/api/user_service.dart';
import 'package:alla_zogak_vendor/models/response_model.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  double? toppading;
  int currentpage = 0;
  String? otpVal;
  String? msg;
  OtpFieldController otpController = OtpFieldController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  bool showPassword = true;
  bool loading = false;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  sendOtp() async {
    setState(() {
      loading = true;
      msg = null;
    });
    try {
      bool? valid = _key.currentState?.validate();
      if (valid == true) {
        ResponseModel resp = await sendResetOtp({"tel": phone.text});
        if (resp.success) {
          setState(() {
            loading = false;
            msg = null;
            currentpage = 1;
          });
        } else {
          setState(() {
            loading = false;
            msg = "تحقق من الرقم الذي أدخلته";
          });
        }
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        msg = "تحقق من الرقم الذي أدخلته";
      });
    }
  }

  verifyOtpReset(String otp) async {
    otpVal = otp;
    setState(() {
      loading = true;
      msg = null;
    });
    try {
      bool? valid = _key.currentState?.validate();
      if (valid == true) {
        ResponseModel resp = await verifyResetOtp(otp, {"tel": phone.text});
        if (resp.success) {
          setState(() {
            loading = false;
            msg = null;
            currentpage = 2;
          });
        } else {
          setState(() {
            loading = false;
            msg = "تحقق من الرقم الذي أدخلته";
          });
        }
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        msg = "تحقق من الرقم الذي أدخلته";
      });
    }
  }

  resetPasswordOtp() async {
    setState(() {
      loading = true;
      msg = null;
    });
    try {
      bool? valid = _key.currentState?.validate();
      if (valid == true) {
        ResponseModel resp = await resetPasswordWithOtp(otpVal.toString(), {
          "tel": phone.text,
          "password": password.text,
        });
        if (resp.success) {
          setState(() {
            loading = false;
            msg = null;
          });
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.done),
                  Text("تم تحديث الباسويرد بنجاح"),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, "login");
        } else {
          setState(() {
            loading = false;
            msg = "تحقق من الرقم الذي أدخلته";
          });
        }
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        msg = "تحقق من الرقم الذي أدخلته";
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("إستعادة الحساب"),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const []),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 38.0,
                        left: 28,
                        right: 28,
                      ),
                      child: SizedBox(
                        width: width * .7,
                        child: Form(
                          key: _key,
                          child: Column(
                            children: [
                              if (loading)
                                const Center(
                                  child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: CircularProgressIndicator(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              if (currentpage == 0 && !loading)
                                TextFormField(
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),
                                    label: Text("رقم الهاتف"),
                                  ),
                                ),
                              if (currentpage == 1 && !loading)
                                Center(
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: OTPTextField(
                                      controller: otpController,
                                      length: 4,
                                      width: MediaQuery.of(context).size.width,
                                      textFieldAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      fieldWidth: 45,
                                      fieldStyle: FieldStyle.box,
                                      outlineBorderRadius: 8,
                                      style: const TextStyle(fontSize: 17),
                                      onCompleted: (pin) async {
                                        await verifyOtpReset(pin);
                                      },
                                    ),
                                  ),
                                ),
                              if (currentpage == 2 && !loading)
                                TextFormField(
                                  controller: password,
                                  keyboardType: TextInputType.text,
                                  obscureText: showPassword,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),
                                    label: Text("الرمز السري الجديد"),
                                  ),
                                ),
                              const SizedBox(
                                height: 15,
                              ),
                              if (msg != null)
                                Center(
                                  child: Text(
                                    "$msg",
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              if (msg != null)
                              const SizedBox(
                                height: 5,
                              ),
                              if (currentpage == 0 && !loading)
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.black87,
                                    ),
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 15,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => sendOtp(),
                                  icon: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Text(
                                    "تأكيد",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              if (currentpage == 2 && !loading)
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.black87,
                                    ),
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 15,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => resetPasswordOtp(),
                                  child: Text(
                                    "تغيير الرمز",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
