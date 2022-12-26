import 'package:flutter/material.dart';

class ChangeSettingsWidget extends StatefulWidget {
  const ChangeSettingsWidget({Key? key}) : super(key: key);

  @override
  State<ChangeSettingsWidget> createState() => _ChangeSettingsWidgetState();
}

class _ChangeSettingsWidgetState extends State<ChangeSettingsWidget> {
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
                  ElevatedButton.icon(
                    autofocus: true,
                    label: const Text("إيقاف الإشعارات"),
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => {},
                    icon: const Icon(Icons.save),
                    label: const Text("حفظ التغيرات"),
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
