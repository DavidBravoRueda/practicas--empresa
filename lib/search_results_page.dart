import 'package:flutter/material.dart';

import 'app_state.dart';
import 'product_widgets.dart';

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
                      selectedColor: selectionColor.withValues(alpha: 0.16),
                      onSelected: (_) => setSheetState(draftBrands.clear),
                    ),
                    ...brands.map(
                      (brand) => FilterChip(
                        label: Text(brand),
                        selected: draftBrands.contains(brand),
                        showCheckmark: false,
                        selectedColor: selectionColor.withValues(alpha: 0.16),
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
                  activeTrackColor: selectionColor,
                  onChanged: (value) =>
                      setSheetState(() => draftOffers = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  value: draftAvailable,
                  activeTrackColor: selectionColor,
                  onChanged: (value) =>
                      setSheetState(() => draftAvailable = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
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
    final brands =
        matchingQuery
            .map((product) => product['brand'] as String? ?? 'Sin marca')
            .toSet()
            .toList()
          ..sort();
    final results = matchingQuery.where((product) {
      return (selectedBrands.isEmpty ||
              selectedBrands.contains(
                product['brand'] as String? ?? 'Sin marca',
              )) &&
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
        results.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
        break;
      case 'Mayor descuento':
        results.sort((a, b) {
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
                            side: const BorderSide(color: borderColor),
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
                            side: const BorderSide(color: borderColor),
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
                if (results.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No hay productos con estos filtros.'),
                    ),
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
