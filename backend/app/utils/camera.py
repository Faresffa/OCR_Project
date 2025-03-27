import cv2
import os
import tempfile
from datetime import datetime

def capture_image():
    """
    Capture une image depuis la webcam.
    
    Returns:
        str: Chemin de l'image capturée
    """
    try:
        # Initialiser la webcam
        cap = cv2.VideoCapture(0)
        
        if not cap.isOpened():
            print("Erreur : Impossible d'accéder à la webcam")
            return None
        
        # Lire une frame
        ret, frame = cap.read()
        
        if not ret:
            print("Erreur : Impossible de capturer l'image")
            return None
        
        # Créer un fichier temporaire pour l'image
        temp_dir = tempfile.gettempdir()
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        image_path = os.path.join(temp_dir, f'capture_{timestamp}.jpg')
        
        # Sauvegarder l'image
        cv2.imwrite(image_path, frame)
        
        # Libérer la webcam
        cap.release()
        
        return image_path
    except Exception as e:
        print(f"Erreur lors de la capture d'image : {e}")
        if 'cap' in locals():
            cap.release()
        return None 