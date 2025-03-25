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
      // Créer une requête multipart
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ocr'));
      
      // Ajouter l'image au fichier multipart
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Envoyer la requête
      var response = await request.send();
      
      // Récupérer la réponse
      var responseData = await response.stream.bytesToString();
      
      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        // Convertir la réponse en modèle TicketModel
        return TicketModel.fromJson(json.decode(responseData));
      } else {
        throw Exception('Échec de l\'analyse OCR: ${response.statusCode}, $responseData');
      }
    } catch (e) {
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