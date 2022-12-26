import 'dart:io';
import 'package:alla_zogak_vendor/models/product_option_values.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
// ignore: library_prefixes
import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:alla_zogak_vendor/models/category_option_values.dart';
import 'package:alla_zogak_vendor/models/products.dart';
import 'package:alla_zogak_vendor/api/category_service.dart';
import 'package:alla_zogak_vendor/models/categories.dart';
import 'package:alla_zogak_vendor/models/category_options.dart';
import 'package:alla_zogak_vendor/models/product_images.dart';
import 'package:alla_zogak_vendor/models/product_options.dart';

import '../api/product_service.dart';
import '../models/response_model.dart';
import 'add_update_product_option.dart';

class AddProductWidget extends StatefulWidget {
  const AddProductWidget({Key? key}) : super(key: key);

  @override
  State<AddProductWidget> createState() => _AddProductWidgetState();
}

class _AddProductWidgetState extends State<AddProductWidget> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Products? prod;
  ProductOptions? prodOpt;
  List<ProductImages> prodImages = [];
  List<Categories> list = [];
  List<CategoryOptions> catsOptions = [];
  List<File> images = [];
  String? imagesErr;
  List<ProductOptionValues> productOtpionValues = [];
  TextEditingController textName = TextEditingController();
  TextEditingController textPrice = TextEditingController();
  TextEditingController textDesc = TextEditingController();
  TextEditingController selectedCat = TextEditingController();
  TextEditingController selectedCatOpt = TextEditingController();
  bool catsLoaded = false;
  bool loading = false;

  List<CategoryOptionValues> get catsOptionValues {
    if (prodOpt != null && selectedCatOpt.text.isNotEmpty) {
      List<CategoryOptions> li = catsOptions
          .where((e) => e.id.toString() == selectedCatOpt.text)
          .toList();
      if (li.isNotEmpty && li[0].categoryOptionValues != null) {
        List<CategoryOptionValues> cv =
            li[0].categoryOptionValues as List<CategoryOptionValues>;
        return cv;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  selectImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ["jpg", "png", "jpeg"],
      type: FileType.custom,
    );

    if (result != null) {
      for (var file in result.files) {
        setState(() {
          if (images.length < 8) {
            images.add(File(file.path as String));
          }
        });
      }
    } else {
      // User canceled the picker
    }
  }

  Future<bool> saveProductOtpValues(Map<String, dynamic> data) async {
    try {
      data.addAll({"product_id": prod?.id, "product_option_id": prodOpt?.id});
      final resp = await addProductOtpValues(data);
      if (resp.success) {
        final dt = ProductOptionValues.fromJson(resp.data);
        setState(() {
          productOtpionValues.add(dt);
        });
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      if (kDebugMode) {
        print([e, s]);
      }
      return false;
    }
  }

  Future<bool> updateProductOtpValues(int id, Map<String, dynamic> data) async {
    try {
      final resp = await updateOtpValues(id, data);
      if (resp.success) {
        final dt = ProductOptionValues.fromJson(resp.data);
        int? index = productOtpionValues.indexWhere((el) => el.id == dt.id);
        setState(() {
          if (index != -1) {
            productOtpionValues[index] = dt;
          }
        });
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      if (kDebugMode) {
        print([e, s]);
      }
      return true;
    }
  }

  selectOpt(String val) {
    List<Categories> li = list.where((e) => e.id == int.parse(val)).toList();
    setState(() {
      selectedCat.text = val;
      if (li.isNotEmpty && li[0].categoryOptions != null) {
        catsOptions = li.first.categoryOptions ?? [];
      }
      selectedCatOpt.text =
          catsOptions.isEmpty ? "not" : catsOptions.first.id.toString();
    });
  }

  addProduct() async {
    setState(() {
      loading = true;
    });
    final resp = await createProduct({
      "name": textName.text,
      "price": double.parse(textPrice.text).floor(),
      "description": textDesc.text,
      "product_category_id": int.parse(selectedCat.text),
      "category_option_id": int.parse(selectedCatOpt.text),
    });
    if (resp.success) {
      setState(() {
        prod = Products.fromJson(resp.data["product"]);
        prodOpt = ProductOptions.fromJson(resp.data["option"]);
      });
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  addImages() async {
    setState(() {
      loading = true;
    });
    List<MultipartFile> formData = [];
    for (var image in images) {
      formData.add(await MultipartFile.fromFile(image.path));
    }

    final resp = await addProductImages({"image[]": formData}, prod?.id);
    if (resp.success) {
      setState(() {
        prodImages = List.generate(
            resp.data.length, (i) => ProductImages.fromJson(resp.data[i]));
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Card(
            child: Form(
              key: _key,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "أضف خيارات المنتج",
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    if (prod == null && prodImages.isEmpty && prodOpt == null)
                      product(),
                    if (prod != null && prodOpt != null && prodImages.isEmpty)
                      imageWidget(),
                    if (prod != null &&
                        prodOpt != null &&
                        prodImages.isNotEmpty)
                      optionValues(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (prod == null)
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.8)),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 10)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            label: const Text("إلغاء"),
                          ),
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 20)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            backgroundColor:
                                MaterialStateProperty.all(disabled()),
                          ),
                          onPressed: () {
                            final valid = _key.currentState?.validate();
                            if (valid != null && valid) {
                              if (prod == null && prodOpt == null) {
                                addProduct();
                              }
                              if (prod != null &&
                                  prodOpt != null &&
                                  images.isNotEmpty &&
                                  prodImages.isEmpty &&
                                  images.isNotEmpty) {
                                addImages();
                              }
                              if (prod != null &&
                                  prodOpt != null &&
                                  // images.isNotEmpty &&
                                  prodImages.isEmpty &&
                                  images.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.red,
                                        content:
                                            Text("الرجاء أضافة صور للمنتج")));
                              }
                              if (prod != null &&
                                  prodOpt != null &&
                                  images.isNotEmpty &&
                                  prodImages.isNotEmpty &&
                                  productOtpionValues.isNotEmpty) {
                                Navigator.pop(context);
                              }
                              if (prod != null &&
                                  prodOpt != null &&
                                  images.isNotEmpty &&
                                  prodImages.isNotEmpty &&
                                  productOtpionValues.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            "الرجاء أضافة خيارات المنتج")));
                              }
                            }
                          },
                          icon: loading
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(prod == null ||
                                      prodOpt == null ||
                                      prodImages.isEmpty
                                  ? Icons.forward
                                  : prod == null ||
                                          prodOpt == null ||
                                          prodImages.isNotEmpty
                                      ? Icons.done
                                      : Icons.save),
                          label: loading
                              ? const Text('')
                              : Text(prod == null ||
                                      prodOpt == null ||
                                      prodImages.isEmpty
                                  ? "التالي"
                                  : prod == null ||
                                          prodOpt == null ||
                                          prodImages.isNotEmpty
                                      ? "أكتمل"
                                      : "إنشاء"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color disabled() {
    final valid = _key.currentState?.validate();
    if (valid != null && valid && selectedCatOpt.text != "not") {
      return Theme.of(context).primaryColor;
    } else {
      return Theme.of(context).primaryColor.withOpacity(0.5);
    }
  }

  Widget optionValues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .6,
          child: ListView.builder(
            itemCount: productOtpionValues.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://yoo2.smart-node.net${productOtpionValues[i].productImages?.image}",
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/3.png",
                                  fit: BoxFit.fill,
                                  scale: 1,
                                  key: GlobalKey(),
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.info),
                                ),
                              ),
                            ),
                            if (productOtpionValues[i]
                                    .categoryOpitionValues
                                    ?.value !=
                                null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الوصف :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${productOtpionValues[i].categoryOpitionValues?.value}",
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            if (productOtpionValues[i].productColors != null)
                              SizedBox(
                                child: Row(
                                  children: [
                                    const Text(
                                      "اللون:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        height: 1.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(
                                            productOtpionValues[i]
                                                .productColors!
                                                .r,
                                            productOtpionValues[i]
                                                .productColors!
                                                .g,
                                            productOtpionValues[i]
                                                .productColors!
                                                .b,
                                            1),
                                        border: Border.all(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الكمية المتبقيه :',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "${productOtpionValues[i].qty}",
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: InkWell(
                            onTap: () => showModalBottomSheet(
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
                                child: AddUpdateProductOption(
                                  prodImages: prodImages,
                                  catsOptionValues: catsOptionValues,
                                  productOptionValues: productOtpionValues[i],
                                  updateOption: updateProductOtpValues,
                                ),
                              ),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.edit_note,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => showModalBottomSheet(
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
              child: AddUpdateProductOption(
                prodImages: prodImages,
                catsOptionValues: catsOptionValues,
                newOption: saveProductOtpValues,
              ),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text("أضف خيار"),
        )
      ],
    );
  }

  Widget imageWidget() {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 3,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          childAspectRatio: 1.0,
          children: List.generate(images.length, (i) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.file(
                      images[i],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                      bottom: 30,
                      left: 30,
                      child: IconButton(
                        iconSize: 30,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          setState(() {
                            images.removeAt(i);
                          });
                        },
                        icon: const Icon(
                          Icons.cancel,
                          size: 30,
                          color: Colors.red,
                        ),
                      ))
                ],
              ),
            );
          }),
        ),
        if (images.length < 8)
          ElevatedButton.icon(
            onPressed: () => selectImages(),
            icon: const Icon(Icons.image),
            label: const Text("إختار بعض الصور للمنتج"),
          )
      ],
    );
  }

  Widget product() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: textName,
          validator: (value) =>
              value == null || value.isEmpty ? "أدخل أسم المنتج" : null,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(label: Text("أسم المنتج")),
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: textPrice,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              value == null || value.isEmpty ? "أدخل سعر المنتج" : null,
          decoration: const InputDecoration(label: Text("سعر المنتج")),
        ),
        TextFormField(
          minLines: 2,
          maxLines: 3,
          controller: textDesc,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) =>
              value == null || value.isEmpty ? "أدخل وصف المنتج" : null,
          decoration: const InputDecoration(label: Text("وصف المنتج")),
        ),
        FutureBuilder(
            future: getAllCategories(),
            builder: (context, AsyncSnapshot<ResponseModel> snap) {
              if (snap.hasData && !catsLoaded) {
                list = List.generate(snap.data?.data.length,
                    (i) => Categories.fromJson(snap.data?.data[i]));
                catsOptions = list[0].categoryOptions ?? [];
                catsLoaded = true;
              }
              return Column(
                children: [
                  SelectFormField(
                    type: SelectFormFieldType.dialog,
                    controller: selectedCat,
                    labelText: 'الفئه',
                    autovalidate: true,
                    validator: (value) =>
                        value == null || value.isEmpty ? "أختار الفئه" : null,
                    items: List.generate(
                        list.length,
                        (i) => {
                              'value': list[i].id.toString(),
                              'label': list[i].nameAr,
                            }),
                    onChanged: (val) => selectOpt(val),
                    onSaved: (val) {
                      if (kDebugMode) {
                        print(val);
                      }
                    },
                  ),
                  SelectFormField(
                    type: SelectFormFieldType.dialog,
                    autovalidate: true,
                    controller: selectedCatOpt,
                    validator: (value) =>
                        value == null || value.isEmpty ? "أختار الصنف" : null,
                    labelText: 'الصنف',
                    items: catsOptions.isNotEmpty
                        ? List.generate(
                            catsOptions.length,
                            (i) => {
                                  'value': catsOptions[i].id.toString(),
                                  'label': catsOptions[i].categoryOption,
                                })
                        : [
                            {
                              'value': "not",
                              'label': "نتأسف لا يوجد اصناف",
                            }
                          ],
                    onChanged: (val) {
                      setState(() {
                        selectedCatOpt.text = val;
                      });
                    },
                    onSaved: (val) {
                      if (kDebugMode) {
                        print(val);
                      }
                    },
                  )
                ],
              );
            })
      ],
    );
  }
}
