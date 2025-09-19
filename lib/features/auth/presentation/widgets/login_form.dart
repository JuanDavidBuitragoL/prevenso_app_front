// =============================================================================
// ARCHIVO: features/auth/presentation/widgets/login_form.dart (VERSIÓN FINAL)
// FUNCIÓN:   Añade el enlace de "Olvidaste tu contraseña" y navega a la
//            pantalla de recuperación sin pasarle ningún email.
// =============================================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../main_screen.dart';
import '../pages/forgot_password_page.dart'; // <-- Importar la página
import '../pages/register_page.dart';
import '../providers/auth_provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  String? _selectedUser;
  List<String> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _apiService.getUsuarios();
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar usuarios: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(
        _selectedUser!,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text('Inicia sesión', style: textTheme.displayLarge),
              const SizedBox(height: 30),

              Text('Nombre', style: textTheme.bodyLarge),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _selectedUser,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _users.isEmpty
                      ? 'Cargando usuarios...'
                      : 'Selecciona tu nombre',
                ),
                items: _users.map((String user) {
                  return DropdownMenuItem<String>(
                    value: user,
                    child: Text(user),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUser = newValue;
                  });
                },
                validator: (value) =>
                value == null ? 'Por favor, selecciona un nombre' : null,
              ),
              const SizedBox(height: 15),

              Text('Contraseña', style: textTheme.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                const InputDecoration(hintText: 'Ingresa tu contraseña'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // --- CAMBIO CLAVE: Enlace para recuperar contraseña ---
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Navega a la pantalla de recuperación SIN pasar email
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : Text('Acceder', style: textTheme.labelLarge),
                ),
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    style: textTheme.bodyLarge,
                    children: [
                      const TextSpan(text: '¿Nuevo usuario/a? '),
                      TextSpan(
                        text: 'Regístrate.',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
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
    );
  }
}