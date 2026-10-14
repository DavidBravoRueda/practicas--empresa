import 'package:flutter/material.dart';

import 'app_state.dart';
import 'auth_form.dart';
import 'category_detail_page.dart';
import 'product_widgets.dart';
import 'search_results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTabIndex = 0;
  String? pendingFavoriteProductName;
  final TextEditingController homeSearchController = TextEditingController();

  final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

  final List<Map<String, dynamic>> categories = [
    {'name': 'Móviles', 'icon': Icons.smartphone},
    {'name': 'Portátiles', 'icon': Icons.laptop_mac},
    {'name': 'Gaming', 'icon': Icons.sports_esports},
    {'name': 'Componentes', 'icon': Icons.memory},
    {'name': 'Periféricos', 'icon': Icons.keyboard},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'iPhone 17 Pro',
      'categories': ['Móviles'],
      'price': '1.319,00 €',
      'originalPrice': '1.469,00 €',
      'icon': Icons.smartphone,
      'color': const Color(0xFFE1E6ED),
      'discount': '-10%',
      'brand': 'Apple',
      'availability': 'Disponible',
      'description': 'El iPhone 17 Pro combina un diseño premium, cámaras avanzadas y un rendimiento potente.',
      'features': [
        'Pantalla de alta calidad',
        'Chip de alto rendimiento',
        'Cámaras avanzadas',
        'Conectividad 5G',
        'Reconocimiento facial',
      ],
    },
    {
      'name': 'Portátil Gaming',
      'categories': ['Portátiles', 'Gaming'],
      'price': '899,00 €',
      'originalPrice': '1.099,00 €',
      'icon': Icons.laptop_mac,
      'color': const Color(0xFFE4E0F5),
      'discount': '-18%',
      'brand': 'Gaming',
      'availability': 'Disponible',
      'description': 'Portátil diseñado para videojuegos, tareas exigentes y aplicaciones que necesitan un buen rendimiento.',
      'features': [
        'Pantalla de alta resolución',
        'Procesador de alto rendimiento',
        'Gráficos para gaming',
        'Teclado cómodo para jugar',
        'Conectividad Wi-Fi y Bluetooth',
      ],
    },
    {
      'name': 'Auriculares Pro',
      'categories': ['Periféricos'],
      'price': '79,99 €',
      'originalPrice': '99,99 €',
      'icon': Icons.headphones,
      'color': const Color(0xFFFFE8D7),
      'discount': '-20%',
      'brand': 'TecnoStore Audio',
      'availability': 'Disponible',
      'description': 'Auriculares pensados para escuchar música, ver películas y realizar llamadas con comodidad.',
      'features': [
        'Diseño ergonómico',
        'Sonido estéreo',
        'Controles de reproducción',
        'Micrófono integrado',
        'Almohadillas cómodas',
      ],
    },
    {
      'name': 'Mando Gaming',
      'categories': ['Periféricos', 'Gaming'],
      'price': '59,99 €',
      'originalPrice': '74,99 €',
      'icon': Icons.sports_esports,
      'color': const Color(0xFFD9F0E5),
      'discount': '-20%',
      'brand': 'TecnoStore Gaming',
      'availability': 'Disponible',
      'description': 'Mando diseñado para disfrutar de videojuegos con un agarre cómodo y controles intuitivos.',
      'features': [
        'Diseño ergonómico',
        'Joysticks analógicos',
        'Botones de acción',
        'Cruceta direccional',
        'Agarre cómodo',
      ],
    },
  ];

  @override
  void dispose() {
    homeSearchController.dispose();
    favorites.dispose();
    super.dispose();
  }

  void openCart() {
    setState(() => selectedTabIndex = 3);
  }

  void openLogin() {
    setState(() => selectedTabIndex = 4);
  }

  void openCategory(Map<String, dynamic> category) {
    final categoryName = category['name'] as String;
    final categoryIcon = category['icon'] as IconData;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailPage(
          name: categoryName,
          icon: categoryIcon,
          products: products.where((product) {
            return (product['categories'] as List).contains(categoryName);
          }).toList(),
          favorites: favorites,
          onFavorite: (product) {
            toggleFavorite(product['name'] as String);
          },
          onViewCart: openCart,
        ),
      ),
    );
  }

  void toggleFavorite(String productName) {
    if (!isLoggedIn.value) {
      pendingFavoriteProductName = productName;
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.lock_outline, size: 38),
          title: const Text('Inicia sesión'),
          content: const Text(
            'Necesitas iniciar sesión para guardar productos en favoritos.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                pendingFavoriteProductName = null;
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: textColor,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).popUntil((route) => route.isFirst);
                openLogin();
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      );
      return;
    }

    final updatedFavorites = Set<String>.from(favorites.value);

    if (updatedFavorites.contains(productName)) {
      updatedFavorites.remove(productName);
    } else {
      updatedFavorites.add(productName);
    }

    favorites.value = updatedFavorites;
  }

  void continueCheckout() {
    if (!isLoggedIn.value) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.lock_outline, size: 38),
          title: const Text('Inicia sesión'),
          content: const Text(
            'Necesitas iniciar sesión para continuar con la compra.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: textColor,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                openLogin();
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La compra estará disponible próximamente.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt, color: textColor, size: 25),
            ),
            const SizedBox(width: 9),
            const Text(
              'tecno',
              style: TextStyle(
                color: textColor,
                fontSize: 23,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Text(
              'store',
              style: TextStyle(
                color: textColor,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: openCart,
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: textColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoggedIn,
        builder: (context, loggedIn, child) => IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildHomeContent(),
            _buildCategoriesPage(),
            if (loggedIn) _buildFavoritesPage() else const SizedBox.shrink(),
            _buildCartPage(),
            _buildProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: isLoggedIn,
        builder: (context, loggedIn, child) {
          final destinations = <NavigationDestination>[
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Categorías',
            ),
            if (loggedIn)
              const NavigationDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
            const NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Carrito',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ];
          final visibleIndex = !loggedIn && selectedTabIndex > 2
              ? selectedTabIndex - 1
              : selectedTabIndex;

          return NavigationBar(
            selectedIndex: visibleIndex,
            backgroundColor: Colors.white,
            indicatorColor: primaryColor.withValues(alpha: 0.35),
            onDestinationSelected: (index) {
              final pageIndex = !loggedIn && index >= 2 ? index + 1 : index;
              setState(() => selectedTabIndex = pageIndex);
            },
            destinations: destinations,
          );
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: TextField(
            controller: homeSearchController,
            decoration: InputDecoration(
              hintText: 'Busca móviles, portátiles...',
              prefixIcon: const Icon(Icons.search, color: textColor),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              final query = value.trim();
              if (query.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchResultsPage(
                    query: query,
                    products: products,
                    favorites: favorites,
                    onFavorite: toggleFavorite,
                    onViewCart: openCart,
                  ),
                ),
              ).then((_) {
                if (mounted) homeSearchController.clear();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'TECNO OFERTAS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'LA TECNOLOGÍA\nA OTRO NIVEL.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Descubre tus próximos favoritos.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: textColor,
                  ),
                  onPressed: () => setState(() => selectedTabIndex = 1),
                  child: const Text(
                    'EXPLORAR PRODUCTOS',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildSectionTitle(
          'Categorías',
          'Ver todas',
          () => setState(() => selectedTabIndex = 1),
        ),
        SizedBox(
          height: 105,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];

              return GestureDetector(
                onTap: () => openCategory(category),
                child: SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: textColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle(
          'Los más destacados',
          'Ver más',
          () => setState(() => selectedTabIndex = 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 255,
            ),
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return ProductCard(
      product: product,
      favorites: favorites,
      onFavorite: () => toggleFavorite(product['name'] as String),
      onViewCart: openCart,
    );
  }

  Widget _buildCategoriesPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Categorías',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) {
          final categoryName = category['name'] as String;
          final categoryIcon = category['icon'] as IconData;

          return Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              leading: Icon(categoryIcon),
              title: Text(categoryName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openCategory(category),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCartPage() {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: cart,
      builder: (context, cartItems, child) {
        if (cartItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 65, color: textColor),
                SizedBox(height: 12),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text('¡Hay tecnología esperándote!'),
              ],
            ),
          );
        }

        final cartEntries = cartItems.entries.toList();
        double total = 0;

        for (final entry in cartEntries) {
          final product = products.firstWhere(
            (item) => item['name'] == entry.key,
          );
          total += _parsePrice(product['price'] as String) * entry.value;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mi carrito',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                  Text(
                    '${cartEntries.fold<int>(0, (sum, entry) => sum + entry.value)} artículos',
                  ),
                  TextButton.icon(
                    onPressed: () => cart.value = {},
                    icon: const Icon(Icons.remove_shopping_cart_outlined),
                    label: const Text('Vaciar cesta'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = cartEntries[index];
                  final product = products.firstWhere(
                    (item) => item['name'] == entry.key,
                  );
                  final productName = entry.key;
                  final quantity = entry.value;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 85,
                          decoration: BoxDecoration(
                            color: product['color'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            product['icon'] as IconData,
                            size: 40,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product['price'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final updatedCart = Map<String, int>.from(
                                        cart.value,
                                      );
                                      if (quantity <= 1) {
                                        updatedCart.remove(productName);
                                      } else {
                                        updatedCart[productName] = quantity - 1;
                                      }
                                      cart.value = updatedCart;
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final updatedCart = Map<String, int>.from(
                                        cart.value,
                                      );
                                      updatedCart[productName] = quantity + 1;
                                      cart.value = updatedCart;
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      final updatedCart = Map<String, int>.from(
                                        cart.value,
                                      );
                                      updatedCart.remove(productName);
                                      cart.value = updatedCart;
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatPrice(total),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: textColor,
                        ),
                        onPressed: continueCheckout,
                        child: const Text(
                          'CONTINUAR CON LA COMPRA',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _parsePrice(String value) {
    return double.tryParse(
          value
              .replaceAll('€', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .trim(),
        ) ??
        0;
  }

  String _formatPrice(double price) {
    final cents = (price * 100).round();
    final wholePart = (cents ~/ 100).toString();
    final decimalPart = (cents % 100).toString().padLeft(2, '0');
    final buffer = StringBuffer();

    for (int index = 0; index < wholePart.length; index++) {
      if (index > 0 && (wholePart.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(wholePart[index]);
    }

    return '${buffer.toString()},$decimalPart €';
  }

  Widget _buildProfilePage() {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoggedIn,
      builder: (context, loggedIn, child) {
        if (loggedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(Icons.person, size: 55, color: textColor),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mi cuenta',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<Map<String, dynamic>?>(
                    valueListenable: currentUser,
                    builder: (context, user, child) {
                      final roles = user?['roles'];
                      final role =
                          user?['role']?.toString() ??
                          (roles is List ? roles.join(', ') : null);

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _profileDataRow(
                              Icons.person_outline,
                              'Nombre',
                              user?['name']?.toString() ?? 'No disponible',
                            ),
                            const Divider(height: 24),
                            _profileDataRow(
                              Icons.email_outlined,
                              'Correo electrónico',
                              user?['email']?.toString() ?? 'No disponible',
                            ),
                            if (role != null && role.isNotEmpty) ...[
                              const Divider(height: 24),
                              _profileDataRow(
                                Icons.badge_outlined,
                                'Rol',
                                role,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: textColor,
                      ),
                      onPressed: () {
                        isLoggedIn.value = false;
                        favorites.value = <String>{};
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Has cerrado sesión.')),
                        );
                      },
                      child: const Text(
                        'CERRAR SESIÓN',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return LoginFormContent(
          onLoginSuccess: () {
            setState(() {
              final pendingProduct = pendingFavoriteProductName;
              if (pendingProduct != null) {
                favorites.value = {...favorites.value, pendingProduct};
                pendingFavoriteProductName = null;
              }
              selectedTabIndex = 4;
            });
          },
        );
      },
    );
  }

  Widget _buildFavoritesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            'Mis favoritos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: favorites,
            builder: (context, favoriteNames, child) {
              final favoriteProducts = products
                  .where(
                    (product) =>
                        favoriteNames.contains(product['name'] as String),
                  )
                  .toList();

              if (!isLoggedIn.value || favoriteProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 58,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isLoggedIn.value
                              ? 'Todavía no tienes favoritos.'
                              : 'Inicia sesión para guardar tus favoritos.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => setState(
                            () => selectedTabIndex = isLoggedIn.value ? 1 : 4,
                          ),
                          child: Text(
                            isLoggedIn.value
                                ? 'Explorar productos'
                                : 'Iniciar sesión',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: favoriteProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 255,
                ),
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  return ProductCard(
                    product: product,
                    favorites: favorites,
                    onFavorite: () => toggleFavorite(product['name'] as String),
                    onViewCart: openCart,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _profileDataRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
