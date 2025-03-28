import 'package:flutter/material.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Réductions & Offres'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOfferCard(
            context,
            title: 'Pneus Michelin',
            description: 'Remise exceptionnelle sur les pneus Michelin Pilot Sport 4. Montage offert pour un train complet.',
            validUntil: '30/04/2024',
            discount: '25%',
            color: Colors.blue,
          ),
          _buildOfferCard(
            context,
            title: 'Vidange + Filtres',
            description: 'Pack entretien complet : vidange d\'huile, filtre à huile, filtre à air et filtre d\'habitacle inclus',
            validUntil: '15/04/2024',
            discount: '40€',
            color: Colors.green,
          ),
          _buildOfferCard(
            context,
            title: 'Freins Premium',
            description: 'Plaquettes et disques de frein de marque Brembo. Installation par un professionnel certifié.',
            validUntil: '31/03/2024',
            discount: '30%',
            color: Colors.orange,
          ),
          _buildOfferCard(
            context,
            title: 'Batterie Bosch',
            description: 'Batterie Bosch S5 avec garantie 3 ans. Diagnostic électrique gratuit inclus.',
            validUntil: '20/04/2024',
            discount: '45€',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String description,
    required String validUntil,
    required String discount,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF2A2B2E),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Économisez $discount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Valable jusqu\'au $validUntil',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Offre ajoutée à vos réductions'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Utiliser'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 