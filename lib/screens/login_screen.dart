import 'package:flutter/material.dart';

import '../services/banco_service.dart';
import '../screens/sessao_usuario.dart';
import '../widgets/cabecalho.dart';
import 'cadastro_usuario_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BancoService banco = BancoService();

  final _formKey = GlobalKey<FormState>();

  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();

  bool entrando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => entrando = true);

    try {
      final usuario = await banco.login(
        usuario: usuarioController.text.trim(),
        senha: senhaController.text,
      );

      if (!mounted) return;

      setState(() => entrando = false);

      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ou senha inválidos.')),
        );
        return;
      }

      SessaoUsuario.instance.definirUsuario(usuario);

      Navigator.pop(context, usuario);
    } catch (e) {
      if (!mounted) return;

      setState(() => entrando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar: $e')),
      );
    }
  }

  void abrirCadastro() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CadastroUsuarioScreen()),
    );
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    bool senha = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            // CARD BRANCO TRANSPARENTE
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: senha,
            validator: (valor) =>
                (valor == null || valor.trim().isEmpty) ? 'Obrigatório' : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8FF),
      body: SafeArea(
        child: Column(
          children: [
            const Cabecalho(),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.asset(
                        'imgs/logofosca.png',
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          // CARD BRANCO TRANSPARENTE (painel principal)
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6F5A),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _campo(
                                  label: 'Usuário:',
                                  controller: usuarioController),
                              const SizedBox(height: 14),
                              _campo(
                                label: 'Senha:',
                                controller: senhaController,
                                senha: true,
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: abrirCadastro,
                                child: const Text(
                                  'Fazer Cadastro',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: entrando ? null : entrar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6F5A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: entrando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Entrar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}