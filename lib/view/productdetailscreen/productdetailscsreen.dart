import 'package:flutter/material.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_event.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailScreen extends StatelessWidget {
  final Productmodel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Cart badge in app bar
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (state.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${state.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product Image ───────────────────
                  Hero(
                    tag: 'product-${product.id}',
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(24),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Product name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating row
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < product.rating.floor()
                                    ? Icons.star
                                    : i < product.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 5.0',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Price
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description heading
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Add to Cart ──────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                // Check if product already in cart
                final inCart = cartState.items.any(
                  (i) => i.product.id == product.id,
                );
                final cartItem = inCart
                    ? cartState.items.firstWhere(
                        (i) => i.product.id == product.id,
                      )
                    : null;

                return Row(
                  children: [
                    // Price column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // If in cart show quantity controls
                    if (inCart && cartItem != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (cartItem.quantity > 1) {
                                  context.read<CartBloc>().add(
                                    UpdateQuantity(
                                      productId: product.id,
                                      quantity: cartItem.quantity - 1,
                                    ),
                                  );
                                } else {
                                  context.read<CartBloc>().add(
                                    RemoveFromCart(product.id),
                                  );
                                }
                              },
                              icon: const Icon(Icons.remove, size: 18),
                            ),
                            Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.read<CartBloc>().add(
                                UpdateQuantity(
                                  productId: product.id,
                                  quantity: cartItem.quantity + 1,
                                ),
                              ),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Add to cart button
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<CartBloc>().add(AddToCart(product));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
