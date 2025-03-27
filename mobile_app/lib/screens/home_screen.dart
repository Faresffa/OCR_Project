import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'scan_screen.dart';
import 'login_screen.dart'; // Correct the file name here
import 'car_dashboard_screen.dart'; // Importez votre écran de tableau de bord

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Ticket Scanner'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scanner vos tickets facilement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Scanner un Ticket',
              icon: Icons.camera_alt,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Se Connecter',
              icon: Icons.login,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()), // Assurez-vous que le nom de la classe correspond
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Tableau de Bord',
              icon: Icons.dashboard,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarDashboardScreen()), // Assurez-vous que le nom de la classe correspond
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Historique des Tickets',
              icon: Icons.history,
              onPressed: () {
                // Navigation vers l'écran d'historique (à implémenter)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Historique des tickets - À implémenter'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}