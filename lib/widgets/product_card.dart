import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/products.dart';

class ProductCard extends StatefulWidget {
  final Products product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Widget prepareImage(String uri) {
    try {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: CachedNetworkImage(
          imageUrl: uri,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Image.asset(
            "assets/3.png",
            fit: BoxFit.fitWidth,
            scale: 1,
            key: GlobalKey(),
            errorBuilder: (context, error, stackTrace) {
              if (kDebugMode) {
                print(error);
              }
              return const Icon(Icons.info);
            },
          ),
          fit: BoxFit.fitWidth,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Image.asset(
        "assets/3.png",
        fit: BoxFit.fill,
        scale: 1,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.info),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "product",
                  arguments: widget.product);
            },
            child: SizedBox(
              height: 190,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 105,
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: widget.product.productImages != null &&
                                  widget.product.productImages!.isNotEmpty &&
                                  widget.product.productImages?.first.image !=
                                      null
                              ? prepareImage(
                                  "https://yoo2.smart-node.net${widget.product.productImages![0].image}")
                              : Image.asset(
                                  "assets/3.png",
                                  fit: BoxFit.fitWidth,
                                  scale: 1,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.info),
                                ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    widget.product.productOptions != null &&
                            widget.product.productOptions!.isNotEmpty &&
                            widget.product.productOptions![0].categoryOption !=
                                null
                        ? '${widget.product.productOptions![0].categoryOption?.categoryOption}'
                        : '',
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    "${widget.product.discount == null ? widget.product.price : (widget.product.price / (widget.product.discount! * 0.1)).ceil()} ج.س",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          if (widget.product.discount != null)
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 32,
                child: Center(
                  child: Text(
                    "${widget.product.price} ج.س",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          if (widget.product.discount != null)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Text(
                    "${widget.product.discount}%",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          if (!widget.product.verified)
            Positioned(
              top: 27,
              left: -30,
              child: Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  width: 140,
                  color: Colors.red,
                  child: const Center(
                    child: Text(
                      "أنتظار الموافقة",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
