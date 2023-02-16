import 'package:flutter/material.dart';
import 'package:alla_zogak_vendor/api/product_service.dart';
import 'package:alla_zogak_vendor/models/categories.dart';
import 'package:alla_zogak_vendor/widgets/product_card.dart';

import '../models/products.dart';
import '../models/response_model.dart';

class ProductsScreen extends StatefulWidget {
  final Categories category;
  const ProductsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  GlobalKey builderKey = GlobalKey();
  // ignore: non_constant_identifier_names
  late List<Products> _ProductList;
  late Future<void> _initProductsData;
  @override
  void initState() {
    super.initState();
    _initProductsData = _initProducts();
  }

  Future<void> _initProducts() async {
    ResponseModel categories =
        await getMyProductsByCategory(widget.category.id);
    _ProductList = List.generate(
        categories.data.length, (i) => Products.fromJson(categories.data[i]));
  }

  Future<void> _refreshMyProducts() async {
    ResponseModel categories =
        await getMyProductsByCategory(widget.category.id);
    setState(() {
      _ProductList = List.generate(
          categories.data.length, (i) => Products.fromJson(categories.data[i]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          title: Text(
            widget.category.nameAr,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          centerTitle: true,
        ),
        body: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: _initProductsData,
                  builder: (c, snapshot) {
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
                          if (_ProductList.isEmpty) {
                            return const Center(
                              child: Text("You did not add any products"),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () => _refreshMyProducts(),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Wrap(
                                children: List.generate(
                                  _ProductList.length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          20,
                                      child: ProductCard(
                                        product: _ProductList[i],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
            )));
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
