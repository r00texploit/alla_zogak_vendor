import 'package:alla_zogak_vendor/api/order_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderReadyWidget extends StatefulWidget {
  final int id;
  final Function(bool done) done;
  const OrderReadyWidget({Key? key, required this.id, required this.done})
      : super(key: key);

  @override
  State<OrderReadyWidget> createState() => _OrderReadyWidgetState();
}

class _OrderReadyWidgetState extends State<OrderReadyWidget> {
  bool loading = false;

  submit() async {
    setState(() {
      loading = true;
    });
    try {
      final resp = await updateOrder(
          widget.id, {"ready_time": DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now())});
      if (resp.success) {
        widget.done(resp.success);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "تم تسليم الطلب بنجاح",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
        setState(() {
          loading = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
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
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => loading ? {} : submit(),
                  icon: loading
                      ? const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delivery_dining),
                  label: loading ? const Text("") : const Text("تسليم"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
