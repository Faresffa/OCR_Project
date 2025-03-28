import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_screen.dart';
import 'login_screen.dart';
import 'car_dashboard.dart';
import 'offers_screen.dart';
import 'ticket_history_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userEmail;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await _authService.getUserEmail();
    setState(() {
      userEmail = email;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    setState(() {
      userEmail = null;
    });
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildFeatureButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR App'),
        actions: [
          if (userEmail != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  userEmail!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Se déconnecter',
            ),
          ] else
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Se connecter',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: userEmail == null
          ? const Center(
              child: Text(
                'Veuillez vous connecter pour accéder à l\'application',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Bienvenue !',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureButton(
                        text: 'Scanner un Ticket',
                        icon: Icons.document_scanner,
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScanScreen()),
                          );
                        },
                      ),
                      _buildFeatureButton(
                        text: 'Tableau de Bord',
                        icon: Icons.dashboard,
                        color: Colors.green,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CarDashboard()),
                          );
                        },
                      ),
                      _buildFeatureButton(
                        text: 'Réductions & Offres',
                        icon: Icons.local_offer,
                        color: Colors.orange,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OffersScreen()),
                          );
                        },
                      ),
                      _buildFeatureButton(
                        text: 'Historique des Tickets',
                        icon: Icons.history,
                        color: Colors.purple,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TicketHistoryScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}