// �cran principal de l'application (accueil, scanner, r�sultats)
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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