import 'package:flutter/material.dart';

import 'app_state.dart';
import 'product_widgets.dart';
import 'search_results_page.dart';

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
                child: Text(
                  'Ordenar por',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                trailing: sortBy == option
                    ? const Icon(Icons.check, color: textColor)
                    : null,
                onTap: () => Navigator.pop(sheetContext, option),
              ),
            ),
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
                const Text(
                  'Filtrar productos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Marca',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
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
                    ...brands.map(
                      (brand) => FilterChip(
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
                      ),
                    ),
                  ],
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('En oferta'),
                  value: draftOffers,
                  activeTrackColor: primaryColor,
                  onChanged: (value) =>
                      setSheetState(() => draftOffers = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  value: draftAvailable,
                  activeTrackColor: primaryColor,
                  onChanged: (value) =>
                      setSheetState(() => draftAvailable = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: textColor,
                    ),
                    onPressed: () => Navigator.pop(sheetContext, (
                      draftBrands,
                      draftOffers,
                      draftAvailable,
                    )),
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
    final brands =
        widget.products
            .map((product) => product['brand'] as String? ?? 'Sin marca')
            .toSet()
            .toList()
          ..sort();
    final visibleProducts = widget.products
        .where(
          (product) =>
              (selectedBrands.isEmpty ||
                  selectedBrands.contains(
                    product['brand'] as String? ?? 'Sin marca',
                  )) &&
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
          final discountA =
              int.tryParse(
                (a['discount'] as String? ?? '').replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                ),
              ) ??
              0;
          final discountB =
              int.tryParse(
                (b['discount'] as String? ?? '').replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                            onlyOffers ||
                                    onlyAvailable ||
                                    selectedBrands.isNotEmpty
                                ? 'Filtrar •'
                                : 'Filtrar',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleProducts.isEmpty
                      ? const Center(
                          child: Text('No hay productos de esta marca.'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: visibleProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 255,
                              ),
                          itemBuilder: (context, index) => ProductCard(
                            product: visibleProducts[index],
                            favorites: widget.favorites,
                            onFavorite: () =>
                                widget.onFavorite(visibleProducts[index]),
                            onViewCart: widget.onViewCart,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
