import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_userapp/data/models/cartmodel/cartmodel.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_state.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_event.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_state.dart';
import 'package:flutter_application_userapp/logic/order/bloc/orderbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/order/bloc/orderbloc_event.dart';
import 'package:flutter_application_userapp/view/ordersscreen/orderscreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox();
              return TextButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<CartBloc>().add(ClearCart());
                          Navigator.pop(context);
                        },
                        child: const Text('Clear',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.white),
                label: const Text('Clear',
                    style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Add items to get started!',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Continue Shopping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) =>
                      _CartItemCard(item: state.items[index]),
                ),
              ),
              _OrderSummary(state: state),
            ],
          );
        },
      ),
    );
  }
}

// ── Cart Item Card ─────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final Cartmodel item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(item.product.category,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '\$${item.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo)),
                    Row(children: [
                      InkWell(
                        onTap: () {
                          if (item.quantity > 1) {
                            context.read<CartBloc>().add(
                                UpdateQuantity(
                                    productId: item.product.id,
                                    quantity: item.quantity - 1));
                          } else {
                            context.read<CartBloc>().add(
                                RemoveFromCart(item.product.id));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey[300]!),
                              borderRadius:
                                  BorderRadius.circular(6)),
                          child: const Icon(Icons.remove,
                              size: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10),
                        child: Text('${item.quantity}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                      InkWell(
                        onTap: () =>
                            context.read<CartBloc>().add(
                                UpdateQuantity(
                                    productId: item.product.id,
                                    quantity: item.quantity + 1)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius:
                                  BorderRadius.circular(6)),
                          child: const Icon(Icons.add,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context
                .read<CartBloc>()
                .add(RemoveFromCart(item.product.id)),
            icon:
                const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ]),
      ),
    );
  }
}

// ── Order Summary ──────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartState state;
  const _OrderSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final total =
        state.items.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Items',
                style: TextStyle(color: Colors.grey)),
            Text('${state.itemCount}',
                style:
                    const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text('\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                _showCheckoutDialog(context, state, total),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
                'Checkout  •  \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  void _showCheckoutDialog(
      BuildContext context, CartState state, double total) {
    final addressController     = TextEditingController();
    final phoneController       = TextEditingController();
    final altPhoneController    = TextEditingController();
    final addressFormKey        = GlobalKey<FormState>();

    // Pre-fill phone from profile
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.uid : '';
    if (uid.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          phoneController.text = doc.data()?['phone'] ?? '';
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CartBloc>()),
          BlocProvider.value(value: context.read<OrderBloc>()),
        ],
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: addressFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────
                    Row(children: [
                      const Icon(Icons.shopping_bag_outlined,
                          color: Colors.indigo),
                      const SizedBox(width: 8),
                      const Text('Confirm Your Order',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 4),
                    Text('${state.itemCount} item(s) in your cart',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 20),

                    // ── Delivery Address ─────────────
                    const _SectionTitle(
                        icon: Icons.location_on_outlined,
                        title: 'Delivery Address'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Full Address',
                        hintText:
                            'House No, Street, City, State, PIN',
                        prefixIcon: const Icon(
                            Icons.home_outlined,
                            color: Colors.indigo),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.indigo, width: 2),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter delivery address'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Phone Numbers ─────────────────
                    const _SectionTitle(
                        icon: Icons.phone_outlined,
                        title: 'Contact Numbers'),
                    const SizedBox(height: 10),

                    // Primary phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+91 9999999999',
                        prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Colors.indigo),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.indigo, width: 2),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter phone number';
                        }
                        if (v.length < 10) {
                          return 'Enter valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Alternative phone
                    TextFormField(
                      controller: altPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Alternative Phone (Optional)',
                        hintText: '+91 8888888888',
                        prefixIcon: const Icon(
                            Icons.phone_callback_outlined,
                            color: Colors.indigo),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.indigo, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Order Summary ─────────────────
                    const _SectionTitle(
                        icon: Icons.receipt_outlined,
                        title: 'Order Summary'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items (${state.itemCount})',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14)),
                            Text('\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delivery',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14)),
                            Text(
                              total > 50 ? 'FREE' : '\$5.00',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: total > 50
                                      ? Colors.green
                                      : null,
                                  fontWeight: total > 50
                                      ? FontWeight.bold
                                      : null),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold)),
                            Text(
                              '\$${(total > 50 ? total : total + 5).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                          ],
                        ),
                      ]),
                    ),

                    const SizedBox(height: 8),
                    if (total > 50)
                      Row(children: [
                        const Icon(Icons.local_shipping_outlined,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text('You qualify for FREE delivery!',
                            style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ])
                    else
                      Row(children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey[500], size: 14),
                        const SizedBox(width: 4),
                        Text(
                            'Add \$${(50 - total).toStringAsFixed(2)} more for FREE delivery',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12)),
                      ]),

                    const SizedBox(height: 20),

                    // ── Place Order Button ─────────────
                    Builder(
                      builder: (innerContext) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!addressFormKey.currentState!
                                .validate()) return;

                            final finalTotal =
                                total > 50 ? total : total + 5;

                            final authState = innerContext
                                .read<AuthBloc>()
                                .state;
                            final uid =
                                authState is Authenticated
                                    ? authState.uid
                                    : '';
                            final name =
                                authState is Authenticated
                                    ? authState.name
                                    : '';
                            final email =
                                authState is Authenticated
                                    ? authState.email
                                    : '';
                            final phone =
                                phoneController.text.trim();
                            final altPhone =
                                altPhoneController.text.trim();

                            // Place order
                            innerContext
                                .read<OrderBloc>()
                                .add(PlaceOrder(
                                  items: state.items,
                                  totalPrice: finalTotal,
                                  address: addressController
                                      .text
                                      .trim(),
                                  userId: uid,
                                  userName: name,
                                  userEmail: email,
                                  userPhone: phone,
                                  userAltPhone: altPhone,
                                ));

                            // Clear cart
                            innerContext
                                .read<CartBloc>()
                                .add(ClearCart());

                            Navigator.pop(innerContext);
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const OrdersScreen()),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '🎉 Order placed successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: const Icon(
                              Icons.check_circle_outline),
                          label: const Text('Place Order',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style:
                                TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Title ──────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: Colors.indigo, size: 18),
      const SizedBox(width: 6),
      Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold)),
    ]);
  }
}