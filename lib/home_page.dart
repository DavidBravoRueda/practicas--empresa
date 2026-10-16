
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'auth_form.dart';
import 'category_detail_page.dart';
import 'checkout_page.dart';
import 'product_widgets.dart';
import 'search_results_page.dart';
import 'services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTabIndex = 0;
  String? pendingFavoriteProductName;

  final TextEditingController homeSearchController =
      TextEditingController();
  final ValueNotifier<Set<String>> favorites =
      ValueNotifier<Set<String>>({});

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> brands = [];

  bool _isLoadingCatalog = true;
  String? _catalogError;

  List<Map<String, dynamic>> get mainCategories {
    final childIds = <String>{};

    for (final category in categories) {
      final children = category['subcategories'];

      if (children is List) {
        for (final child in children) {
          if (child is Map && child['id'] != null) {
            childIds.add(child['id'].toString());
          }
        }
      }
    }

    return categories.where((category) {
      final name =
          (category['name'] ?? '').toString().toLowerCase().trim();

      final parentId = category['parent_id'] ??
          category['parent_category_id'] ??
          category['parentId'];

      final id = category['id']?.toString();

      if (parentId != null) return false;
      if (id != null && childIds.contains(id)) return false;
      if (name == 'ratones') return false;

      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    if (mounted) {
      setState(() {
        _isLoadingCatalog = true;
        _catalogError = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getProducts(),
        ApiService.getCategories(),
      ]);

      final apiProducts =
          results[0] as List<Map<String, dynamic>>;
      final apiCategories =
          results[1] as List<Map<String, dynamic>>;

      final loadedCategories = apiCategories.map((category) {
        final name = category['name']?.toString() ?? 'Otros';

        return <String, dynamic>{
          ...category,
          'name': name,
          'icon': _iconForCategory(name),
        };
      }).toList();

      // Pasamos las categorías al mapeador para identificar
      // correctamente las subcategorías de cada producto.
      final loadedProducts = apiProducts
          .where((product) => product['is_active'] != false)
          .map(
            (product) => _mapApiProduct(
              product,
              loadedCategories,
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        categories = loadedCategories;
        _isLoadingCatalog = false;
        _catalogError = null;
      });

      try {
        final loadedBrands = await ApiService.getBrands();

        if (!mounted) return;

        setState(() {
          brands = loadedBrands;
        });
      } catch (_) {
        // El catálogo sigue funcionando aunque fallen las marcas.
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingCatalog = false;
        _catalogError =
            'No se ha podido cargar el catálogo. Comprueba tu conexión e inténtalo de nuevo.';
      });
    }
  }

  Map<String, dynamic> _mapApiProduct(
    Map<String, dynamic> apiProduct,
    List<Map<String, dynamic>> apiCategories,
  ) {
    final categoryData = apiProduct['category'];
    final brandData = apiProduct['brand'];

    final rawCategoryName = categoryData is Map
        ? categoryData['name']?.toString() ?? 'Otros'
        : apiProduct['category_name']?.toString() ?? 'Otros';

    final rawCategoryId = apiProduct['category_id'] ??
        (categoryData is Map ? categoryData['id'] : null);

    final productCategoryRelations = apiProduct['categories'];

    // IDs de las categorías relacionadas con el producto.
    final relatedCategoryIds = <String>{};

    if (productCategoryRelations is List) {
      for (final relation in productCategoryRelations) {
        if (relation is Map && relation['id'] != null) {
          relatedCategoryIds.add(relation['id'].toString());
        }
      }
    }

    // Primero intentamos encontrar una subcategoría usando la
    // jerarquía real de categorías que devuelve la API.
    Map<String, dynamic>? relatedSubcategory;

    for (final category in apiCategories) {
      final categoryId = category['id'];
      final parentId = category['parent_id'] ??
          category['parent_category_id'] ??
          category['parentId'];

      if (categoryId == null || parentId == null) continue;

      if (relatedCategoryIds.contains(categoryId.toString())) {
        relatedSubcategory = category;
        break;
      }
    }

    // Compatibilidad con APIs que no incluyen parent_id en la
    // relación categories, pero sí devuelven el nombre Ratones.
    if (relatedSubcategory == null &&
        productCategoryRelations is List) {
      for (final relation in productCategoryRelations) {
        if (relation is! Map) continue;

        final relationName =
            (relation['name'] ?? '').toString().toLowerCase().trim();

        if (relationName == 'ratones') {
          relatedSubcategory =
              Map<String, dynamic>.from(relation);
          break;
        }
      }
    }

    final nestedSubcategory = apiProduct['subcategory'] ??
        apiProduct['sub_category'] ??
        apiProduct['subcategory_data'];

    final subcategoryData =
        nestedSubcategory is Map
            ? nestedSubcategory
            : relatedSubcategory;

    final nestedSubcategoryName = subcategoryData is Map
        ? subcategoryData['name']?.toString()
        : null;

    final explicitSubcategoryName =
        apiProduct['subcategory_name']?.toString() ??
            apiProduct['sub_category_name']?.toString() ??
            nestedSubcategoryName;

    final isMouseCategory =
        rawCategoryName.toLowerCase().trim() == 'ratones';

    final categoryName =
        isMouseCategory ? 'Periféricos' : rawCategoryName;

    final subcategoryName = explicitSubcategoryName ??
        (isMouseCategory ? rawCategoryName : null);

    final brandName = brandData is Map
        ? brandData['name']?.toString() ?? 'Sin marca'
        : apiProduct['brand_name']?.toString() ?? 'Sin marca';

    final rawPrice = apiProduct['price'];
    final numericPrice =
        double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

    final rawStock = apiProduct['stock'];
    final stock = rawStock is num
        ? rawStock.toInt()
        : int.tryParse(rawStock?.toString() ?? '') ?? 0;

    final imageUrl = apiProduct['image_url']?.toString();

    return {
      'id': apiProduct['id'],
      'sku': apiProduct['sku']?.toString() ?? '',
      'name': apiProduct['name']?.toString() ?? 'Producto',
      'createdAt': apiProduct['created_at']?.toString(),
      'categories': <String>[categoryName],
      'categoryId': rawCategoryId,
      'subcategoryId': apiProduct['subcategory_id'] ??
          apiProduct['sub_category_id'] ??
          (subcategoryData is Map ? subcategoryData['id'] : null) ??
          (isMouseCategory && categoryData is Map
              ? categoryData['id']
              : null),
      'subcategoryName': subcategoryName,
      'subcategory': subcategoryData is Map
          ? Map<String, dynamic>.from(subcategoryData)
          : null,
      'brandId': apiProduct['brand_id'],
      'brand': brandName,
      'price': _formatPrice(numericPrice),
      'originalPrice': null,
      'discount': null,
      'icon': _iconForCategory(categoryName),
      'color': _colorForCategory(categoryName),
      'availability': stock > 0 ? 'Disponible' : 'Agotado',
      'stock': stock,
      'description': apiProduct['description']?.toString() ??
          'Descubre este producto en TecnoStore.',
      'features': <String>[],
      'imageUrl': imageUrl,
      'isActive': apiProduct['is_active'] != false,
    };
  }

  IconData _iconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('móvil') || name.contains('movil')) {
      return Icons.smartphone;
    }
    if (name.contains('portátil') || name.contains('portatil')) {
      return Icons.laptop_mac;
    }
    if (name.contains('gaming') || name.contains('videojuego')) {
      return Icons.sports_esports;
    }
    if (name.contains('componente')) {
      return Icons.memory;
    }
    if (name.contains('periférico') || name.contains('periferico')) {
      return Icons.keyboard;
    }
    if (name.contains('audio') || name.contains('auricular')) {
      return Icons.headphones;
    }
    if (name.contains('tablet')) {
      return Icons.tablet_mac;
    }
    if (name.contains('televisión') || name.contains('television')) {
      return Icons.tv;
    }

    return Icons.devices;
  }

  Color _colorForCategory(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('móvil') || name.contains('movil')) {
      return const Color(0xFFE1E6ED);
    }
    if (name.contains('portátil') || name.contains('portatil')) {
      return const Color(0xFFE4E0F5);
    }
    if (name.contains('gaming')) {
      return const Color(0xFFD9F0E5);
    }
    if (name.contains('audio') || name.contains('periférico')) {
      return const Color(0xFFFFE8D7);
    }

    return const Color(0xFFE8EDF2);
  }

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

  bool _isRatonesCategory(Map<String, dynamic> category) {
    return (category['name'] ?? '').toString().toLowerCase().trim() ==
        'ratones';
  }

  void openCategory(Map<String, dynamic> category) {
    final categoryName = category['name']?.toString() ?? 'Categoría';

    final categoryIcon = category['icon'] is IconData
        ? category['icon'] as IconData
        : _iconForCategory(categoryName);

    final categoryId = category['id'];
    final nested = category['subcategories'];

    var subcategories = <Map<String, dynamic>>[];

    if (nested is List) {
      subcategories = nested
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (subcategories.isEmpty && categoryId != null) {
      subcategories = categories.where((item) {
        final parentId = item['parent_id'] ??
            item['parent_category_id'] ??
            item['parentId'];

        return parentId != null &&
            parentId.toString() == categoryId.toString();
      }).toList();
    }

    if (subcategories.isEmpty &&
        categoryName.toLowerCase().contains('perif')) {
      subcategories = categories.where(_isRatonesCategory).toList();
    }

    if (subcategories.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubcategoriesPage(
            name: categoryName,
            subcategories: subcategories,
            products: products,
            favorites: favorites,
            onFavorite: (product) {
              toggleFavorite(product['name']?.toString() ?? '');
            },
            onViewCart: openCart,
          ),
        ),
      );
      return;
    }

    final categoryProducts = products.where((product) {
      final productCategoryId = product['categoryId'];

      if (categoryId != null && productCategoryId != null) {
        return productCategoryId.toString() == categoryId.toString();
      }

      final productCategories = product['categories'];

      return productCategories is List &&
          productCategories.contains(categoryName);
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailPage(
          name: categoryName,
          icon: categoryIcon,
          products: categoryProducts,
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

  Future<void> continueCheckout() async {
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

    final cartItems = cart.value;
    final checkoutProducts = <Map<String, dynamic>>[];

    for (final entry in cartItems.entries) {
      if (entry.value <= 0) continue;

      final matchingProducts = products.where(
        (product) => product['name'] == entry.key,
      );

      if (matchingProducts.isEmpty) continue;

      checkoutProducts.add({
        'product': matchingProducts.first,
        'quantity': entry.value,
      });
    }

    if (checkoutProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu cesta está vacía o los productos ya no están disponibles.',
          ),
        ),
      );
      return;
    }

    final order = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => CheckoutPage(cartProducts: checkoutProducts),
      ),
    );

    if (!mounted || order == null) return;

    cart.value = {};

    final orderId = order['id']?.toString() ?? '';
    final total = order['total']?.toString() ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pedido #$orderId registrado correctamente. Total: $total €',
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    await _loadCatalog();
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
              final pageIndex =
                  !loggedIn && index >= 2 ? index + 1 : index;

              setState(() => selectedTabIndex = pageIndex);
            },
            destinations: destinations,
          );
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    final sortedProducts = List<Map<String, dynamic>>.from(products)
      ..sort((first, second) {
        final firstDate = DateTime.tryParse(
          first['createdAt']?.toString() ?? '',
        );

        final secondDate = DateTime.tryParse(
          second['createdAt']?.toString() ?? '',
        );

        if (firstDate != null && secondDate != null) {
          final dateOrder = secondDate.compareTo(firstDate);
          if (dateOrder != 0) return dateOrder;
        } else if (firstDate != null) {
          return -1;
        } else if (secondDate != null) {
          return 1;
        }

        final firstId = int.tryParse(first['id']?.toString() ?? '');
        final secondId = int.tryParse(second['id']?.toString() ?? '');

        if (firstId != null && secondId != null) {
          return secondId.compareTo(firstId);
        }

        return 0;
      });

    final latestProducts = sortedProducts.take(4).toList();

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
                if (mounted) {
                  homeSearchController.clear();
                }
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
        if (_isLoadingCatalog && categories.isEmpty)
          const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (categories.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No hay categorías disponibles.'),
          )
        else
          SizedBox(
            height: 105,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: mainCategories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = mainCategories[index];

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
        if (_isLoadingCatalog)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 35),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_catalogError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 45,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(_catalogError!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loadCatalog,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No hay productos disponibles.')),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: latestProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 255,
              ),
              itemBuilder: (context, index) =>
                  _buildProductCard(latestProducts[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title,
    String action,
    VoidCallback onTap,
  ) {
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
    if (_isLoadingCatalog && categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_catalogError != null && categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 45),
              const SizedBox(height: 12),
              Text(_catalogError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadCatalog,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Categorías',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        if (categories.isEmpty)
          const Text('No hay categorías disponibles.')
        else
          ...mainCategories.map((category) {
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
        final cartEntries = cartItems.entries.where((entry) {
          return products.any((product) => product['name'] == entry.key);
        }).toList();

        if (cartEntries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 65,
                  color: textColor,
                ),
                SizedBox(height: 12),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text('¡Hay tecnología esperándote!'),
              ],
            ),
          );
        }

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
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartEntries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = cartEntries[index];

                  final product = products.firstWhere(
                    (item) => item['name'] == entry.key,
                  );

                  final productName = entry.key;
                  final quantity = entry.value;
                  final imageUrl = product['imageUrl'] as String?;
                  final productColor =
                      product['color'] as Color? ?? Colors.white;
                  final productIcon =
                      product['icon'] as IconData? ?? Icons.devices;

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
                            color: productColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: imageUrl != null &&
                                  imageUrl.trim().isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      productIcon,
                                      size: 40,
                                      color: textColor,
                                    );
                                  },
                                )
                              : Icon(
                                  productIcon,
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
                                      final updatedCart =
                                          Map<String, int>.from(cart.value);

                                      if (quantity <= 1) {
                                        updatedCart.remove(productName);
                                      } else {
                                        updatedCart[productName] =
                                            quantity - 1;
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
                                      final updatedCart =
                                          Map<String, int>.from(cart.value);

                                      updatedCart[productName] =
                                          quantity + 1;
                                      cart.value = updatedCart;
                                    },
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      final updatedCart =
                                          Map<String, int>.from(cart.value);

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
                    child: const Icon(
                      Icons.person,
                      size: 55,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mi cuenta',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<Map<String, dynamic>?>(
                    valueListenable: currentUser,
                    builder: (context, user, child) {
                      final roles = user?['roles'];

                      final role = user?['role']?.toString() ??
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
                          const SnackBar(
                            content: Text('Has cerrado sesión.'),
                          ),
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
                            () => selectedTabIndex =
                                isLoggedIn.value ? 1 : 4,
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
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                    onFavorite: () =>
                        toggleFavorite(product['name'] as String),
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

  Widget _profileDataRow(
    IconData icon,
    String label,
    String value,
  ) {
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
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pantalla que muestra las subcategorías de una categoría principal.
class SubcategoriesPage extends StatelessWidget {
  const SubcategoriesPage({
    super.key,
    required this.name,
    required this.subcategories,
    required this.products,
    required this.favorites,
    required this.onFavorite,
    required this.onViewCart,
  });

  final String name;
  final List<Map<String, dynamic>> subcategories;
  final List<Map<String, dynamic>> products;
  final ValueNotifier<Set<String>> favorites;
  final void Function(Map<String, dynamic>) onFavorite;
  final VoidCallback onViewCart;

  IconData _iconFor(String name) {
    final value = name.toLowerCase();

    if (value.contains('ratón') || value.contains('raton')) {
      return Icons.mouse_outlined;
    }

    if (value.contains('teclado')) {
      return Icons.keyboard_outlined;
    }

    if (value.contains('auricular') || value.contains('audio')) {
      return Icons.headphones_outlined;
    }

    return Icons.devices_other_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Elige una subcategoría para ver sus productos.'),
          const SizedBox(height: 12),
          ...subcategories.map((subcategory) {
            final subcategoryName =
                subcategory['name']?.toString() ?? 'Subcategoría';

            final subcategoryId = subcategory['id'];

            final items = products.where((product) {
              final productSubcategoryId = product['subcategoryId'];

              if (subcategoryId != null &&
                  productSubcategoryId != null) {
                return productSubcategoryId.toString() ==
                    subcategoryId.toString();
              }

              final nested = product['subcategory'];

              if (subcategoryId != null &&
                  nested is Map &&
                  nested['id'] != null) {
                return nested['id'].toString() ==
                    subcategoryId.toString();
              }

              if (subcategoryId != null &&
                  subcategoryName.toLowerCase().trim() == 'ratones' &&
                  product['categoryId'] != null) {
                return product['categoryId'].toString() ==
                    subcategoryId.toString();
              }

              final productSubcategoryName =
                  product['subcategoryName']?.toString().toLowerCase();

              return productSubcategoryName ==
                  subcategoryName.toLowerCase();
            }).toList();

            return Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.3),
                  child: Icon(
                    _iconFor(subcategoryName),
                    color: textColor,
                  ),
                ),
                title: Text(
                  subcategoryName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${items.length} ${items.length == 1 ? 'producto' : 'productos'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailPage(
                        name: subcategoryName,
                        icon: _iconFor(subcategoryName),
                        products: items,
                        favorites: favorites,
                        onFavorite: onFavorite,
                        onViewCart: onViewCart,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}