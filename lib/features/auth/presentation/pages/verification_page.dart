// =============================================================================
// ARCHIVO: features/auth/presentation/pages/verification_page.dart (VERSIÓN FINAL)
// FUNCIÓN:   Pantalla para introducir el código. Ahora recibe el email para
//            saber a quién pertenece el token.
// =============================================================================

import 'package:flutter/material.dart';
import 'reset_password_page.dart';
import '../widgets/lock_avatar.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _verifyToken() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(
            token: _tokenController.text.trim(),
            email: widget.email, // Pasa el email a la siguiente pantalla
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black54),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const LockAvatar(radius: 60),
              const SizedBox(height: 40),
              const Text(
                'Escribe el código de verificación',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Revisa tu correo (${widget.email}) y pega aquí el código que te enviamos.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _tokenController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, letterSpacing: 8),
                decoration: const InputDecoration(
                  labelText: 'Código de Recuperación',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa el código.';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F54EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Continuar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}