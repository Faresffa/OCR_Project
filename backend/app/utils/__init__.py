from .image_utils import enhance_image_for_ocr
from .pdf_to_img import convert_pdf_to_images
from .camera import capture_image

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'pdf'}

def allowed_file(filename):
    """
    Vérifie si l'extension du fichier est autorisée.
    
    Args:
        filename (str): Nom du fichier
    
    Returns:
        bool: True si l'extension est autorisée
    """
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

__all__ = ['enhance_image_for_ocr', 'convert_pdf_to_images', 'capture_image', 'allowed_file'] 