import 'package:flutter/material.dart';

import 'app_state.dart';
import 'services/api_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartProducts;

  const CheckoutPage({super.key, required this.cartProducts});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'España');
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;
  static const double _freeShippingThreshold = 50;
  static const double _shippingCost = 3.99;

  @override
  void initState() {
    super.initState();
    final user = currentUser.value;
    if (user == null) return;

    _nameController.text = _profileValue(user, const ['shipping_name', 'name']);
    _addressController.text = _profileValue(user, const [
      'shipping_address',
      'address',
    ]);
    _cityController.text = _profileValue(user, const ['shipping_city', 'city']);
    _postalCodeController.text = _profileValue(user, const [
      'shipping_postal_code',
      'postal_code',
      'zip_code',
    ]);
    _countryController.text = _profileValue(user, const [
      'shipping_country',
      'country',
    ], fallback: 'España');
    _phoneController.text = _profileValue(user, const [
      'shipping_phone',
      'phone',
    ]);
  }

  String _profileValue(
    Map<String, dynamic> user,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = user[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    return fallback;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();

    final text = (value?.toString() ?? '0')
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .trim();
    if (text.contains(',')) {
      return double.tryParse(text.replaceAll('.', '').replaceAll(',', '.')) ??
          0;
    }
    return double.tryParse(text) ?? 0;
  }

  String _formatPrice(double price) {
    final cents = (price * 100).round();
    final whole = (cents ~/ 100).toString();
    final decimals = (cents % 100).toString().padLeft(2, '0');

    return '$whole,$decimals €';
  }

  double get _estimatedTotal {
    double total = 0;

    for (final entry in widget.cartProducts) {
      final product = entry['product'] as Map<String, dynamic>;
      final quantity = entry['quantity'] as int;

      total += _parsePrice(product['price']) * quantity;
    }

    return total + _shippingCostFor(total);
  }

  double get _subtotal {
    double total = 0;
    for (final entry in widget.cartProducts) {
      final product = entry['product'] as Map<String, dynamic>;
      total += _parsePrice(product['price']) * (entry['quantity'] as int);
    }
    return total;
  }

  double _shippingCostFor(double subtotal) =>
      subtotal >= _freeShippingThreshold ? 0 : _shippingCost;

  Widget _priceRow(String label, String amount, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 14,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
      color: textColor,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(amount, style: style),
      ],
    );
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (widget.cartProducts.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('La cesta está vacía.')));
      return;
    }

    final items = <Map<String, dynamic>>[];

    for (final entry in widget.cartProducts) {
      final product = entry['product'] as Map<String, dynamic>;
      final quantity = entry['quantity'] as int;
      final productId = int.tryParse(product['id']?.toString() ?? '');

      if (productId == null || productId < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uno de los productos no tiene un ID válido.'),
          ),
        );
        return;
      }

      if (quantity < 1 || quantity > 99) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La cantidad de un producto no es válida.'),
          ),
        );
        return;
      }

      items.add({'product_id': productId, 'quantity': quantity});
    }

    if (items.length > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El pedido no puede superar los 30 productos diferentes.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final order = await ApiService.createOrder(
        shippingName: _nameController.text,
        shippingAddress: _addressController.text,
        shippingCity: _cityController.text,
        shippingPostalCode: _postalCodeController.text,
        shippingCountry: _countryController.text,
        shippingPhone: _phoneController.text,
        items: items,
      );

      if (!mounted) return;

      Navigator.of(context).pop(order);
    } catch (error) {
      if (!mounted) return;

      final message = error is ApiException
          ? error.message
          : 'No se ha podido registrar el pedido. Comprueba tu conexión e inténtalo de nuevo.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finalizar compra',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Resumen del pedido',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.cartProducts.map((entry) {
              final product = entry['product'] as Map<String, dynamic>;
              final quantity = entry['quantity'] as int;

              return Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text(product['name']?.toString() ?? 'Producto'),
                  subtitle: Text('Cantidad: $quantity'),
                  trailing: Text(
                    _formatPrice(_parsePrice(product['price']) * quantity),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _priceRow('Productos', _formatPrice(_subtotal)),
                  const SizedBox(height: 6),
                  _priceRow(
                    'Envío',
                    _shippingCostFor(_subtotal) == 0
                        ? 'Gratis'
                        : _formatPrice(_shippingCost),
                  ),
                  const Divider(height: 18),
                  _priceRow('Total', _formatPrice(_estimatedTotal), bold: true),
                  const SizedBox(height: 5),
                  Text(
                    _subtotal >= _freeShippingThreshold
                        ? '¡Tu pedido tiene envío gratis!'
                        : 'Envío gratis a partir de 50,00 €',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Método de pago',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const ListTile(
                leading: Icon(Icons.account_balance_outlined),
                title: Text('Transferencia bancaria'),
                subtitle: Text(
                  'El pedido quedará pendiente hasta confirmar el pago.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Datos de envío',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _nameController,
              label: 'Nombre del destinatario',
              icon: Icons.person_outline,
              validator: _validateRequired,
              textCapitalization: TextCapitalization.words,
            ),
            _buildField(
              controller: _addressController,
              label: 'Dirección completa',
              icon: Icons.location_on_outlined,
              validator: _validateRequired,
            ),
            _buildField(
              controller: _cityController,
              label: 'Ciudad',
              icon: Icons.location_city_outlined,
              validator: _validateRequired,
              textCapitalization: TextCapitalization.words,
            ),
            _buildField(
              controller: _postalCodeController,
              label: 'Código postal',
              icon: Icons.markunread_mailbox_outlined,
              validator: _validateRequired,
              keyboardType: TextInputType.number,
            ),
            _buildField(
              controller: _countryController,
              label: 'País',
              icon: Icons.public,
              validator: _validateRequired,
              textCapitalization: TextCapitalization.words,
            ),
            _buildField(
              controller: _phoneController,
              label: 'Teléfono (opcional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selectionColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Al confirmar, el pedido se registrará como pendiente. La transferencia deberá realizarse por separado.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSubmitting ? 'REGISTRANDO PEDIDO...' : 'CONFIRMAR PEDIDO',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }
}
