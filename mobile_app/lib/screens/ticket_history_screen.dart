import 'package:flutter/material.dart';
import 'dart:math';

class TicketHistoryScreen extends StatelessWidget {
  const TicketHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Historique des Tickets'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // À remplacer par la vraie liste des tickets
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: const Color(0xFF2A2B2E),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                'Ticket #${1000 + index}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Montant: ${(Random().nextDouble() * 100 + 50).toStringAsFixed(2)}€',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onPressed: () {
                  // Navigation vers le détail du ticket
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Détails du ticket à implémenter'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
} 