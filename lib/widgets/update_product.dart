import 'package:alla_zogak_vendor/models/products.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api/product_service.dart';

class UpdateProductWidget extends StatefulWidget {
  final Products? product;
  final Future<void> Function() pull;
  const UpdateProductWidget({Key? key, required this.pull, this.product})
      : super(key: key);
  @override
  State<UpdateProductWidget> createState() => _UpdateProductWidgetState();
}

class _UpdateProductWidgetState extends State<UpdateProductWidget> {
  bool loading = false;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController desc = TextEditingController();

  @override
  initState() {
    super.initState();
    name.text = widget.product?.name ?? "";
    price.text = widget.product?.price.toString() ?? "";
    desc.text = widget.product?.description ?? "";
  }

  submit() async {
    final valid = _key.currentState?.validate();
    if (valid == true) {
    setState(() {
      loading = true;
    });
    try {
      Map<String, dynamic> map = {};
      if (name.text.isNotEmpty) {
        map['name'] = name.text;
      }
      if (price.text.isNotEmpty) {
        map['price'] = int.parse(price.text);
      }
      if (desc.text.isNotEmpty) {
        map['description'] = desc.text;
      }
      final resp = await updateProductDetails(widget.product!.id,map);
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
                  TextFormField(
                    autofocus: true,
                    controller: name,
                    decoration: const InputDecoration(
                      label: Text("أسم المنتج"),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("سعر المنتج"),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: desc,
                    keyboardType: TextInputType.text,
                    maxLines: 5,
                    minLines: 3,
                    decoration: const InputDecoration(
                      label: Text("سعر المنتج"),
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
