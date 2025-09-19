// =============================================================================
// ARCHIVO: features/auth/presentation/pages/forgot_password_page.dart (VERSIÓN FINAL)
// FUNCIÓN:   Pantalla que solicita el envío del código. Ahora es flexible:
//            - Si recibe un email, lo usa directamente.
//            - Si no recibe un email, muestra un campo para que el usuario lo escriba.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  // --- CAMBIO CLAVE: El email ahora es opcional ---
  final String? email;
  const ForgotPasswordPage({super.key, this.email});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // --- CAMBIO CLAVE: Determina si el email fue pre-cargado ---
  bool get _isEmailProvided => widget.email != null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  Future<void> _sendRecoveryEmail() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final emailToSend = _emailController.text.trim();

    try {
      final message = await authProvider.forgotPassword(emailToSend);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(email: emailToSend),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- CAMBIO CLAVE: Muestra un widget u otro dependiendo del contexto ---
              if (_isEmailProvided)
              // Caso: Vienes desde el perfil
                Text(
                  'Se enviará un código de recuperación al correo:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                )
              else
              // Caso: Vienes desde el login
                Column(
                  children: [
                    Text(
                      'Ingresa tu correo electrónico para recibir un código de recuperación.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Por favor, ingresa un correo válido.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendRecoveryEmail,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar Código'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}