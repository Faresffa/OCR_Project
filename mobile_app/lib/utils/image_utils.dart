import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

class ImageUtils {
  // Optimisation de l'image pour OCR
  static Future<File> optimizeImageForOCR(File originalImage) async {
    try {
      // Charger l'image
      img.Image? image = await img.decodeImageFile(originalImage.path);
      
      if (image == null) {
        throw Exception('Impossible de charger l\'image');
      }

      // Convertir en noir et blanc
      img.Image grayscale = img.grayscale(image);
      
      // Augmenter le contraste
      img.Image contrastImage = img.contrast(grayscale, contrast: 1.5);
      
      // Créer un nouveau fichier
      File optimizedFile = File('${originalImage.path}_optimized.jpg');
      await optimizedFile.writeAsBytes(img.encodeJpg(contrastImage));
      
      return optimizedFile;
    } catch (e) {
      // Retourner l'image originale si l'optimisation échoue
      return originalImage;
    }
  }

  // Méthode simple de compression (réduire la taille de l'image)
  static Future<File> compressImage(File file) async {
    try {
      // Charger l'image
      img.Image? image = await img.decodeImageFile(file.path);
      
      if (image == null) {
        return file;
      }

      // Redimensionner l'image 
      img.Image resizedImage = img.copyResize(
        image, 
        width: 800,  // Largeur maximale
        height: 600, // Hauteur maximale
        interpolation: img.Interpolation.average
      );

      // Créer un nouveau fichier compressé
      File compressedFile = File('${file.path}_compressed.jpg');
      await compressedFile.writeAsBytes(
        img.encodeJpg(resizedImage, quality: 70)
      );
      
      return compressedFile;
    } catch (e) {
      return file;
    }
  }

  // Conversion en base64
  static Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }
}