import os
import tempfile
from pdf2image import convert_from_path
from PIL import Image

def get_poppler_path():
    """
    Retourne le chemin vers poppler.
    """
    # Chemins possibles pour poppler
    possible_paths = [
        r"C:\Program Files\poppler-23.11.0\Library\bin",
        r"C:\Program Files (x86)\poppler-23.11.0\Library\bin",
        os.path.join(os.environ.get('PROGRAMFILES', ''), 'poppler-23.11.0', 'Library', 'bin'),
        os.path.join(os.environ.get('PROGRAMFILES(X86)', ''), 'poppler-23.11.0', 'Library', 'bin')
    ]
    
    # Vérifier chaque chemin possible
    for path in possible_paths:
        if os.path.exists(path):
            return path
    
    # Si aucun chemin n'est trouvé, essayer de trouver dans le PATH
    import subprocess
    try:
        result = subprocess.run(['where', 'pdftoppm'], capture_output=True, text=True)
        if result.returncode == 0 and result.stdout:
            return os.path.dirname(result.stdout.split('\n')[0])
    except:
        pass
    
    return None

def convert_pdf_to_images(pdf_path):
    """
    Convertit un PDF en images.
    
    Args:
        pdf_path (str): Chemin du fichier PDF
    
    Returns:
        list: Liste des chemins des images générées
    """
    try:
        # Créer un dossier temporaire pour les images
        temp_dir = tempfile.gettempdir()
        output_dir = os.path.join(temp_dir, 'pdf_images')
        os.makedirs(output_dir, exist_ok=True)
        
        # Obtenir le chemin de poppler
        poppler_path = get_poppler_path()
        if not poppler_path:
            raise Exception("Poppler n'est pas installé ou n'est pas trouvé dans le PATH")
        
        # Convertir le PDF en images
        images = convert_from_path(pdf_path, poppler_path=poppler_path)
        
        # Sauvegarder chaque page comme une image
        image_paths = []
        for i, image in enumerate(images):
            image_path = os.path.join(output_dir, f'page_{i+1}.jpg')
            image.save(image_path, 'JPEG')
            image_paths.append(image_path)
        
        return image_paths
    except Exception as e:
        print(f"Erreur lors de la conversion du PDF : {e}")
        return [] 