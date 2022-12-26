import 'package:flutter/material.dart';
import 'package:alla_zogak_vendor/models/categories.dart';
import 'package:alla_zogak_vendor/screens/products_screen.dart';

class CategoryCard extends StatefulWidget {
  final Categories category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductsScreen(category: widget.category)));
              },
            child: Container(
              padding: const EdgeInsets.all(9),
              width: MediaQuery.of(context).size.width * .85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.category.nameAr,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Row(
                        children: [
                          Text(
                            widget.category.nameAr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    minRadius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Center(
                        child: Text("${widget.category.count}",style: const TextStyle(fontSize: 20,color: Colors.grey,),),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
