import 'package:flutter/material.dart';

import '../services/banco_service.dart';
import '../widgets/cabecalho.dart';
import 'login_screen.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final BancoService banco = BancoService();

  final _formKey = GlobalKey<FormState>();

  final usuarioController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool salvando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    emailController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não conferem.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      await banco.cadastrarUsuario(
        usuario: usuarioController.text.trim(),
        senha: senhaController.text,
        email: emailController.text.trim(),
        cpf: cpfController.text.trim(),
        telefone: telefoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() => salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      abrirLogin();
    } catch (e) {
      if (!mounted) return;

      setState(() => salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('UNIQUE')
                ? 'Esse usuário já existe.'
                : 'Erro ao cadastrar: $e',
          ),
        ),
      );
    }
  }

  void abrirLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    bool senha = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: senha,
            keyboardType: keyboardType,
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Cadastro',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6F5A),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _campo(
                                label: 'Usuário:',
                                controller: usuarioController),
                            const SizedBox(height: 12),
                            _campo(
                              label: 'Email:',
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _campo(
                              label: 'CPF:',
                              controller: cpfController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _campo(
                              label: 'Telefone:',
                              controller: telefoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            _campo(
                              label: 'Senha:',
                              controller: senhaController,
                              senha: true,
                            ),
                            const SizedBox(height: 12),
                            _campo(
                              label: 'Confirmar Senha:',
                              controller: confirmarSenhaController,
                              senha: true,
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: abrirLogin,
                              child: const Text(
                                'Fazer Login',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: salvando ? null : cadastrar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6F5A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: salvando
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}