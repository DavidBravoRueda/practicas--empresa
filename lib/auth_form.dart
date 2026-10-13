import 'package:flutter/material.dart';

import 'app_state.dart';

class LoginFormContent extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginFormContent({super.key, required this.onLoginSuccess});

  @override
  State<LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<LoginFormContent> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isCreatingAccount = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (!formKey.currentState!.validate()) return;

    isLoggedIn.value = true;
    widget.onLoginSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCreatingAccount
              ? 'Cuenta de demostración creada.'
              : 'Sesión iniciada correctamente.',
        ),
      ),
    );
  }

  void showProviderNotConfigured(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'El acceso con $provider estará disponible '
          'cuando configuremos la autenticación.',
        ),
      ),
    );
  }

  Widget buildSocialButton({
    required Widget leading,
    required String label,
    required VoidCallback onPressed,
    required bool isApple,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isApple ? Colors.black : Colors.white,
          foregroundColor: isApple ? Colors.white : textColor,
          side: BorderSide(
            color: isApple ? Colors.black : const Color(0xFFDADCE0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.bolt, size: 45, color: textColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isCreatingAccount ? 'Crear cuenta' : 'Iniciar sesión',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCreatingAccount
                  ? 'Únete a TecnoStore'
                  : 'Accede a tu cuenta de TecnoStore',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            if (isCreatingAccount) ...[
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                  return 'Introduce un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),
            if (!isCreatingAccount)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La recuperación estará disponible '
                          'al conectar la autenticación.',
                        ),
                      ),
                    );
                  },
                  child: const Text('¿Has olvidado tu contraseña?'),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: submitForm,
                child: Text(
                  isCreatingAccount ? 'CREAR CUENTA' : 'INICIAR SESIÓN',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFDADCE0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    isCreatingAccount ? 'O REGÍSTRATE CON' : 'O CONTINÚA CON',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFDADCE0))),
              ],
            ),
            const SizedBox(height: 20),
            buildSocialButton(
              leading: const Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              label: 'Continuar con Google',
              isApple: false,
              onPressed: () => showProviderNotConfigured('Google'),
            ),
            const SizedBox(height: 12),
            buildSocialButton(
              leading: const Text('', style: TextStyle(fontSize: 25)),
              label: 'Continuar con Apple',
              isApple: true,
              onPressed: () => showProviderNotConfigured('Apple'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  isCreatingAccount = !isCreatingAccount;
                });
              },
              child: Text(
                isCreatingAccount
                    ? '¿Ya tienes cuenta? Inicia sesión'
                    : '¿No tienes cuenta? Regístrate',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
