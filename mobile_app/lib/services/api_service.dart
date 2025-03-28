// Service pour gérer les requêtes HTTP vers le backend Flask
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';
import '../utils/image_utils.dart';
import '../config/api_config.dart';

class ApiService {
  // Méthode utilisant multipart pour envoyer l'image
  Future<TicketModel> uploadImage(File imageFile) async {
    try {
      print("\n=== Début de l'envoi de l'image ===");
      print("Taille du fichier: ${imageFile.lengthSync()} bytes");
      
      // Créer une requête multipart
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadUrl));
      
      // Ajouter l'image au fichier multipart
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
      
      print("\n=== Envoi de la requête ===");
      print("URL: ${ApiConfig.uploadUrl}");
      
      // Envoyer la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print("\n=== Réponse reçue ===");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");
      
      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        try {
          final responseData = response.body;
          final jsonData = json.decode(responseData);
          
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
        print("Réponse: ${response.body}");
        throw Exception('Échec de l\'analyse OCR: ${response.statusCode}, ${response.body}');
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
        Uri.parse(ApiConfig.uploadUrl),
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
      final response = await http.get(Uri.parse(ApiConfig.baseUrl + '/tickets'));
      
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
      final response = await http.get(Uri.parse(ApiConfig.baseUrl + '/tickets/$ticketId'));
      
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