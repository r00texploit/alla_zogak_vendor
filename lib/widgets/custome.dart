import 'dart:developer';

import 'package:alla_zogak_vendor/models/category_option_values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomMultiselectDropDown extends StatefulWidget {
  final Function(List<CategoryOptionValues>) selectedList;
  final List<CategoryOptionValues> listOFStrings;

  CustomMultiselectDropDown(
      {required this.selectedList, required this.listOFStrings});

  @override
  createState() {
    return new _CustomMultiselectDropDownState();
  }
}

int i = 0;
List<CategoryOptionValues>? list;

class _CustomMultiselectDropDownState extends State<CustomMultiselectDropDown> {
  List<CategoryOptionValues> listOFSelectedItem = [];
  CategoryOptionValues? selectedText;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: ExpansionTile(
        iconColor: Colors.grey,
        title: Text(
          // listOFSelectedItem.isEmpty
          // ?
          "Select",
          // : listOFSelectedItem[0].toString(),
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
              fontSize: 15.0,
            ),
          ),
        ),
        children: <Widget>[
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.listOFStrings.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: _ViewItem(
                    item: widget.listOFStrings[index],
                    selected: (val, index) {
                      selectedText = val;
                      // i = index;
                      if (listOFSelectedItem.contains(val)) {
                        listOFSelectedItem.remove(val);
                      } else {
                        listOFSelectedItem.add(val);
                      }
                      widget.selectedList(listOFSelectedItem);
                      setState(() {

                        // list = widget.selectedList(listOFSelectedItem);
                      });
                      // getselected();
                    },
                    itemSelected: listOFSelectedItem
                        .contains(widget.listOFStrings[index])),
              );
            },
          ),
        ],
      ),
    );
  }
}

List<CategoryOptionValues>? getselected() {
  return list!;
}

class _ViewItem extends StatelessWidget {
  CategoryOptionValues item;
  bool itemSelected;
  final Function(CategoryOptionValues, int index) selected;

  _ViewItem(
      {required this.item, required this.itemSelected, required this.selected});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding:
          EdgeInsets.only(left: size.width * .032, right: size.width * .098),
      child: Row(
        children: [
          SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
              value: itemSelected,
              onChanged: (val) {
                selected(item, i);
                log("message:${item.value}");
                
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: size.width * .025,
          ),
          Text(
            item.value,
            style: GoogleFonts.cairo(
              textStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 17.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
