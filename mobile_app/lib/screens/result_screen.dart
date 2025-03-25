// Écran pour afficher les résultats extraits du ticket
import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../widgets/result_card.dart';

class ResultScreen extends StatelessWidget {
  final TicketModel ticketData;
  
  const ResultScreen({Key? key, required this.ticketData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat de l\'analyse'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations extraites',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Utiliser le widget ResultCard importé
            ResultCard(
              title: 'Montant',
              value: '${ticketData.amount} €',
              icon: Icons.euro,
            ),
            ResultCard(
              title: 'Date',
              value: ticketData.date,
              icon: Icons.calendar_today,
            ),
            ResultCard(
              title: 'Commerçant',
              value: ticketData.merchant,
              icon: Icons.store,
            ),
            ResultCard(
              title: 'N° de transaction',
              value: ticketData.transactionId,
              icon: Icons.receipt,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Sauvegarder le ticket
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ticket sauvegardé')),
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Sauvegarder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Fermer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}