import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/curved_background.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

    Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.register(
        nombreUsuario: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.grey.shade700),
        title: Image.asset(
          'assets/images/logo-inicio.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const CurvedBackground(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('Regístrate', style: textTheme.displayLarge),
                    const SizedBox(height: 30),

                    Text('Nombre', style: textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Ingresa tu nombre completo'),
                      validator: (value) => (value == null || value.isEmpty) ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 20),

                    Text('Correo', style: textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: 'Ingresa tu correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El correo es requerido';
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Ingresa un correo válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Text('Contraseña', style: textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Crea una contraseña'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'La contraseña es requerida';
                        if (value.length < 8) return 'Debe tener al menos 8 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Text('Confirma la contraseña', style: textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Vuelve a escribir la contraseña'),
                      validator: (value) {
                        if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                            : Text('Acceder', style: textTheme.labelLarge),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.bodyLarge,
                          children: [
                            const TextSpan(text: '¿Ya estas registrado/a? '),
                            TextSpan(
                              text: 'Inicia sesión.',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
