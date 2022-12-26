import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alla_zogak_vendor/api/user_service.dart';

import '../models/vendors.dart';

class ChangeProfileWidget extends StatefulWidget {
  final Vendors? vendor;
  final Future<void> Function() pull;
  const ChangeProfileWidget({Key? key, required this.pull, this.vendor})
      : super(key: key);
  @override
  State<ChangeProfileWidget> createState() => _ChangeProfileWidgetState();
}

class _ChangeProfileWidgetState extends State<ChangeProfileWidget> {
  bool loading = false;
  TextEditingController name = TextEditingController();

  @override
  initState() {
    super.initState();
    name.text = widget.vendor?.name ?? "";
  }

  submit() async {
    setState(() {
      loading = true;
    });
    try {
      Map<String, String> map = {};
      if (name.text.isNotEmpty) {
        map['name'] = name.text;
      }
      final resp = await updateProfile(map);
      if (resp.success) {
        setState(() {
          loading = false;
        });
        await widget.pull();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
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
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: name,
                    decoration: const InputDecoration(
                      label: Text("أسم المتجر"),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
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
