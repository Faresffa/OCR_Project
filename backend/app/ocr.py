import os
import re
import json
from PIL import Image
from datetime import datetime
from flask import current_app
from .utils import preprocess_image, extract_text_with_mistral

def process_image(image_path):
    """
    Traite une image avec OCR pour extraire les informations du ticket en utilisant Mistral PixTral.

    Args:
        image_path (str): Chemin vers l'image à traiter
    
    Returns:
        dict: Dictionnaire contenant les informations extraites du ticket
    """
    # Prétraiter l'image pour améliorer la qualité de l'OCR
    preprocessed_image = preprocess_image(image_path)

    # Extraire le texte avec Mistral PixTral
    raw_text = extract_text_with_mistral(preprocessed_image)
    
    if not raw_text:
        return {
            'merchant': '',
            'amount': 0.0,
            'date': None,
            'transaction_id': '',
            'raw_text': ''
        }

    try:
        # Parser le JSON retourné par Mistral
        extracted_data = json.loads(raw_text)
        
        # Convertir la date en objet datetime si elle existe
        if 'date' in extracted_data and extracted_data['date']:
            try:
                extracted_data['date'] = datetime.strptime(extracted_data['date'], '%Y-%m-%d')
            except ValueError:
                extracted_data['date'] = None
        
        return extracted_data
    except json.JSONDecodeError:
        current_app.logger.error("Erreur lors du décodage du JSON retourné par Mistral")
        return {
            'merchant': '',
            'amount': 0.0,
            'date': None,
            'transaction_id': '',
            'raw_text': raw_text
        }