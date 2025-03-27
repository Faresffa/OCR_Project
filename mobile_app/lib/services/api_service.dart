// Service pour gérer les requêtes HTTP vers le backend Flask
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';
import '../utils/image_utils.dart';

class ApiService {
  // Remplacez cette URL par l'adresse de votre API backend
  final String baseUrl = 'http://10.0.2.2:5000/api';  // 10.0.2.2 pour l'émulateur Android

  // Méthode utilisant multipart pour envoyer l'image
  Future<TicketModel> uploadImage(File imageFile) async {
    try {
      print("\n=== Début de l'envoi de l'image ===");
      print("Taille du fichier: ${imageFile.lengthSync()} bytes");
      
      // Créer une requête multipart
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ocr'));
      
      // Ajouter l'image au fichier multipart
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      print("Envoi de la requête au serveur...");
      // Envoyer la requête
      var response = await request.send();
      
      // Récupérer la réponse
      var responseData = await response.stream.bytesToString();
      
      print("\n=== Réponse du serveur ===");
      print("Code de statut: ${response.statusCode}");
      print("Données reçues:");
      print(responseData);
      
      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        try {
          // Convertir la réponse en modèle TicketModel
          final jsonData = json.decode(responseData);
          print("\n=== Données JSON décodées ===");
          print(jsonData);
          
          // Vérifier la structure des données
          if (jsonData == null) {
            print("❌ Les données reçues sont nulles");
            throw Exception('Les données reçues sont nulles');
          }
          
          if (jsonData is! Map<String, dynamic>) {
            print("❌ Les données reçues ne sont pas un objet JSON valide");
            throw Exception('Les données reçues ne sont pas un objet JSON valide');
          }

          // Vérifier si les données sont dans un objet 'data'
          final data = jsonData['data'] as Map<String, dynamic>? ?? jsonData;
          print("\n=== Données extraites ===");
          print(data);
          
          // Vérifier les champs requis
          print("\n=== Vérification des champs requis ===");
          if (!data.containsKey('date')) {
            print("⚠️ Champ date manquant");
          }
          if (!data.containsKey('ticket_number')) {
            print("⚠️ Champ ticket_number manquant");
          }
          if (!data.containsKey('total')) {
            print("⚠️ Champ total manquant");
          }
          if (!data.containsKey('payment_mode')) {
            print("⚠️ Champ payment_mode manquant");
          }
          if (!data.containsKey('articles')) {
            print("⚠️ Champ articles manquant");
          }
          
          print("\n=== Création du modèle TicketModel ===");
          final ticket = TicketModel.fromJson(data);
          print("✅ Modèle créé avec succès");
          print("Articles trouvés: ${ticket.articles.length}");
          if (ticket.articles.isNotEmpty) {
            print("Premier article: ${ticket.articles.first.name} - ${ticket.articles.first.price}€");
          }
          print("=== Fin du traitement ===\n");
          
          return ticket;
        } catch (e) {
          print("\n❌ Erreur lors du parsing JSON: $e");
          throw Exception('Erreur lors du traitement des données: $e');
        }
      } else {
        print("\n❌ Erreur serveur: ${response.statusCode}");
        print("Réponse: $responseData");
        throw Exception('Échec de l\'analyse OCR: ${response.statusCode}, $responseData');
      }
    } catch (e) {
      print("\n❌ Erreur lors de l'envoi de l'image: $e");
      throw Exception('Erreur lors de l\'envoi de l\'image: $e');
    }
  }

  // Méthode alternative utilisant base64 pour envoyer l'image
  Future<TicketModel> uploadImageAsBase64(File imageFile) async {
    try {
      // Convertir l'image en base64
      final base64Image = await ImageUtils.imageToBase64(imageFile);
      
      // Envoyer l'image en base64 au serveur
      final response = await http.post(
        Uri.parse('$baseUrl/ocr'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'image': base64Image,
        }),
      );
      
      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        // Convertir la réponse en modèle TicketModel
        return TicketModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec de l\'analyse OCR: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'image: $e');
    }
  }

  // Vous pouvez ajouter d'autres méthodes API ici (récupérer l'historique, etc.)
  // Par exemple:
  
  // Récupérer l'historique des tickets
  Future<List<TicketModel>> getTicketHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((ticket) => TicketModel.fromJson(ticket)).toList();
      } else {
        throw Exception('Échec de récupération de l\'historique: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique: $e');
    }
  }
  
  // Obtenir les détails d'un ticket spécifique
  Future<TicketModel> getTicketDetails(String ticketId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets/$ticketId'));
      
      if (response.statusCode == 200) {
        return TicketModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec de récupération du ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du ticket: $e');
    }
  }
}