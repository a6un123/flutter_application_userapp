import 'package:flutter/material.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_event.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AdminRegisterSubmit(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Registration'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated && state.role == 'admin') {
            context.go('/admin');
          }
          if (state is Autherror) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 70,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Admin Registration',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Text(
                        'Admin accounts have full access to manage products and orders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Admin Name',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Admin Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Register as Admin',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
