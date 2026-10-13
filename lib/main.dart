import 'package:flutter/material.dart';
void main() {
  runApp(const TecnoStoreApp());
}

const Color primaryColor = Color(0xFFB8F500);
const Color backgroundColor = Color(0xFFF5F6F7);
const Color textColor = Color(0xFF202124);

final ValueNotifier<Map<String, int>> cart = ValueNotifier<Map<String, int>>(
  {},
);

final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

class TecnoStoreApp extends StatelessWidget {
  const TecnoStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TecnoStore',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: textColor,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTabIndex = 0;
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
    setState(() => selectedTabIndex = 2);
  }

  void openLogin() {
    setState(() => selectedTabIndex = 3);
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
      body: IndexedStack(
        index: selectedTabIndex,
        children: [
          _buildHomeContent(),
          _buildCategoriesPage(),
          _buildCartPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTabIndex,
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withValues(alpha: 0.35),
        onDestinationSelected: (index) {
          setState(() => selectedTabIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
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
                    '¡Sesión iniciada!',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ya puedes guardar productos en favoritos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
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
            setState(() {}); 
          },
        );
      },
    );
  }
}

class LoginFormContent extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginFormContent({super.key, required this.onLoginSuccess});

  @override
  State<LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<LoginFormContent> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isCreatingAccount = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (!formKey.currentState!.validate()) return;

    isLoggedIn.value = true;
    widget.onLoginSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCreatingAccount
              ? 'Cuenta de demostración creada.'
              : 'Sesión iniciada correctamente.',
        ),
      ),
    );
  }

  void showProviderNotConfigured(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'El acceso con $provider estará disponible '
          'cuando configuremos la autenticación.',
        ),
      ),
    );
  }

  Widget buildSocialButton({
    required Widget leading,
    required String label,
    required VoidCallback onPressed,
    required bool isApple,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isApple ? Colors.black : Colors.white,
          foregroundColor: isApple ? Colors.white : textColor,
          side: BorderSide(
            color: isApple ? Colors.black : const Color(0xFFDADCE0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.bolt, size: 45, color: textColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isCreatingAccount ? 'Crear cuenta' : 'Iniciar sesión',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCreatingAccount
                  ? 'Únete a TecnoStore'
                  : 'Accede a tu cuenta de TecnoStore',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            if (isCreatingAccount) ...[
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                  return 'Introduce un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),
            if (!isCreatingAccount)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La recuperación estará disponible '
                          'al conectar la autenticación.',
                        ),
                      ),
                    );
                  },
                  child: const Text('¿Has olvidado tu contraseña?'),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: submitForm,
                child: Text(
                  isCreatingAccount ? 'CREAR CUENTA' : 'INICIAR SESIÓN',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFDADCE0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    isCreatingAccount ? 'O REGÍSTRATE CON' : 'O CONTINÚA CON',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFDADCE0))),
              ],
            ),
            const SizedBox(height: 20),
            buildSocialButton(
              leading: const Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              label: 'Continuar con Google',
              isApple: false,
              onPressed: () => showProviderNotConfigured('Google'),
            ),
            const SizedBox(height: 12),
            buildSocialButton(
              leading: const Text('', style: TextStyle(fontSize: 25)),
              label: 'Continuar con Apple',
              isApple: true,
              onPressed: () => showProviderNotConfigured('Apple'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  isCreatingAccount = !isCreatingAccount;
                });
              },
              child: Text(
                isCreatingAccount
                    ? '¿Ya tienes cuenta? Inicia sesión'
                    : '¿No tienes cuenta? Regístrate',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryDetailPage extends StatefulWidget {
  final String name;
  final IconData icon;
  final List<Map<String, dynamic>> products;
  final ValueNotifier<Set<String>> favorites;
  final ValueChanged<Map<String, dynamic>> onFavorite;
  final VoidCallback onViewCart;

  const CategoryDetailPage({
    super.key,
    required this.name,
    required this.icon,
    required this.products,
    required this.favorites,
    required this.onFavorite,
    required this.onViewCart,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  String sortBy = 'Recomendados';
  Set<String> selectedBrands = {};
  bool onlyOffers = false;
  bool onlyAvailable = false;

  double _priceOf(Map<String, dynamic> product) {
    final price = (product['price'] as String)
        .replaceAll('€', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(price) ?? 0;
  }

  Future<void> _openSortOptions() async {
    const options = [
      'Recomendados',
      'Nombre',
      'Precio: menor a mayor',
      'Precio: mayor a menor',
      'Mayor descuento',
    ];
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Ordenar por', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            ...options.map((option) => ListTile(
              title: Text(option),
              trailing: sortBy == option
                  ? const Icon(Icons.check, color: textColor)
                  : null,
              onTap: () => Navigator.pop(sheetContext, option),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result != null && mounted) setState(() => sortBy = result);
  }

  Future<void> _openFilterOptions(List<String> brands) async {
    var draftBrands = Set<String>.from(selectedBrands);
    var draftOffers = onlyOffers;
    var draftAvailable = onlyAvailable;
    final result = await showModalBottomSheet<(Set<String>, bool, bool)>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filtrar productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('Marca', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: draftBrands.isEmpty,
                      showCheckmark: false,
                      selectedColor: primaryColor.withValues(alpha: 0.55),
                      onSelected: (_) => setSheetState(draftBrands.clear),
                    ),
                    ...brands.map((brand) => FilterChip(
                      label: Text(brand),
                      selected: draftBrands.contains(brand),
                      showCheckmark: false,
                      selectedColor: primaryColor.withValues(alpha: 0.55),
                      onSelected: (selected) => setSheetState(() {
                        if (selected) {
                          draftBrands.add(brand);
                        } else {
                          draftBrands.remove(brand);
                        }
                      }),
                    )),
                  ],
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('En oferta'),
                  value: draftOffers,
                  activeTrackColor: primaryColor,
                  onChanged: (value) => setSheetState(() => draftOffers = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  value: draftAvailable,
                  activeTrackColor: primaryColor,
                  onChanged: (value) => setSheetState(() => draftAvailable = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: textColor,
                    ),
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      (draftBrands, draftOffers, draftAvailable),
                    ),
                    child: const Text('Mostrar productos'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        selectedBrands = result.$1;
        onlyOffers = result.$2;
        onlyAvailable = result.$3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brands = widget.products
        .map((product) => product['brand'] as String? ?? 'Sin marca')
        .toSet()
        .toList()
      ..sort();
    final visibleProducts = widget.products
        .where(
          (product) =>
              (selectedBrands.isEmpty ||
                  selectedBrands.contains(product['brand'] as String? ?? 'Sin marca')) &&
              (!onlyOffers || product['discount'] != null) &&
              (!onlyAvailable || product['availability'] == 'Disponible'),
        )
        .toList();
    switch (sortBy) {
      case 'Precio: menor a mayor':
        visibleProducts.sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));
        break;
      case 'Precio: mayor a menor':
        visibleProducts.sort((a, b) => _priceOf(b).compareTo(_priceOf(a)));
        break;
      case 'Nombre':
        visibleProducts.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
        break;
      case 'Mayor descuento':
        visibleProducts.sort((a, b) {
          final discountA = int.tryParse(
                (a['discount'] as String? ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          final discountB = int.tryParse(
                (b['discount'] as String? ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          return discountB.compareTo(discountA);
        });
        break;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: widget.products.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 65, color: textColor),
                  const SizedBox(height: 12),
                  Text(
                    'Productos de ${widget.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Próximamente encontrarás aquí el catálogo.'),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openSortOptions,
                          icon: const Icon(Icons.sort, size: 18),
                          label: const Text('Ordenar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openFilterOptions(brands),
                          icon: const Icon(Icons.tune, size: 18),
                          label: Text(
                            onlyOffers || onlyAvailable || selectedBrands.isNotEmpty
                                ? 'Filtrar •'
                                : 'Filtrar',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleProducts.isEmpty
                      ? const Center(child: Text('No hay productos de esta marca.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: visibleProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 255,
                          ),
                          itemBuilder: (context, index) => ProductCard(
                            product: visibleProducts[index],
                            favorites: widget.favorites,
                            onFavorite: () => widget.onFavorite(visibleProducts[index]),
                            onViewCart: widget.onViewCart,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  final String query;
  final List<Map<String, dynamic>> products;
  final ValueNotifier<Set<String>> favorites;
  final ValueChanged<String> onFavorite;
  final VoidCallback onViewCart;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.products,
    required this.favorites,
    required this.onFavorite,
    required this.onViewCart,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController searchController;
  late String query;
  String sortBy = 'Recomendados';
  Set<String> selectedBrands = {};
  bool onlyOffers = false;
  bool onlyAvailable = false;

  @override
  void initState() {
    super.initState();
    query = widget.query;
    searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  double _priceOf(Map<String, dynamic> product) {
    final price = (product['price'] as String)
        .replaceAll('€', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(price) ?? 0;
  }

  Future<void> _openSortOptions() async {
    const options = [
      'Recomendados',
      'Nombre',
      'Precio: menor a mayor',
      'Precio: mayor a menor',
      'Mayor descuento',
    ];
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Ordenar por', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            ...options.map((option) => ListTile(
              title: Text(option),
              trailing: sortBy == option
                  ? const Icon(Icons.check, color: textColor)
                  : null,
              onTap: () => Navigator.pop(sheetContext, option),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result != null && mounted) setState(() => sortBy = result);
  }

  Future<void> _openFilterOptions(List<String> brands) async {
    var draftBrands = Set<String>.from(selectedBrands);
    var draftOffers = onlyOffers;
    var draftAvailable = onlyAvailable;
    final result = await showModalBottomSheet<(Set<String>, bool, bool)>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filtrar productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('Marca', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: draftBrands.isEmpty,
                      showCheckmark: false,
                      selectedColor: primaryColor.withValues(alpha: 0.55),
                      onSelected: (_) => setSheetState(draftBrands.clear),
                    ),
                    ...brands.map((brand) => FilterChip(
                      label: Text(brand),
                      selected: draftBrands.contains(brand),
                      showCheckmark: false,
                      selectedColor: primaryColor.withValues(alpha: 0.55),
                      onSelected: (selected) => setSheetState(() {
                        if (selected) {
                          draftBrands.add(brand);
                        } else {
                          draftBrands.remove(brand);
                        }
                      }),
                    )),
                  ],
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('En oferta'),
                  value: draftOffers,
                  activeTrackColor: primaryColor,
                  onChanged: (value) => setSheetState(() => draftOffers = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  value: draftAvailable,
                  activeTrackColor: primaryColor,
                  onChanged: (value) => setSheetState(() => draftAvailable = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: textColor,
                    ),
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      (draftBrands, draftOffers, draftAvailable),
                    ),
                    child: const Text('Mostrar productos'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        selectedBrands = result.$1;
        onlyOffers = result.$2;
        onlyAvailable = result.$3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _normalize(query.trim());

    final matchingQuery = widget.products.where((product) {
      final searchableText = _normalize(
        [
          product['name'] ?? '',
          product['brand'] ?? '',
          (product['categories'] as List? ?? []).join(' '),
          product['description'] ?? '',
        ].join(' '),
      );

      return searchableText.contains(normalizedQuery);
    }).toList();
    final brands = matchingQuery
        .map((product) => product['brand'] as String? ?? 'Sin marca')
        .toSet()
        .toList()
      ..sort();
    final results = matchingQuery.where((product) {
      return (selectedBrands.isEmpty ||
              selectedBrands.contains(product['brand'] as String? ?? 'Sin marca')) &&
          (!onlyOffers || product['discount'] != null) &&
          (!onlyAvailable || product['availability'] == 'Disponible');
    }).toList();
    switch (sortBy) {
      case 'Precio: menor a mayor':
        results.sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));
        break;
      case 'Precio: mayor a menor':
        results.sort((a, b) => _priceOf(b).compareTo(_priceOf(a)));
        break;
      case 'Nombre':
        results.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case 'Mayor descuento':
        results.sort((a, b) {
          final discountA = int.tryParse(
                (a['discount'] as String? ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          final discountB = int.tryParse(
                (b['discount'] as String? ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          return discountB.compareTo(discountA);
        });
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Buscar productos, marcas o categorías',
            border: InputBorder.none,
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Borrar búsqueda',
                    onPressed: () {
                      searchController.clear();
                      setState(() => query = '');
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: query.trim().isEmpty
          ? const Center(child: Text('Escribe para buscar productos.'))
          : matchingQuery.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'No encontramos "${query.trim()}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Prueba con otro nombre, marca o categoría.'),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    '${results.length} productos encontrados',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openSortOptions,
                          icon: const Icon(Icons.sort, size: 18),
                          label: const Text('Ordenar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openFilterOptions(brands),
                          icon: const Icon(Icons.tune, size: 18),
                          label: Text(
                            onlyOffers || onlyAvailable || selectedBrands.isNotEmpty
                                ? 'Filtrar •'
                                : 'Filtrar',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (results.isEmpty)
                  const Expanded(
                    child: Center(child: Text('No hay productos con estos filtros.')),
                  )
                else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 255,
                        ),
                    itemBuilder: (context, index) {
                      final product = results[index];

                      return ProductCard(
                        product: product,
                        favorites: widget.favorites,
                        onFavorite: () =>
                            widget.onFavorite(product['name'] as String),
                        onViewCart: widget.onViewCart,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

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
