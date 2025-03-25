// Écran de scan pour prendre la photo du ticket
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'result_screen.dart';
import '../utils/image_utils.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isProcessing = false;
  final ApiService _apiService = ApiService();

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  // Ajout de la méthode de rotation d'image
  Future<void> _rotateImage() async {
    if (_imageFile == null) return;
    
    final rotatedImage = await ImageUtils.rotateImage(_imageFile!, 90);
    
    setState(() {
      _imageFile = rotatedImage;
    });
  }

  // Méthode mise à jour pour le traitement d'image
  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Optimiser l'image pour l'OCR
      final optimizedImage = await ImageUtils.optimizeImageForOCR(_imageFile!);
      
      // Compresser l'image pour l'envoi au serveur
      final compressedImage = await ImageUtils.compressImage(optimizedImage);
      
      // Envoyer l'image au serveur
      final result = await _apiService.uploadImage(compressedImage);
      
      // Navigation vers l'écran de résultat
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(ticketData: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un Ticket'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Colors.grey,
                    ),
                  )
                : Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            const SizedBox(height: 30),
            _imageFile == null
                ? ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Prendre une Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _takePicture,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reprendre'),
                          ),
                          const SizedBox(width: 20),
                          // Ajout du bouton de rotation
                          ElevatedButton.icon(
                            onPressed: _rotateImage,
                            icon: const Icon(Icons.rotate_right),
                            label: const Text('Pivoter'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _processImage,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check),
                        label: Text(_isProcessing ? 'Traitement...' : 'Analyser'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
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
}