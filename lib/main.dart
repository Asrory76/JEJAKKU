import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'lanjutan.dart';

void main() {
  runApp(const MyApp());
}

// ======================================================
// MY APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPS Tracker',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087789)),
      ),
      home: const LoginPage(),
    );
  }
}

// ======================================================
// LOGIN PAGE
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController =
      TextEditingController(text: 'aryacahyo');

  final TextEditingController passwordController =
      TextEditingController(text: 'password123');

  bool showPassword = false;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan username dan password.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.login(
        username: username,
        password: password,
      );

      if (mounted) {
        final userName = res['user']?['name'] ?? username;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login berhasil! Selamat datang, $userName.'),
            backgroundColor: const Color(0xFF087789),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showServerConfigDialog() {
    final TextEditingController urlController =
        TextEditingController(text: ApiService.baseUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengaturan Server API'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah URL backend jika Anda menguji di emulator atau HP fisik:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'Base URL Backend',
                  hintText: 'http://10.0.2.2:3000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Web/Desktop: http://localhost:3000\n• Android Emulator: http://10.0.2.2:3000\n• HP Fisik: http://<IP_KOMPUTER>:3000',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087789),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  setState(() {
                    ApiService.baseUrl = newUrl;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('URL backend diubah ke: $newUrl')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog() {
    final TextEditingController regUser = TextEditingController();
    final TextEditingController regEmail = TextEditingController();
    final TextEditingController regPass = TextEditingController();
    final TextEditingController regName = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Daftar Akun Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: regName,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: regUser,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: regEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: regPass,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087789),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (regUser.text.trim().isEmpty ||
                              regEmail.text.trim().isEmpty ||
                              regPass.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua kolom wajib diisi.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          try {
                            await ApiService.register(
                              username: regUser.text.trim(),
                              email: regEmail.text.trim(),
                              password: regPass.text,
                              name: regName.text.trim(),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              usernameController.text = regUser.text.trim();
                              passwordController.text = regPass.text;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pendaftaran berhasil! Silakan klik LOGIN.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (err) {
                            setDialogState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    err
                                        .toString()
                                        .replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Daftar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF087789)),
            tooltip: 'Konfigurasi Server API',
            onPressed: _showServerConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ======================================================
              // LOGO MOTOR
              // ======================================================
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF087789),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF087789).withOpacity(0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  size: 65,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // TITLE
              // ======================================================
              const Text(
                'JEJAKKU',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Pantau kendaraan Anda dengan mudah dan aman',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF7B8496)),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // LOGIN CARD
              // ======================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Masuk untuk memantau armada Anda',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7B8496)),
                    ),

                    const SizedBox(height: 20),

                    // USERNAME
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan username',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA3B2),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF9AA3B2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F7F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA3B2),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF9AA3B2),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF9AA3B2),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F7F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // LUPA PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur lupa password belum diaktifkan.',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Lupa password?',
                          style: TextStyle(
                            color: Color(0xFF087789),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ======================================================
                    // LOGIN BUTTON
                    // ======================================================
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF087789),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ======================================================
                    // DAFTAR
                    // ======================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun?',
                          style: TextStyle(
                            color: Color(0xFF7B8496),
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: _showRegisterDialog,
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: Color(0xFF087789),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Tersambung ke: ${ApiService.baseUrl}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF7B8496)),
              ),

              const SizedBox(height: 6),

              const Text(
                'GPS Tracker • Smart Vehicle Monitoring',
                style: TextStyle(fontSize: 10, color: Color(0xFF9AA3B2)),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
