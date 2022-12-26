import 'package:alla_zogak_vendor/api/category_service.dart';
import 'package:alla_zogak_vendor/models/product_option_values.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alla_zogak_vendor/api/product_service.dart';
import '../models/category_option_values.dart';
import '../models/product_images.dart';
import '../models/products.dart';
import '../models/response_model.dart';
import '../widgets/add_update_product_option.dart';
import '../widgets/image_selector.dart';
import '../widgets/update_product.dart';

class ProductSc extends StatefulWidget {
  final Products product;
  const ProductSc({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductSc> createState() => _ProductScState();
}

class _ProductScState extends State<ProductSc> {
  // final List<GlobalKey> _keys = [];
  final CarouselController _controller = CarouselController();
  List<CategoryOptionValues> catsOptionValues = [];
  late int cover = 0;
  Products? _product;
  bool loading = false;
  bool discountLoading = false;
  TextEditingController discount = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late Future<void> _initProductData;
  @override
  void initState() {
    super.initState();
    _initProductData = _initPage();
    for (var i = 0; i < widget.product.productImages!.length; i++) {
      if (widget.product.productImages![i].isCover == true) {
        cover = i;
      }
    }
  }

  Future<void> _initPage() async {
    try {
      ResponseModel resp = await productDetails(widget.product.id);
      if (resp.success) {
        if (kDebugMode) {
          print(resp.data);
        }
        setState(() {
          _product = Products.fromJson(resp.data);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  selectImages(int id) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["jpg", "png", "jpeg"],
        type: FileType.custom,
      );

      if (result != null) {
        final avatar =
            await MultipartFile.fromFile(result.files.first.path as String);
        final resp = await updateProductImage(id, {"image": avatar});
        if (resp.success) {
          final index =
              widget.product.productImages?.indexWhere((e) => e.id == id);
          setState(() {
            widget.product.productImages![index as int] =
                ProductImages.fromJson(resp.data);
          });
        }
      } else {
        // User canceled the picker
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<bool> saveProductOtpValues(Map<String, dynamic> data) async {
    try {
      data.addAll({
        "product_id": _product?.id,
        "product_option_id": _product?.productOptions![0].id
      });
      final resp = await addProductOtpValues(data);
      if (resp.success) {
        final dt = ProductOptionValues.fromJson(resp.data);
        if (_product?.productOptions![0].productOptionValues != null) {
          setState(() {
            _product?.productOptions![0].productOptionValues?.add(dt);
          });
        } else {
          _initProductData = _initPage();
        }
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
        if (_product?.productOptions![0].productOptionValues != null) {
          int? index = _product?.productOptions![0].productOptionValues
              ?.indexWhere((el) => el.id == dt.id);
          setState(() {
            if (index != null && index != -1) {
              _product?.productOptions![0].productOptionValues![index] = dt;
            }
          });
        } else {
          _initProductData = _initPage();
        }
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

  newOption() async {
    setState(() {
      loading = true;
    });
    try {
      if (catsOptionValues.isEmpty) {
        ResponseModel resp = await getCategoryOptions(
            _product!.productOptions![0].categoryOptionId);
        if (resp.success) {
          catsOptionValues = List.generate(resp.data.length,
              (i) => CategoryOptionValues.fromJson(resp.data[i]));
        }
      }
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        backgroundColor: Colors.white,
        builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: AddUpdateProductOption(
            prodImages: _product?.productImages ?? [],
            catsOptionValues: catsOptionValues,
            newOption: saveProductOtpValues,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() {
      loading = false;
    });
  }

  updateOption(ProductOptionValues opt) async {
    setState(() {
      loading = true;
    });
    try {
      if (catsOptionValues.isEmpty) {
        ResponseModel resp = await getCategoryOptions(
            _product!.productOptions![0].categoryOptionId);
        if (resp.success) {
          catsOptionValues = List.generate(resp.data.length,
              (i) => CategoryOptionValues.fromJson(resp.data[i]));
        }
      }
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        backgroundColor: Colors.white,
        builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: AddUpdateProductOption(
            prodImages: _product?.productImages ?? [],
            catsOptionValues: catsOptionValues,
            productOptionValues: opt,
            updateOption: updateProductOtpValues,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool?> updateDiscount() async {
    final valid = _form.currentState?.validate();
    if (valid == true) {
      setState(() {
        discountLoading = true;
      });
      try {
        Map<String, dynamic> map = {};
        if (discount.text.isNotEmpty) {
          map['discount'] = discount.text;
        }
        final resp = await updateProductDetails(widget.product.id, map);
        if (resp.success) {
          setState(() {
            _product?.discount = int.parse(discount.text);
            discountLoading = false;
          });
          return resp.success;
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        setState(() {
          discountLoading = false;
        });
        return null;
      }
      setState(() {
        discountLoading = false;
      });
      return null;
    }else{
      return null;
    }
  }

  _addOrEditDiscount(String type) async {
    if (type == "edit") {
      discount.text = "${_product?.discount}";
    }
    if (type == "edit" || type == "add") {
      await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: TextFormField(
                        controller: discount,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) =>
                            value != null && value.isNotEmpty && value == "0"
                                ? 'يجب ان تكون القيمة أعلي من 0'
                                : value != null &&
                                        value.isNotEmpty &&
                                        int.parse(value) > 99
                                    ? "يجب ان تكون القيمه أقل من 100"
                                    : null,
                        decoration: const InputDecoration(
                          hintText: "0%",
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: discountLoading
                          ? const SizedBox(
                              width: 45,
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                final val = await updateDiscount();
                                if (val == true) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text("حفظ التغيير"),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      setState(() {
        discountLoading = true;
      });
      final resp =
          await updateProductDetails(widget.product.id, {"discount": null});
      if (resp.success) {
        setState(() {
          _product?.discount = null;
          discountLoading = false;
        });
      } else {
        setState(() {
          discountLoading = false;
        });
      }
    }
  }

  updateDetails() {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        backgroundColor: Colors.white,
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: UpdateProductWidget(
                product: _product,
                pull: () async {
                  _initProductData = _initPage();
                },
              ),
            ));
  }

  Widget _buildProductDetailsDisplay(Products productss, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        _product != null ? _product!.name : productss.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        widget.product.productOptions != null &&
                                widget.product.productOptions!.isNotEmpty &&
                                widget.product.productOptions![0]
                                        .categoryOption !=
                                    null
                            ? '${widget.product.productOptions![0].categoryOption?.categoryOption}'
                            : '',
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_product != null ? _product?.discount != null? (_product!.price / (_product!.discount! * 0.1)).ceil() : _product?.price : productss.price} ج.س',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    if(_product?.discount != null)
                    Text(
                      '${_product?.price ?? productss.price} ج.س',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_product != null)
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: const Text(
                              'الخصم :',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              "${_product!.discount ?? 0} %",
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (_product?.discount == null)
                            InkWell(
                              onTap: () => _addOrEditDiscount("add"),
                              child: Container(
                                width: 45,
                                height: 45,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 25,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          if (_product?.discount != null)
                            InkWell(
                              onTap: () => _addOrEditDiscount("delete"),
                              child: Container(
                                width: 45,
                                height: 45,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.delete,
                                    size: 25,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          if (_product?.discount != null)
                            const SizedBox(
                              height: 8,
                            ),
                          if (_product?.discount != null)
                            InkWell(
                              onTap: () => _addOrEditDiscount("edit"),
                              child: Container(
                                width: 45,
                                height: 45,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit,
                                    size: 25,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          RichText(
            text: const TextSpan(
              text: "تاريخ النشر",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              text: DateFormat("yyyy-mm-dd   hh:mm a", "ar")
                  .format(productss.createdAt),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: const Text(
                          'الوصف :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          _product != null
                              ? _product!.description
                              : productss.description,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_product != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: InkWell(
                        onTap: () => updateDetails(),
                        child: Container(
                          width: 45,
                          height: 45,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50)),
                          child: const Center(
                            child: Icon(
                              Icons.edit,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _optionValues(List<ProductOptionValues> opts) {
    return ListView.builder(
      itemCount: opts.length,
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
                              "https://yoo2.smart-node.net${opts[i].productImages?.image}",
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
                      if (opts[i].categoryOpitionValues?.value != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الوصف :',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${opts[i].categoryOpitionValues?.value}",
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
                      if (opts[i].productColors != null)
                        SizedBox(
                          child: Row(
                            children: [
                              const Text(
                                "اللون:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.5,
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
                                      opts[i].productColors!.r,
                                      opts[i].productColors!.g,
                                      opts[i].productColors!.b,
                                      1),
                                  border: Border.all(
                                    color: Colors.grey,
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
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${opts[i].qty}",
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
                      onTap: () => updateOption(opts[i]),
                      child: Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50)),
                        child: const Icon(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black54, //change your color here
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product_image_${widget.product.id}',
                  child: CarouselSlider.builder(
                    itemBuilder: (context, i, realIndex) {
                      return Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://yoo2.smart-node.net${widget.product.productImages![i].image}",
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/3.png",
                                  fit: BoxFit.fill,
                                  scale: 1,
                                  key: GlobalKey(),
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.info),
                                ),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            if (widget.product.productImages![i].isCover ==
                                true)
                              Positioned(
                                bottom: 0,
                                left: MediaQuery.of(context).size.width * .195,
                                child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.image),
                                  label: const Text(
                                    "تغير صورة الغلاف",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () => selectImageCover(),
                                ),
                              ),
                            Positioned(
                              bottom: 100,
                              left: MediaQuery.of(context).size.width * .21,
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.change_circle),
                                label: const Text(
                                  "استبدال الصوره",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () => selectImages(
                                    widget.product.productImages![i].id),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: widget.product.productImages?.length,
                    carouselController: _controller,
                    options: CarouselOptions(
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      enlargeCenterPage: true,
                      pauseAutoPlayOnManualNavigate: false,
                      autoPlay: false,
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                        ),
                        onPressed: () => _controller.previousPage(),
                        child: const Icon(Icons.arrow_back),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                        ),
                        onPressed: () => _controller.nextPage(),
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            _buildProductDetailsDisplay(widget.product, context),
            Container(
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    (_product != null &&
                            _product!.productOptions!.isNotEmpty &&
                            _product!
                                .productOptions![0].productOptionValues!.isEmpty
                        ? 0.1
                        : 0.7),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => !loading ? newOption() : {},
                        icon: loading ? const Text('') : const Icon(Icons.add),
                        label: loading
                            ? const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text("أضف خيارات"),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 40.0,
                    ),
                    child: FutureBuilder(
                      future: _initProductData,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          case ConnectionState.done:
                            {
                              // ignore: unnecessary_null_comparison
                              if (_product != null &&
                                  _product!.productOptions!.isNotEmpty &&
                                  _product!.productOptions![0]
                                      .productOptionValues!.isEmpty) {
                                return const Center(
                                  child: Text("ليس لديك خيارات بعد"),
                                );
                              } else {
                                return _optionValues(_product
                                    ?.productOptions![0]
                                    .productOptionValues
                                    ?.reversed
                                    .toList() as List<ProductOptionValues>);
                              }
                            }
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  selectImageCover() {
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => ImageSelector(
        images:
            widget.product.productImages?.map((e) => e.image).toList() ?? [],
        onSelect: changeCoverImage,
        onChanged: (int i) {
          if (kDebugMode) {
            print(i);
          }
        },
        initialIndex: widget.product.productImages
                ?.indexWhere((e) => e.isCover == true) ??
            0,
      ),
    );
  }

  Future changeCoverImage(int i) async {}
}
