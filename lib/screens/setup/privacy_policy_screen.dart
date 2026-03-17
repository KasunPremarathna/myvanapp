import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final Widget nextScreen;

  const PrivacyPolicyScreen({super.key, required this.nextScreen});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isAccepted = false;
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    if (!_isAccepted) return;

    setState(() => _isLoading = true);

    // 1. Request Notification Permissions
    await NotificationService.requestPermissions();

    // 2. Save Acceptance Flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_accepted', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        'Welcome to My Van! Your privacy is important to us. '
                        'We only store your van details, service history, '
                        'and fuel records on secure Firebase servers. '
                        'Your data is private to your account and is not shared with third parties. '
                        'We use local notifications to remind you of upcoming services. '
                        'By using this app, you agree to our terms of service and privacy policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAccepted,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (val) {
                          setState(() => _isAccepted = val ?? false);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I accept the Privacy Policy',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isAccepted && !_isLoading) ? _handleAccept : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accept & Continue',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
