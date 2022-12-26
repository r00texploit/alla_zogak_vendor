import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alla_zogak_vendor/api/order_service.dart';
import 'package:alla_zogak_vendor/models/sub_orders.dart';

import '../models/response_model.dart';
import '../models/sub_order_products.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(5)),
                child: TabBar(
                  tabs: const <Widget>[
                    Tab(
                      child: SizedBox(
                        child: Text(
                          "الحالية",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "السابقة",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).primaryColor.withOpacity(0.8)),
                  unselectedLabelColor: Colors.black54,
                  labelColor: Colors.black,
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    OnGoing(),
                    PastOrder(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class OnGoing extends StatefulWidget {
  const OnGoing({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OnGoingState createState() => _OnGoingState();
}

class _OnGoingState extends State<OnGoing> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<SubOrders> _orderList = [];
  late Future<void> _initOrdersData;
  @override
  void initState() {
    super.initState();
    _initOrdersData = _initOrders();
  }

  Future<void> _initOrders() async {
    ResponseModel orders = await getActiveOrders();
    _orderList = List.generate(
        orders.data.length, (i) => SubOrders.fromJson(orders.data[i]));
  }

  Future<void> _refreshOrders() async {
    ResponseModel orders = await getActiveOrders();
    setState(() {
      _orderList = List.generate(
          orders.data.length, (i) => SubOrders.fromJson(orders.data[i]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initOrdersData,
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
                if (_orderList.isEmpty) {
                  return const Center(
                    child: Text("ليس لديك طلبات"),
                  );
                } else {
                  return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () => _refreshOrders(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _orderList.length,
                      itemBuilder: (context, i) {
                        return listItem(_orderList[i]);
                      },
                    ),
                  );
                }
              }
          }
        });
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
                                    .compareTo(
                                        DateTime(DateTime.now().year - 1))
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
                    "${countTotalBalance(order.subOrderProducts)} SDG",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
              Text("# ${order.orders?.id}"),
              Column(
                children: List.generate(
                  order.subOrderProducts?.length ?? 0,
                  (i) => Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.description_outlined,
                          size: 15,
                          color: Colors.black12,
                        ),
                      ),
                      Expanded(
                          child: Text(
                              "${order.subOrderProducts![i].name} (${order.subOrderProducts![i].qty})")),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "${order.orders?.address}",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "orderDetails",
                          arguments: order.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  String countTotalBalance(List<SubOrderProducts>? products) {
    double total = 0;
    if (products != null) {
      for (var pro in products) {
        total += pro.price;
      }
    }
    return total.toString();
  }
}

class PastOrder extends StatefulWidget {
  const PastOrder({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PastOrderState createState() => _PastOrderState();
}

class _PastOrderState extends State<PastOrder> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<SubOrders> _orderList = [];
  late Future<void> _initOrdersData;
  @override
  void initState() {
    super.initState();
    _initOrdersData = _initOrders();
  }

  Future<void> _initOrders() async {
    ResponseModel orders = await getDeleiveredOrders();
    _orderList = List.generate(
        orders.data.length, (i) => SubOrders.fromJson(orders.data[i]));
  }

  Future<void> _refreshOrders() async {
    ResponseModel orders = await getDeleiveredOrders();
    setState(() {
      _orderList = List.generate(
          orders.data.length, (i) => SubOrders.fromJson(orders.data[i]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initOrdersData,
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
                if (_orderList.isEmpty) {
                  return const Center(
                    child: Text("ليس لديك طلبات"),
                  );
                } else {
                  return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () => _refreshOrders(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _orderList.length,
                      itemBuilder: (context, i) {
                        return listItem(_orderList[i]);
                      },
                    ),
                  );
                }
              }
          }
        });
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
                                    .compareTo(
                                        DateTime(DateTime.now().year - 1))
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
                    "${countTotalBalance(order.subOrderProducts)} SDG",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
              Text("# ${order.orders?.id}"),
              Column(
                children: List.generate(
                  order.subOrderProducts?.length ?? 0,
                  (i) => Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.description_outlined,
                          size: 15,
                          color: Colors.black12,
                        ),
                      ),
                      Expanded(
                          child: Text(
                              "${order.subOrderProducts![i].name} (${order.subOrderProducts![i].qty})")),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "${order.orders?.address}",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "orderDetails",
                          arguments: order.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  String countTotalBalance(List<SubOrderProducts>? products) {
    double total = 0;
    if (products != null) {
      for (var pro in products) {
        total += pro.price;
      }
    }
    return total.toString();
  }
}
