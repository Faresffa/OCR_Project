import 'package:flutter/material.dart';

class CarDashboard extends StatefulWidget {
  const CarDashboard({super.key});

  @override
  CarDashboardState createState() => CarDashboardState();
}

class CarDashboardState extends State<CarDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tableau de Bord'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color(0xFF1A1B1E),
      body: SafeArea(
        child: Stack(
          children: [
            // En-tête avec le titre "Replaced Parts"
            const Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Replaced Parts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Zone centrale pour la voiture 3D
            Center(
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B2E),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 100,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),

            // Boutons circulaires flottants
            ..._buildFloatingButtons(),

            // Panneau inférieur avec les statistiques
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2B2E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCircularIndicator(19, 'Engine'),
                          _buildCircularIndicator(28, 'Battery'),
                          _buildCircularIndicator(22, 'Tires'),
                          _buildCircularIndicator(23, 'Brakes'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildReplacedPartsList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingButtons() {
    final List<Map<String, double>> positions = [
      {'top': 100.0, 'left': 20.0},
      {'top': 150.0, 'left': 40.0},
      {'top': 200.0, 'left': 20.0},
      {'top': 100.0, 'right': 20.0},
      {'top': 150.0, 'right': 40.0},
      {'top': 200.0, 'right': 20.0},
    ];

    return positions.map((position) {
      return Positioned(
        top: position['top'] ?? 0.0,
        left: position['left'],
        right: position['right'],
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3B3E),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.build,
            color: Colors.white54,
            size: 20.0,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCircularIndicator(int value, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReplacedPartsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildListItem('Engine Oil', 'Changed on 12/03/2024'),
        _buildListItem('Air Filter', 'Changed on 10/03/2024'),
        _buildListItem('Brake Pads', 'Changed on 05/03/2024'),
        _buildListItem('Battery', 'Changed on 01/03/2024'),
      ],
    );
  }

  Widget _buildListItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3B3E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 