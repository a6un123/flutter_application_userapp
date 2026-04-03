import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_userapp/data/models/ordermodel/ordermodel.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_state.dart';
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
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCancelledSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order cancelled successfully'),
                backgroundColor: Colors.orange,
              ),
            );
            // Reload orders
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              context.read<OrderBloc>().add(LoadMyOrders(authState.uid));
            }
          }
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
                return _OrderCard(order: order);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── Order Card ─────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _showTimeline = false;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}  '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final canCancel = order.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderId.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(order.orderedAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const Divider(height: 20),

            // ── Items ─────────────────────────────
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
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
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

            // ── Total + Address ───────────────────
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
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),

            // ── Phone Numbers ─────────────────────
            if (order.userPhone.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.userPhone,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (order.userAltPhone.isNotEmpty) ...[
                    const Text('  |  ', style: TextStyle(color: Colors.grey)),
                    const Icon(
                      Icons.phone_callback_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.userAltPhone,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 12),

            // ── Timeline Toggle ───────────────────
            GestureDetector(
              onTap: () => setState(() => _showTimeline = !_showTimeline),
              child: Row(
                children: [
                  const Icon(
                    Icons.timeline_outlined,
                    color: Colors.indigo,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Order Timeline',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showTimeline
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),

            if (_showTimeline) ...[
              const SizedBox(height: 12),
              _OrderTimeline(order: order),
            ],

            // ── Cancel Button ─────────────────────
            if (canCancel) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, order),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 8),
            Text(
              'Order #${order.orderId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Only pending orders can be cancelled.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(CancelMyOrder(order.orderId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

// ── Order Timeline ─────────────────────────────────────────
class _OrderTimeline extends StatelessWidget {
  final OrderModel order;
  const _OrderTimeline({required this.order});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}  '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (order.status == 'cancelled') {
      return _CancelledTimeline(
        orderedAt: order.orderedAt,
        cancelledAt: order.cancelledAt,
      );
    }

    final steps = [
      _Step(
        label: 'Order Placed',
        subtitle: 'Your order has been placed',
        date: _formatDate(order.orderedAt),
        isCompleted: true,
        isActive: order.status == 'pending',
        color: Colors.indigo,
        icon: Icons.shopping_bag_outlined,
      ),
      _Step(
        label: 'Confirmed',
        subtitle: 'Order confirmed by seller',
        date: _formatDate(order.confirmedAt),
        isCompleted: order.confirmedAt != null,
        isActive: order.status == 'confirmed',
        color: Colors.blue,
        icon: Icons.check_circle_outline,
      ),
      _Step(
        label: 'Shipped',
        subtitle: 'Order is on the way',
        date: _formatDate(order.shippedAt),
        isCompleted: order.shippedAt != null,
        isActive: order.status == 'shipped',
        color: Colors.purple,
        icon: Icons.local_shipping_outlined,
      ),
      _Step(
        label: 'Delivered',
        subtitle: 'Order delivered successfully',
        date: _formatDate(order.deliveredAt),
        isCompleted: order.deliveredAt != null,
        isActive: order.status == 'delivered',
        color: Colors.green,
        icon: Icons.done_all,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          return _TimelineItem(step: steps[i], isLast: i == steps.length - 1);
        }),
      ),
    );
  }
}

class _Step {
  final String label;
  final String subtitle;
  final String date;
  final bool isCompleted;
  final bool isActive;
  final Color color;
  final IconData icon;

  const _Step({
    required this.label,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
    required this.isActive,
    required this.color,
    required this.icon,
  });
}

class _TimelineItem extends StatelessWidget {
  final _Step step;
  final bool isLast;
  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? step.color
                    : step.isActive
                    ? step.color.withOpacity(0.3)
                    : Colors.grey[200],
                shape: BoxShape.circle,
                border: step.isActive && !step.isCompleted
                    ? Border.all(color: step.color, width: 2)
                    : null,
              ),
              child: Icon(
                step.icon,
                size: 18,
                color: step.isCompleted
                    ? Colors.white
                    : step.isActive
                    ? step.color
                    : Colors.grey[400],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: step.isCompleted
                    ? step.color.withOpacity(0.4)
                    : Colors.grey[200],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: step.isCompleted
                            ? Colors.black87
                            : step.isActive
                            ? step.color
                            : Colors.grey[400],
                      ),
                    ),
                    if (step.isCompleted)
                      Icon(Icons.check, size: 14, color: step.color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: step.isCompleted || step.isActive
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                ),
                if (step.date.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.date,
                    style: TextStyle(
                      fontSize: 11,
                      color: step.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelledTimeline extends StatelessWidget {
  final DateTime orderedAt;
  final DateTime? cancelledAt;
  const _CancelledTimeline({required this.orderedAt, this.cancelledAt});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}  '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          _TimelineItem(
            step: _Step(
              label: 'Order Placed',
              subtitle: 'Order was placed',
              date: _formatDate(orderedAt),
              isCompleted: true,
              isActive: false,
              color: Colors.indigo,
              icon: Icons.shopping_bag_outlined,
            ),
            isLast: false,
          ),
          _TimelineItem(
            step: _Step(
              label: 'Order Cancelled',
              subtitle: 'Order was cancelled',
              date: _formatDate(cancelledAt),
              isCompleted: true,
              isActive: false,
              color: Colors.red,
              icon: Icons.cancel_outlined,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

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
