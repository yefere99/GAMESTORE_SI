import 'package:flutter/material.dart';

class PaymentMethodForm extends StatefulWidget {
  final String method;
  final VoidCallback onValidSubmit;

  const PaymentMethodForm({
    super.key,
    required this.method,
    required this.onValidSubmit,
  });

  @override
  State<PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<PaymentMethodForm> {
  final _formKey = GlobalKey<FormState>();

  // Campos comunes
  String cardNumber = '', expiry = '', cvv = '';
  String phone = '';
  String username = '', password = '';

  @override
  Widget build(BuildContext context) {
    Widget form;

    switch (widget.method) {
      case 'Tarjeta de crédito':
        form = Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Número de tarjeta',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              maxLength: 16,
              validator: (v) => RegExp(r'^\d{16}$').hasMatch(v ?? '') ? null : 'Tarjeta inválida',
              onChanged: (v) => cardNumber = v,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Fecha de vencimiento (MM/AA)',
                prefixIcon: Icon(Icons.date_range),
              ),
              maxLength: 5,
              validator: (v) => RegExp(r'^\d{2}/\d{2}$').hasMatch(v ?? '') ? null : 'Formato inválido',
              onChanged: (v) => expiry = v,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'CVV',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              keyboardType: TextInputType.number,
              maxLength: 3,
              validator: (v) => RegExp(r'^\d{3}$').hasMatch(v ?? '') ? null : 'CVV inválido',
              onChanged: (v) => cvv = v,
            ),
          ],
        );
        break;

      case 'Nequi':
        form = Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Número del remitente',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (v) => RegExp(r'^3\d{9}$').hasMatch(v ?? '') ? null : 'Número inválido',
              onChanged: (v) => phone = v,
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.4)),
              ),
              alignment: Alignment.center,
              child: const Text('🔳 QR simulado', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
        break;

      case 'Daviplata':
        form = Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => (v != null && v.length >= 4) ? null : 'Usuario inválido',
              onChanged: (v) => username = v,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (v) => (v != null && v.length >= 6) ? null : 'Contraseña inválida',
              onChanged: (v) => password = v,
            ),
          ],
        );
        break;

      default:
        return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            form,
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Confirmar pago',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onValidSubmit();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
