import 'package:flutter/material.dart';
import 'package:dio_complete/core/widgets/app_colors.dart';
import 'package:dio_complete/core/widgets/app_formatter.dart';
import 'package:dio_complete/core/widgets/app_image_placeholder.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';


class ProductGridCard extends StatelessWidget {
  final Product product;

  final GlobalKey addButtonKey;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.addButtonKey,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProductImage(
              product: product,
              addButtonKey: addButtonKey,
              onAddToCart: onAddToCart,
            ),
            _ProductInfo(product: product),
          ],
        ),
      ),
    );
  }
}


class _ProductImage extends StatelessWidget {
  final Product product;
  final GlobalKey addButtonKey;
  final VoidCallback onAddToCart;

  const _ProductImage({
    required this.product,
    required this.addButtonKey,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          product.image.isNotEmpty
              ? Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const AppImagePlaceholder(),
                )
              : const AppImagePlaceholder(),
          Positioned(
            right: 6,
            bottom: 6,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                key: addButtonKey,
                customBorder: const CircleBorder(),
                onTap: onAddToCart,
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.add_shopping_cart,
                    size: 18,
                    color: AppColors.primary,
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

/// Tên, danh mục, mã, giá và tồn kho - phần thông tin bên dưới ảnh.
class _ProductInfo extends StatelessWidget {
  final Product product;

  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (product.category != null) ...[
            const SizedBox(height: 4),
            _CategoryBadge(name: product.category!.name),
          ],
          const SizedBox(height: 4),
          Text(
            'Mã: ${product.code}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatter.currency(product.price),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Kho: ${product.stock}',
            style: TextStyle(
              fontSize: 11,
              color: product.stock <= 5 ? Colors.red : Colors.grey,
              fontWeight:
                  product.stock <= 5 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String name;

  const _CategoryBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
      ),
    );
  }
}
