import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ImageSelector extends StatefulWidget {
  List<String> images;
  int initialIndex;
  Function(int i)? onChanged;
  Future Function(int i) onSelect;
  ImageSelector(
      {Key? key,
      required this.images,
      this.initialIndex = 0,
      this.onChanged,
      required this.onSelect})
      : super(key: key);

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  int? init;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    init = widget.initialIndex;
  }

  bool get enabled => init != widget.initialIndex;

  select() async {
    setState(() {
      loading = true;
    });
    await widget.onSelect(widget.initialIndex);
    setState(() {
      loading = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            )),
        width: MediaQuery.of(context).size.width * .9,
        height: MediaQuery.of(context).size.height * .7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: List.generate(
                widget.images.length,
                (i) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.initialIndex = i;
                        if (widget.onChanged != null) {
                          widget.onChanged!(i);
                        }
                        // Navigator.pop(context);
                      });
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: i == widget.initialIndex
                              ? BoxDecoration(
                                  border: Border.all(
                                      width: 3,
                                      color: Theme.of(context).primaryColor))
                              : const BoxDecoration(),
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://yoo2.smart-node.net/${widget.images[i]}",
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
                        if (i == widget.initialIndex)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              color: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.done,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color.fromARGB(255, 250, 82, 70),
                  ),
                  label: const Text(
                    "إلغاء",
                    style: TextStyle(
                      color: Color.fromARGB(255, 250, 82, 70),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(enabled
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  onPressed: () => enabled ? select() : {},
                  icon: loading
                      ? const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.done),
                  label: Text(!loading ? "أختيار" : ""),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
