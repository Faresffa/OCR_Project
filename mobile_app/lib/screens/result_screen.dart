// Écran pour afficher les résultats extraits du ticket
import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../widgets/result_card.dart';
import '../services/database_service.dart';

class ResultScreen extends StatefulWidget {
  final TicketModel ticketData;
  
  const ResultScreen({Key? key, required this.ticketData}) : super(key: key);
  
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    // Ajout des logs pour déboguer
    print("\n=== ResultScreen - Données reçues ===");
    print("Date: ${widget.ticketData.date}");
    print("Numéro de ticket: ${widget.ticketData.ticketNumber}");
    print("Total: ${widget.ticketData.total}");
    print("Mode de paiement: ${widget.ticketData.paymentMode}");
    print("Nombre d'articles: ${widget.ticketData.articles.length}");
    print("\n=== Détail des articles ===");
    for (var article in widget.ticketData.articles) {
      print("Article: ${article.name}");
      print("  Prix: ${article.price}€");
      print("  Quantité: ${article.quantity}");
      print("  Total: ${article.price * article.quantity}€");
      print("---");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Résultats de l\'Analyse',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec les informations principales
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt, size: 24, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Ticket N°${widget.ticketData.ticketNumber}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            widget.ticketData.date,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.payment, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            widget.ticketData.paymentMode,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Liste des articles
            const Text(
              'Articles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.ticketData.articles.length,
              itemBuilder: (context, index) {
                final article = widget.ticketData.articles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      article.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Quantité: ${article.quantity}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${article.price.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Total: ${(article.price * article.quantity).toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.ticketData.total.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // Sauvegarder le ticket dans la base de données
                        await _saveTicketToDatabase();
                        
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ticket sauvegardé avec succès')),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Sauvegarder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Fermer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTicketToDatabase() async {
    try {
      // Sauvegarder le ticket dans la base de données
      final ticketId = await DatabaseService.instance.insertTicket(widget.ticketData);
      print('Ticket sauvegardé avec l\'ID: $ticketId');
    } catch (e) {
      print('Erreur lors de la sauvegarde en base de données: $e');
      throw Exception('Erreur lors de la sauvegarde en base de données: $e');
    }
  }
}