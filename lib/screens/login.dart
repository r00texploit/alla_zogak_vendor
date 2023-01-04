import 'package:alla_zogak_vendor/screens/reset_password.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alla_zogak_vendor/api/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  double? toppading;
  int currentpage = 0;
  bool loading = false;
  String? msg;
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  loginIntoApp() async {
    setState(() {
      loading = true;
    });
    try {
      final data = await login({"tel": phone.text, "password": password.text});
      if (data.success) {
        final sh = await SharedPreferences.getInstance();
        sh.setString("token", data.data['token']);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, "home");
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          msg = "رقم الهاتف أو كلمة المرور خطأ";
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/logo.png",
                      width: width / 3.5,
                    ),
                    const SizedBox(height: 5),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const []),
                    const SizedBox(height: 15),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: phone,
                                textInputAction: TextInputAction.next,
                                validator: (value) => value == null
                                    ? "الرجاء إدخال رقم الهاتف"
                                    : null,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    label: const Text("رقم الهاتف"),
                                    hintText: "0xxxxxxxxx"),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: password,
                                obscureText: true,
                                validator: (value) => value == null
                                    ? "الرجاء إدخال الرمز السري"
                                    : null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  label: const Text("الرمز السري"),
                                  hintText: "xxxxxxx",
                                ),
                              ),
                              const SizedBox(
                                height: 10,
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
                              ElevatedButton.icon(
                                style: ButtonStyle(
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
                                onPressed: () async {
                                  final valid = _key.currentState?.validate();
                                  if (valid != null && valid) {
                                    await loginIntoApp();
                                  }
                                },
                                icon: loading == true
                                    ? const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: CircularProgressIndicator(),
                                      )
                                    : const Icon(
                                        Icons.login,
                                      ),
                                label: loading == false
                                    ? const Text(
                                        "تسجيل الدخول",
                                        style: TextStyle(),
                                      )
                                    : const Text(""),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("أو"),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
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
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ResetPasswordScreen()));
                                },
                                child: const Text(
                                  "تغيير الرمز السري",
                                  style: TextStyle(),
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
