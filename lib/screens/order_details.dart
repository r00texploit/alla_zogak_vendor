import 'package:alla_zogak_vendor/api/order_service.dart';
import 'package:alla_zogak_vendor/models/sub_orders.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/response_model.dart';
import '../models/sub_order_products.dart';
import '../widgets/order_ready.dart';

class OrderDetails extends StatefulWidget {
  final int id;
  const OrderDetails({super.key, required this.id});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  SubOrders? order;
  late Future<void> _initOrderData;
  @override
  void initState() {
    super.initState();
    _initOrderData = _initOrder();
  }

  Future<void> _initOrder() async {
    try {
      ResponseModel resp = await getOrderDetails(widget.id);
      if (resp.success) {
        order = SubOrders.fromJson(resp.data);
      }
    } catch (e, s) {
      if (kDebugMode) {
        print([e, s]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الطلب"),
      ),
      body: FutureBuilder(
        future: _initOrderData,
        builder: (c, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              {
                return const Center(child: CircularProgressIndicator());
              }
            case ConnectionState.done:
              {
                if (order == null) {
                  return const Center(
                    child: Text("تأكد من إتصالك بشبكة الإنترنت"),
                  );
                } else {
                  return listItem(order as SubOrders);
                }
              }
          }
        },
      ),
    );
  }

  done(bool val) {
    if (val) {
      setState(() {
        order?.readyTime = DateTime.now();
      });
    }
  }

  Widget listItem(SubOrders order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 0.2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                          order.createdAt
                                  .compareTo(DateTime(DateTime.now().year - 1))
                                  .isNegative
                              ? 'EEE, dd MMM, yyyy , hh:mm a'
                              : 'EEE, dd MMM hh:mm a',
                          "ar")
                      .format(order.createdAt),
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                ),
                Text(
                  "${countTotalBalance(order.subOrderProducts as List<SubOrderProducts>)} ج.س",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: Colors.grey),
                ),
              ],
            ),
            Text("# ${order.orders?.id}"),
            Column(
              children: List.generate(
                order.subOrderProducts?.length ?? 0,
                (i) => SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://yoo2.smart-node.net${order.subOrderProducts![i].productOptionValues?.productImages?.image}",
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
                          SizedBox(
                            child: Text(
                              "أسم المنتج: ${order.subOrderProducts![i].products?.name}",
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Text(
                              "السعر: ${order.subOrderProducts![i].price} ج.س",
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Text(
                              "الكمية: ${order.subOrderProducts![i].qty}",
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (order.subOrderProducts![i].productOptionValues
                                  ?.categoryOpitionValues !=
                              null)
                            SizedBox(
                              child: Text(
                                "الوصف: ${order.subOrderProducts![i].productOptionValues?.categoryOpitionValues?.value}",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          if (order.subOrderProducts![i].productOptionValues
                                  ?.productColors !=
                              null)
                            SizedBox(
                              child: Row(
                                children: [
                                  const Text(
                                    "اللون:",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    height: 18,
                                    width: 18,
                                    color: Color.fromRGBO(
                                        order
                                            .subOrderProducts![i]
                                            .productOptionValues!
                                            .productColors!
                                            .r,
                                        order
                                            .subOrderProducts![i]
                                            .productOptionValues!
                                            .productColors!
                                            .g,
                                        order
                                            .subOrderProducts![i]
                                            .productOptionValues!
                                            .productColors!
                                            .b,
                                        1),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            if (order.readyTime == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text(
                      'الطلب جاهز للتسليم',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    onPressed: () => showModalBottomSheet(
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
                        child: OrderReadyWidget(
                          id: order.id,
                          done: done,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String countTotalBalance(List<SubOrderProducts> products) {
    double total = 0;
    for (var pro in products) {
      total += pro.price;
    }
    return total.toString();
  }
}
