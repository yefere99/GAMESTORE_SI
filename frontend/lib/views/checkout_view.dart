import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../widgets/payment_method_form.dart';
import '../widgets/summary_dialog.dart';
import '../views/order_confirmation_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  String name = '', address = '', phone = '', email = '', paymentMethod = 'Efectivo';
  final List<String> paymentOptions = ['Efectivo', 'Tarjeta de crédito', 'Nequi', 'Daviplata'];

  bool _loading = false;
  bool _paymentValidated = false;

  IconData getPaymentIcon() {
    switch (paymentMethod) {
      case 'Tarjeta de crédito':
        return Icons.credit_card;
      case 'Nequi':
        return Icons.qr_code;
      case 'Daviplata':
        return Icons.lock;
      default:
        return Icons.payments;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartService>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío.')),
      );
      return;
    }

    if (!_paymentValidated && paymentMethod != 'Efectivo') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor confirma el método de pago.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Mostrar resumen antes de enviar
      final confirmed = await showSummaryDialog(
        context: context,
        name: name,
        address: address,
        phone: phone,
        email: email,
        paymentMethod: paymentMethod,
        total: cart.totalPrice,
      );

      if (!confirmed) {
        setState(() => _loading = false);
        return;
      }

      if (paymentMethod == 'Efectivo') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se hará cobro contraentrega')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pago aprobado con $paymentMethod')),
        );
      }

      final orderId = await OrderService.submitOrder(
        context: context,
        name: name,
        address: address,
        phone: phone,
        email: email,
        paymentMethod: paymentMethod,
      );

      cart.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderConfirmationView(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la orden: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentIcon = getPaymentIcon();

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Icon(
                  paymentIcon,
                  key: ValueKey(paymentIcon),
                  size: 70,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "Simulación de pasarela de pago",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                onChanged: (v) => name = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección de entrega'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                onChanged: (v) => address = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (!RegExp(r'^3\d{9}$').hasMatch(v)) return 'Número inválido';
                  return null;
                },
                onChanged: (v) => phone = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$').hasMatch(v)) return 'Correo inválido';
                  return null;
                },
                onChanged: (v) => email = v,
              ),

              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: paymentOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                    _paymentValidated = false;
                  });
                },
              ),

              const SizedBox(height: 20),

              if (paymentMethod != 'Efectivo')
                PaymentMethodForm(
                  method: paymentMethod,
                  onValidSubmit: () {
                    setState(() => _paymentValidated = true);
                    _submit(); // ✅ Ejecutar automáticamente
                  },
                ),

              const SizedBox(height: 20),

              if (paymentMethod == 'Efectivo')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.deepPurpleAccent,
                    ),
                    onPressed: _loading ? null : _submit,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _loading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              key: const ValueKey('text'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.lock_outline),
                                SizedBox(width: 10),
                                Text(
                                  'Pagar ahora',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
