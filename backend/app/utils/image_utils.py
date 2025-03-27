from PIL import Image, ImageEnhance
import os
import tempfile

def enhance_image_for_ocr(image_path):
    """
    Améliore la qualité d'une image pour l'OCR.
    
    Args:
        image_path (str): Chemin de l'image à améliorer
    
    Returns:
        str: Chemin de l'image améliorée
    """
    try:
        # Ouvrir l'image
        img = Image.open(image_path)
        
        # Convertir en niveaux de gris si nécessaire
        if img.mode != 'L':
            img = img.convert('L')
        
        # Améliorer le contraste
        enhancer = ImageEnhance.Contrast(img)
        img = enhancer.enhance(2.0)
        
        # Améliorer la netteté
        enhancer = ImageEnhance.Sharpness(img)
        img = enhancer.enhance(2.0)
        
        # Améliorer la luminosité
        enhancer = ImageEnhance.Brightness(img)
        img = enhancer.enhance(1.5)
        
        # Créer un fichier temporaire pour l'image améliorée
        temp_dir = os.path.dirname(image_path)  # Utiliser le même dossier que l'image d'origine
        temp_filename = f"enhanced_{os.path.basename(image_path)}"
        temp_path = os.path.join(temp_dir, temp_filename)
        
        # Sauvegarder l'image améliorée
        img.save(temp_path, 'JPEG', quality=95)
        
        return temp_path
    except Exception as e:
        print(f"Erreur lors de l'amélioration de l'image : {e}")
        return image_path  # Retourner le chemin original en cas d'erreur 