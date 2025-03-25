import 'dart:io';
import 'dart:convert'; // Ajout de l'import pour base64
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Optimise une image pour l'OCR en ajustant la luminosité et le contraste
  static Future<File> optimizeImageForOCR(File imageFile) async {
    try {
      // Décoder l'image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }
      
      // Prétraitement de l'image
      final processedImage = img.copyResize(
        image,
        width: 1000, // Redimensionner pour une meilleure performance
      );
      
      // Améliorer le contraste (ajouter un facteur de contraste)
      final contrastImage = img.contrast(
        processedImage,
        contrast: 1.5, // Ajustez ce facteur selon vos besoins
      );
      
      // Conversion en niveau de gris (meilleur pour l'OCR)
      final grayscaleImage = img.grayscale(contrastImage);
      
      // Obtenir le chemin temporaire pour enregistrer l'image optimisée
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Enregistrer l'image optimisée
      final optimizedFile = File(tempPath);
      await optimizedFile.writeAsBytes(img.encodeJpg(grayscaleImage, quality: 90));
      
      return optimizedFile;
    } catch (e) {
      print('Erreur lors de l\'optimisation de l\'image: $e');
      return imageFile; // Retourner l'image originale en cas d'erreur
    }
  }

  /// Recadre une image autour du ticket
  static Future<File> cropTicketArea(File imageFile) async {
    try {
      // Cette fonction serait idéalement implémentée avec un algorithme de détection de contours
      // Pour l'instant, nous retournons simplement l'image originale
      return imageFile;
      
      // Un exemple d'implémentation plus avancée pourrait utiliser:
      // - OpenCV pour la détection de contours
      // - Des algorithmes de détection de rectangles
      // - Des modèles ML pour la détection de tickets
    } catch (e) {
      print('Erreur lors du recadrage de l\'image: $e');
      return imageFile;
    }
  }

  /// Compresse une image pour réduire sa taille avant l'envoi au serveur
  static Future<File> compressImage(File imageFile, {int quality = 85}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }
      
      // Redimensionner l'image si elle est trop grande
      img.Image resizedImage;
      if (image.width > 1200 || image.height > 1200) {
        // Correction de la fonction copyResize
        resizedImage = img.copyResize(
          image,
          width: 1200,
          height: (1200 * image.height / image.width).round(),
        );
      } else {
        resizedImage = image;
      }
      
      // Compresser l'image
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      // Enregistrer l'image compressée
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      print('Erreur lors de la compression de l\'image: $e');
      return imageFile;
    }
  }

  /// Rotation de l'image selon l'angle spécifié
  static Future<File> rotateImage(File imageFile, int degrees) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }
      
      // Rotation de l'image (correction)
      final rotatedImage = img.copyRotate(image, angle: degrees);
      
      // Enregistrer l'image rotée
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final rotatedFile = File(tempPath);
      await rotatedFile.writeAsBytes(img.encodeJpg(rotatedImage, quality: 90));
      
      return rotatedFile;
    } catch (e) {
      print('Erreur lors de la rotation de l\'image: $e');
      return imageFile;
    }
  }

  /// Convertit une image en base64 pour l'envoi au serveur
  static Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Erreur lors de la conversion en base64: $e');
      throw Exception('Impossible de convertir l\'image en base64');
    }
  }

  /// Convertit une chaîne base64 en image
  static Future<File> base64ToImage(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/decoded_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final imageFile = File(tempPath);
      await imageFile.writeAsBytes(bytes);
      
      return imageFile;
    } catch (e) {
      throw Exception('Impossible de convertir la chaîne base64 en image');
    }
  }
}
