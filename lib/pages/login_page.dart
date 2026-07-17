import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../models/response_model.dart';
import '../provider/common_provider.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'main_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await LocalStorageService.getSavedCredentials();
    if (credentials.isNotEmpty) {
      _usernameController.text = credentials['username'] ?? '';
      _passwordController.text = credentials['password'] ?? '';
      if (mounted) setState(() => _rememberMe = true);
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('กรุณากรอกชื่อเข้าใช้งานและรหัสผ่าน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        ref.read(loginProvider.notifier).state = result.data;
        ref.read(userProvider.notifier).state = result.data.user;

        // ดึงข้อมูลผู้ใช้ (mock)
        final meResult = await AuthService.me();
        if (!mounted) return;
        if (meResult.responseEnum == ResponseEnum.success) {
          ref.read(meProvider.notifier).state = meResult.data;
          ref.read(userProvider.notifier).state = meResult.data.user;
        }

        if (_rememberMe) {
          await LocalStorageService.saveCredentials(
            username: username,
            password: password,
          );
        } else {
          await LocalStorageService.clearCredentials();
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        _showError('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('ไม่สามารถเข้าสู่ระบบได้: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Social login (stub) ─────────────────────────────────────────────────
  // TODO: ต่อ SDK จริงเมื่อได้ credential/หลังบ้าน
  //   - เบอร์โทร: OTP flow (endpoint ฝั่ง patient)
  //   - LINE: flutter_line_sdk + LINE channel ID
  //   - Facebook: flutter_facebook_auth + FB App ID
  void _loginWithPhone() => _showComingSoon('เข้าสู่ระบบด้วยเบอร์โทรศัพท์');
  void _loginWithLine() => _showComingSoon('เข้าสู่ระบบด้วย LINE');
  void _loginWithFacebook() => _showComingSoon('เข้าสู่ระบบด้วย Facebook');

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — กำลังพัฒนา')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary1, AppTheme.primaryThemeApp],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'MedFlow',
                        textAlign: TextAlign.center,
                        style: AppTheme.generalText(
                          28,
                          fonWeight: FontWeight.bold,
                          color: AppTheme.primaryThemeApp,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'สำหรับผู้ป่วย',
                        textAlign: TextAlign.center,
                        style: AppTheme.generalText(
                          16,
                          color: AppTheme.secondaryText62,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Username
                      _fieldLabel('ชื่อเข้าใช้งาน'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        enabled: !_isLoading,
                        style: AppTheme.generalText(16,
                            color: AppTheme.primaryText),
                        decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.person, color: AppTheme.secondaryText62),
                          hintText: 'ชื่อเข้าใช้งาน',
                          hintStyle: AppTheme.generalText(16,
                              color: AppTheme.secondaryText62),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Password
                      _fieldLabel('รหัสผ่าน'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        style: AppTheme.generalText(16,
                            color: AppTheme.primaryText),
                        decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.lock, color: AppTheme.secondaryText62),
                          hintText: 'รหัสผ่าน',
                          hintStyle: AppTheme.generalText(16,
                              color: AppTheme.secondaryText62),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.secondaryText62,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Remember me
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: _isLoading
                                  ? null
                                  : (v) =>
                                      setState(() => _rememberMe = v ?? false),
                              activeColor: AppTheme.primaryThemeApp,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'จดจำบัญชีผู้ใช้',
                            style: AppTheme.generalText(16,
                                color: AppTheme.primaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Login button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('เข้าสู่ระบบ'),
                      ),
                      const SizedBox(height: 20),

                      // Divider "หรือ"
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.lineColorD9)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'หรือเข้าสู่ระบบด้วย',
                              style: AppTheme.generalText(13,
                                  color: AppTheme.secondaryText62),
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.lineColorD9)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Phone
                      _socialButton(
                        icon: Icons.phone,
                        iconColor: AppTheme.primaryThemeApp,
                        label: 'เบอร์โทรศัพท์',
                        onPressed: _isLoading ? null : _loginWithPhone,
                      ),
                      const SizedBox(height: 12),
                      // LINE
                      _socialButton(
                        icon: Icons.chat_bubble,
                        iconColor: AppTheme.lineBrand,
                        label: 'LINE',
                        onPressed: _isLoading ? null : _loginWithLine,
                      ),
                      const SizedBox(height: 12),
                      // Facebook
                      _socialButton(
                        icon: Icons.facebook,
                        iconColor: AppTheme.facebookBrand,
                        label: 'Facebook',
                        onPressed: _isLoading ? null : _loginWithFacebook,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTheme.generalText(
            16,
            color: AppTheme.primaryText,
            fonWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _socialButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: 22),
      label: Text(
        label,
        style: AppTheme.generalText(
          16,
          color: AppTheme.primaryText,
          fonWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: AppTheme.lineColorD9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
