import 'package:flutter/material.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_userapp/logic/order/bloc/orderbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/order/bloc/orderbloc_event.dart';
import 'package:flutter_application_userapp/logic/order/bloc/orderbloc_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<OrderBloc>().add(LoadMyOrders(authState.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message),
                ],
              ),
            );
          }
          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start shopping to see orders here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.orderId.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            _StatusBadge(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.orderedAt.day}/${order.orderedAt.month}/${order.orderedAt.year}  '
                          '${order.orderedAt.hour}:${order.orderedAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(height: 20),
                        // Items
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  '×${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.indigo,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                order.address,
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color => switch (status) {
    'pending' => Colors.orange,
    'confirmed' => Colors.blue,
    'shipped' => Colors.purple,
    'delivered' => Colors.green,
    'cancelled' => Colors.red,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
