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
                      color: product['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      product['icon'] as IconData,
                      size: 75,
                      color: textColor.withValues(alpha: 0.75),
                    ),
                  ),
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
                        product['discount'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
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
                        final productName = product['name'] as String;
                        final favorite = currentFavorites.contains(productName);

                        return IconButton(
                          tooltip: isLoggedIn.value
                              ? 'Añadir o quitar de favoritos'
                              : 'Inicia sesión para usar favoritos',
                          visualDensity: VisualDensity.compact,
                          onPressed: onFavorite,
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            color: favorite ? Colors.green : textColor,
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
                    product['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFB800), size: 15),
                      SizedBox(width: 3),
                      Text('4,8', style: TextStyle(fontSize: 11)),
                      SizedBox(width: 4),
                      Text(
                        '(128)',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['originalPrice'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    product['price'] as String,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 14,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Envío disponible',
                        style: TextStyle(fontSize: 10, color: Colors.green),
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
    final productCategories = product['categories'] ?? ['Electrónica'];

    final categoryText = productCategories is List
        ? productCategories.join(' · ')
        : productCategories.toString();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Detalle del producto',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
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
              child: Icon(
                product['icon'] as IconData? ?? Icons.devices,
                size: 130,
                color: product['color'] as Color? ?? primaryColor,
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
                    product['name'] as String? ?? 'Producto',
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
                        product['price'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (product['originalPrice'] != null)
                        Text(
                          product['originalPrice'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
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
                        final productName = product['name'] as String;
                        final favorite = currentFavorites.contains(productName);

                        return OutlinedButton.icon(
                          onPressed: onFavorite,
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
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
                    product['description'] as String? ??
                        'Descubre este producto en TecnoStore.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
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
                  if (product['features'] != null)
                    ...List<String>.from(product['features']).map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                feature,
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
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final productName = product['name'] as String;
                        final updatedCart = Map<String, int>.from(cart.value);

                        updatedCart[productName] =
                            (updatedCart[productName] ?? 0) + 1;

                        cart.value = updatedCart;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$productName añadido al carrito'),
                            action: SnackBarAction(
                              label: 'VER CARRITO',
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                onViewCart();
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Añadir al carrito',
                        style: TextStyle(
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
