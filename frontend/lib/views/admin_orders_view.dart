import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/env.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  List<dynamic> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('${Env.apiUrl}/api/orders'));

      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
          loading = false;
        });
      } else {
        throw Exception('Error al cargar órdenes');
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> markAsNotified(String orderId, String email) async {
    final url = Uri.parse('${Env.apiUrl}/api/orders/$orderId/notify');

    try {
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        setState(() {
          orders = orders.map((order) {
            if (order['orderId'] == orderId) {
              order['notified'] = true;
            }
            return order;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se notificó por correo a $email')),
        );
      } else {
        throw Exception('No se pudo marcar como notificada');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy – hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes realizadas')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No hay órdenes registradas.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    final order = orders[index];
                    final orderId = order["orderId"] ?? "N/A";
                    final isNotified = order["notified"] == true;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: isNotified ? const Color.fromARGB(255, 240, 2, 54) : Colors.deepPurple,
                      child: ListTile(
                        leading: Icon(
                          isNotified ? Icons.mark_email_read : Icons.receipt_long,
                          color: isNotified ? Colors.green : Colors.deepPurple,
                        ),
                        title: Text('#$orderId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cliente: ${order["name"]}'),
                            Text('Dirección: ${order["address"]}'),
                            Text('Pago: ${order["paymentMethod"]}'),
                            Text('Total: \$${order["total"].toInt()}'),
                            Text('Fecha: ${formatDate(order["createdAt"])}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: isNotified ? 'Ya enviado' : 'Marcar como enviado',
                          icon: Icon(
                            Icons.send,
                            color: isNotified ? const Color.fromARGB(255, 215, 37, 37) : Colors.green,
                          ),
                          onPressed: isNotified
                              ? null
                              : () => markAsNotified(orderId, order["email"]),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Detalle de orden #$orderId'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cliente: ${order["name"]}'),
                                    Text('Email: ${order["email"]}'),
                                    Text('Teléfono: ${order["phone"]}'),
                                    Text('Dirección: ${order["address"]}'),
                                    Text('Método de pago: ${order["paymentMethod"]}'),
                                    const SizedBox(height: 12),
                                    const Text('Productos:',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    ...List.from(order["items"]).map((item) => Text(
                                        '${item["name"]} x${item["quantity"]} — \$${item["price"]}')),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
