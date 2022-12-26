import 'package:alla_zogak_vendor/models/category_option_values.dart';
import 'package:alla_zogak_vendor/models/product_option_values.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as color_picker;
import 'package:select_form_field/select_form_field.dart';
import '../models/product_images.dart';
import 'image_selector.dart';

class AddUpdateProductOption extends StatefulWidget {
  final List<ProductImages> prodImages;
  final List<CategoryOptionValues> catsOptionValues;
  final ProductOptionValues? productOptionValues;
  final Future<bool> Function(Map<String, dynamic> data)? newOption;
  final Future<bool> Function(int id, Map<String, dynamic> data)? updateOption;
  const AddUpdateProductOption({
    super.key,
    required this.prodImages,
    required this.catsOptionValues,
    this.productOptionValues,
    this.newOption,
    this.updateOption,
  });

  @override
  State<AddUpdateProductOption> createState() => _AddUpdateProductOptionState();
}

class _AddUpdateProductOptionState extends State<AddUpdateProductOption> {
  bool loading = false;
  int initImage = 0;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map? color;

  @override
  void initState() {
    if (widget.productOptionValues != null) {
      int index = widget.prodImages.indexWhere(
          (el) => el.id == widget.productOptionValues?.productImageId);
      if (index != -1) {
        initImage = index;
      }
      if (widget.productOptionValues?.qty != null) {
        _qty.text = widget.productOptionValues!.qty.toString();
      }
      if (widget.productOptionValues?.value != null) {
        _controller.text = widget.productOptionValues!.value.toString();
      }
      if (widget.productOptionValues?.productColors != null) {
        color = {};
        if (color != null) {
          color!['r'] = widget.productOptionValues?.productColors?.r;
          color!['g'] = widget.productOptionValues?.productColors?.g;
          color!['b'] = widget.productOptionValues?.productColors?.b;
        }
      }
    }
    super.initState();
  }

  submit() async {
    final valid = _key.currentState?.validate();
    if (valid == true) {
      setState(() {
        loading = true;
      });
      try {
        if (widget.newOption != null) {
          final val = await widget.newOption!({
            "colors": color,
            "product_image_id": widget.prodImages[initImage].id,
            "qty": double.parse(_qty.text).floor(),
            "value": _controller.text,
          });
          if (val) {
            setState(() {
              loading = false;
            });
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          } else {
            setState(() {
              loading = false;
            });
          }
        } else {
          if (widget.productOptionValues != null) {
            final Map<String, dynamic> map = {
              "qty": double.parse(_qty.text).floor(),
              "value": _controller.text,
            };
            if (color!['r'] != widget.productOptionValues?.productColors?.r &&
                color!['g'] != widget.productOptionValues?.productColors?.g &&
                color!['b'] != widget.productOptionValues?.productColors?.b) {
              map['colors'] = color;
            } else {
              map['colors'] = null;
            }
            if (widget.prodImages[initImage].id !=
                widget.productOptionValues?.productImageId) {
              map['product_image_id'] = widget.prodImages[initImage].id;
            } else {
              map['product_image_id'] = null;
            }
            final val =
                await widget.updateOption!(widget.productOptionValues!.id, map);
            if (val) {
              setState(() {
                loading = false;
              });
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            } else {
              setState(() {
                loading = false;
              });
            }
          } else {
            setState(() {
              loading = false;
            });
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        setState(() {
          loading = false;
        });
      }
      setState(() {
        loading = false;
      });
    }
  }

  selectColor() {
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => Center(
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * .9,
          height: MediaQuery.of(context).size.height * .8,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              color_picker.MaterialPicker(
                onColorChanged: (c) {
                  color = {};
                  if (color != null) {
                    setState(() {
                      color!['r'] = c.red;
                      color!['g'] = c.green;
                      color!['b'] = c.blue;
                    });
                  }
                },
                pickerColor: Colors.black,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.colorize_sharp),
                label: const Text("إختيار"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future select(int i) async {
    setState(() {
      initImage = i;
    });
  }

  selectImageCover() {
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => ImageSelector(
        images: widget.prodImages.map((e) => e.image).toList(),
        onSelect: select,
        onChanged: (int i) {
          if (kDebugMode) {
            print(i);
          }
        },
        initialIndex: initImage,
      ),
    );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "الصوره: ",
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                          ),
                          IconButton(
                            onPressed: () => selectImageCover(),
                            icon: const CircleAvatar(
                              radius: 40,
                              child: Icon(
                                Icons.change_circle,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://yoo2.smart-node.net${widget.prodImages[initImage].image}",
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/3.png",
                            fit: BoxFit.fill,
                            scale: 1,
                            key: GlobalKey(),
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.info),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "اللون: ",
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                          ),
                          IconButton(
                            onPressed: () => selectColor(),
                            icon: const CircleAvatar(
                              radius: 40,
                              child: Icon(
                                Icons.colorize,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (color != null)
                        Container(
                          height: 25,
                          width: 25,
                          color: Color.fromRGBO(
                              color!['r'], color!['g'], color!['b'], 1),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .88,
                        child: SelectFormField(
                          type: SelectFormFieldType.dropdown,
                          controller: _controller,
                          labelText: 'الوحدة',
                          autovalidate: true,
                          validator: (value) => null,
                          items: List.generate(
                              widget.catsOptionValues.length,
                              (i) => {
                                    'value': widget.catsOptionValues[i].id
                                        .toString(),
                                    'label': widget.catsOptionValues[i].value,
                                  }),
                          onSaved: (val) {
                            if (kDebugMode) {
                              print(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .88,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _qty,
                          validator: (value) => value == null || value.isEmpty
                              ? "الرجاء إضافة الكميه المتوفره"
                              : null,
                          decoration: const InputDecoration(
                              label: Text("الكميه المتوفره")),
                        ),
                      ),
                    ],
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
                        : const Icon(Icons.add),
                    label: loading ? const Text("") : const Text("إضافه"),
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
