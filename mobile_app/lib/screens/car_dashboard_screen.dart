import 'package:flutter/material.dart';
import '../services/car_service.dart';
import '../screens/login_screen.dart';
import '../screens/add_car_screen.dart';

class CarDashboardScreen extends StatefulWidget {
  const CarDashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CarDashboardScreenState createState() => _CarDashboardScreenState();
}

class _CarDashboardScreenState extends State<CarDashboardScreen> {
  final CarService _carService = CarService();
  List<dynamic> _cars = [];
  dynamic _selectedCar;
  List<dynamic> _maintenanceRecords = [];
  bool _isLoading = true;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _fetchUserCars();
  }

  Future<void> _fetchUserCars() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final cars = await _carService.getUserCars();
        setState(() {
          _cars = cars.isNotEmpty ? cars : [_generateDemoCar()];
          _isUserLoggedIn = cars.isNotEmpty;
          _isLoading = false;
          _selectCar(_cars.first);
        });
      } catch (e) {
        // Fallback to demo car if fetching fails
        setState(() {
          _cars = [_generateDemoCar()];
          _isUserLoggedIn = false;
          _isLoading = false;
          _selectCar(_cars.first);
        });
        _showErrorSnackBar('Impossible de charger les voitures : ${e.toString()}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _cars = [_generateDemoCar()];
        _isUserLoggedIn = false;
      });
      _showErrorSnackBar('Erreur inattendue : ${e.toString()}');
    }
  }

  dynamic _generateDemoCar() {
    return {
      'id': 'demo_car_001',
      'make': 'Toyota',
      'model': 'Camry',
      'year': '2022',
      'color': 'Silver',
      'mileage': '15000',
      'isDemo': true,
      'details': {
        'engine': 'Bon état',
        'transmission': 'Automatique',
        'lastService': '2023-08-15',
      },
      'maintenanceHistory': [
        {
          'type': 'Changement d\'huile',
          'date': '2023-08-15',
          'description': 'Entretien régulier',
          'cost': '65.00'
        },
        {
          'type': 'Rotation des pneus',
          'date': '2023-06-20',
          'description': 'Rotation et équilibrage des pneus',
          'cost': '45.00'
        }
      ]
    };
  }

  Future<void> _selectCar(dynamic car) async {
    try {
      final maintenanceRecords = await _carService.getMaintenanceRecords(car['id']);
      setState(() {
        _selectedCar = car;
        _maintenanceRecords = maintenanceRecords;
      });
    } catch (e) {
      // Use car's built-in maintenance history if service fails
      setState(() {
        _selectedCar = car;
        _maintenanceRecords = car['maintenanceHistory'] ?? [];
      });
      _showErrorSnackBar('Impossible de charger l\'historique : ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToAddCar() {
    if (!_isUserLoggedIn) {
      // Redirect to login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      // Redirect to add car screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddCarScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Voiture'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddCar,
            tooltip: 'Ajouter une voiture',
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        // Demo user indicator
        if (!_isUserLoggedIn)
          Container(
            color: Colors.orange.shade100,
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vous utilisez une voiture de démonstration. Connectez-vous pour personnaliser.',
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),

        // Car details
        if (_selectedCar != null)
          Expanded(
            child: ListView(
              children: [
                _buildCarInfoCard(),
                _buildMaintenanceHistoryCard(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCarInfoCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedCar['make']} ${_selectedCar['model']}', 
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Année: ${_selectedCar['year']}'),
                Text('Couleur: ${_selectedCar['color']}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kilométrage: ${_selectedCar['mileage']} km'),
                ElevatedButton(
                  onPressed: _showCarDetailsDialog,
                  child: Text('Plus de détails'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceHistoryCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique de maintenance', 
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_isUserLoggedIn)
                  ElevatedButton(
                    onPressed: _showAddMaintenanceDialog,
                    child: Icon(Icons.add),
                  ),
              ],
            ),
          ),
          _buildMaintenanceHistoryList(),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistoryList() {
    final history = _selectedCar['maintenanceHistory'] ?? [];

    if (history.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucun historique de maintenance'),
      );
    }

    return Column(
      children: history.map<Widget>((record) {
        return ListTile(
          title: Text(record['type'] ?? 'Maintenance'),
          subtitle: Text(record['date'] ?? 'Date inconnue'),
          trailing: Text('${record['cost']} €'),
          onTap: () {
            _showMaintenanceDetailsDialog(record);
          },
        );
      }).toList(),
    );
  }

  void _showCarDetailsDialog() {
    final details = _selectedCar['details'] ?? {};
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la voiture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Moteur: ${details['engine'] ?? 'Non disponible'}'),
            Text('Transmission: ${details['transmission'] ?? 'Non disponible'}'),
            Text('Dernier service: ${details['lastService'] ?? 'Non disponible'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceDetailsDialog(dynamic record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record['type'] ?? 'Maintenance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${record['date'] ?? 'Date inconnue'}'),
            Text('Description: ${record['description'] ?? 'Aucune description'}'),
            Text('Coût: ${record['cost'] ?? '0'} €'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAddMaintenanceDialog() {
    // Only if logged in
    if (!_isUserLoggedIn) {
      _showErrorSnackBar('Veuillez vous connecter pour ajouter un entretien');
      return;
    }

    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un entretien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type d\'entretien'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: costController,
              decoration: InputDecoration(labelText: 'Coût'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement actual maintenance record addition
              Navigator.of(context).pop();
              _showErrorSnackBar('Fonctionnalité non implémentée');
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}