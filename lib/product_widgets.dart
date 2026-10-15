import 'package:flutter/material.dart';

import 'app_state.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final ValueNotifier<Set<String>> favorites;
  final VoidCallback onFavorite;
  final VoidCallback onViewCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.favorites,
    required this.onFavorite,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    final productName = product['name'] as String? ?? 'Producto';
    final imageUrl = product['imageUrl'] as String?;
    final productColor = product['color'] as Color? ?? Colors.white;
    final productIcon = product['icon'] as IconData? ?? Icons.devices;
    final discount = product['discount'] as String?;
    final originalPrice = product['originalPrice'] as String?;
    final price = product['price'] as String? ?? '0,00 €';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: product,
              favorites: favorites,
              onFavorite: onFavorite,
              onViewCart: onViewCart,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: productColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildProductImage(
                      imageUrl,
                      productIcon,
                      productColor,
                      75,
                    ),
                  ),
                  if (discount != null && discount.isNotEmpty)
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: favorites,
                      builder: (context, currentFavorites, child) {
                        final favorite =
                            currentFavorites.contains(productName);

                        return IconButton(
                          tooltip: isLoggedIn.value
                              ? 'Añadir o quitar de favoritos'
                              : 'Inicia sesión para usar favoritos',
                          visualDensity: VisualDensity.compact,
                          onPressed: onFavorite,
                          icon: Icon(
                            favorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: favorite ? primaryColor : textColor,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (originalPrice != null &&
                      originalPrice.isNotEmpty &&
                      originalPrice != price)
                    Text(
                      originalPrice,
                      style: const TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        (product['stock'] as num?)?.toInt() == 0
                            ? Icons.remove_shopping_cart_outlined
                            : Icons.local_shipping_outlined,
                        size: 14,
                        color: (product['stock'] as num?)?.toInt() == 0
                            ? errorColor
                            : successColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (product['stock'] as num?)?.toInt() == 0
                              ? 'Agotado'
                              : 'Envío disponible',
                          style: TextStyle(
                            fontSize: 10,
                            color: (product['stock'] as num?)?.toInt() == 0
                                ? errorColor
                                : successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProductImage(
  String? imageUrl,
  IconData icon,
  Color fallbackColor,
  double iconSize,
) {
  if (imageUrl != null && imageUrl.trim().isNotEmpty) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          icon,
          size: iconSize,
          color: secondaryTextColor,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

  return Icon(
    icon,
    size: iconSize,
    color: secondaryTextColor,
  );
}

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final ValueNotifier<Set<String>> favorites;
  final VoidCallback onFavorite;
  final VoidCallback onViewCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.favorites,
    required this.onFavorite,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    final productCategories =
        product['categories'] ?? ['Electrónica'];

    final categoryText = productCategories is List
        ? productCategories.join(' · ')
        : productCategories.toString();

    final productName = product['name'] as String? ?? 'Producto';
    final imageUrl = product['imageUrl'] as String?;
    final productColor = product['color'] as Color? ?? Colors.white;
    final productIcon = product['icon'] as IconData? ?? Icons.devices;
    final price = product['price'] as String? ?? '';
    final originalPrice = product['originalPrice'] as String?;
    final description = product['description'] as String? ??
        'Descubre este producto en Nexo.';
    final features = product['features'] as List? ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Detalle del producto',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildProductImage(
                imageUrl,
                productIcon,
                productColor,
                130,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryText,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (originalPrice != null &&
                          originalPrice.isNotEmpty &&
                          originalPrice != price)
                        Text(
                          originalPrice,
                          style: const TextStyle(
                            fontSize: 16,
                      color: secondaryTextColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: favorites,
                      builder: (context, currentFavorites, child) {
                        final favorite =
                            currentFavorites.contains(productName);

                        return OutlinedButton.icon(
                          onPressed: onFavorite,
                          icon: Icon(
                            favorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text(
                            favorite
                                ? 'Quitar de favoritos'
                                : 'Añadir a favoritos',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Características',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: successColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature.toString(),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed:
                          (product['stock'] as num?)?.toInt() == 0
                              ? null
                              : () {
                                  final updatedCart =
                                      Map<String, int>.from(cart.value);

                                  updatedCart[productName] =
                                      (updatedCart[productName] ?? 0) + 1;

                                  cart.value = updatedCart;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$productName añadido al carrito',
                                      ),
                                      action: SnackBarAction(
                                        label: 'VER CARRITO',
                                        onPressed: () {
                                          Navigator.of(context).popUntil(
                                            (route) => route.isFirst,
                                          );
                                          onViewCart();
                                        },
                                      ),
                                    ),
                                  );
                                },
                      child: Text(
                        (product['stock'] as num?)?.toInt() == 0
                            ? 'Producto agotado'
                            : 'Añadir al carrito',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
