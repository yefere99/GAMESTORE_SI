import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class OrderConfirmationView extends StatefulWidget {
  final String orderId;

  const OrderConfirmationView({super.key, required this.orderId});

  @override
  State<OrderConfirmationView> createState() => _OrderConfirmationViewState();
}

class _OrderConfirmationViewState extends State<OrderConfirmationView> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Pedido confirmado'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Gracias por tu compra!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tu pedido ha sido procesado correctamente.',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Número de orden:',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                        Text(
                          widget.orderId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Volver al inicio'),
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 15,
            minBlastForce: 8,
            gravity: 0.3,
            shouldLoop: false,
          ),
        ],
      ),
    );
  }
}
